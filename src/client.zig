const std = @import("std");
const open62541 = @import("open62541");
const helper = @import("helper.zig");

pub fn main(init: std.process.Init) !void {
    errdefer {
        if (@errorReturnTrace()) |trace| {
            std.debug.dumpErrorReturnTrace(trace);
        }
    }
    const io = init.io;
    const client = open62541.UA_Client_new();
    defer open62541.UA_Client_delete(client);
    var retval = open62541.UA_ClientConfig_setDefault(open62541.UA_Client_getConfig(client));
    try helper.checkStatusCode(retval);
    retval = open62541.UA_Client_connect(
        client,
        @constCast("opc.tcp://192.168.250.1:4840"),
    );
    // retval = open62541.UA_Client_connect(
    //     client,
    //     @constCast("opc.tcp://localhost:4840"),
    // );
    try helper.checkStatusCode(retval);
    const config = open62541.UA_Client_getConfig(client);
    var custom_data_types: [*c]open62541.UA_DataTypeArray = null;
    try helper.checkStatusCode(
        open62541.UA_Client_getRemoteDataTypes(
            client,
            0,
            null,
            &custom_data_types,
        ),
    );
    config.*.customDataTypes = custom_data_types;

    // Read value
    // const node_id = open62541.UA_NODEID_NUMERIC(
    //     0,
    //     open62541.UA_NS0ID_SERVER_SERVERSTATUS_CURRENTTIME,
    // );
    // var variant = try read_attribute(client, node_id);
    // defer helper.UA_Clear(
    //     @ptrCast(@alignCast(&variant)),
    //     open62541.UA_DATATYPEKIND_VARIANT,
    // );
    // const raw_date: *open62541.UA_DateTime =
    //     @ptrCast(@alignCast(variant.data));
    // const dts = open62541.UA_DateTime_toStruct(raw_date.*);
    // std.log.debug(
    //     "date is: {}-{}-{} {}:{}:{}.{d:.3}",
    //     .{
    //         dts.day,
    //         dts.month,
    //         dts.year,
    //         dts.hour,
    //         dts.min,
    //         dts.sec,
    //         dts.milliSec,
    //     },
    // );
    // try browseAddressSpace(
    //     client,
    //     open62541.UA_NODEID_NUMERIC(0, open62541.UA_NS0ID_OBJECTSFOLDER),
    // );
    // const the_answer_variant = try read_attribute(
    //     client,
    //     open62541.UA_NODEID_STRING(1, @constCast("the.answer")),
    // );
    // std.log.debug(
    //     "the.answer: {}",
    //     .{@as(*open62541.UA_UInt32, @ptrCast(@alignCast(the_answer_variant.data))).*},
    // );
    // const attr = try read_attribute(
    //     client,
    //     open62541.UA_NODEID_STRING(4, @constCast("OPC_Node")),
    // );
    // const target =
    //     open62541.UA_NODEID_STRING(1, @constCast("OPC_Node_Data"));
    const target =
        open62541.UA_NODEID_STRING(4, @constCast("NodeData"));
    for (1..11) |i| {
        var timestamp: std.Io.Timestamp = .now(io, .awake);
        const attr = try read_attribute(client, target);
        var node_data: []helper.OPCNodeData = &.{};
        node_data.len = attr.arrayLength;
        node_data.ptr = @ptrCast(@alignCast(attr.data));
        std.log.debug("{f}", .{node_data[9]});
        node_data[9].BoardNo = @as(i16, @intCast(i));
        try writeAttribute(
            client,
            target,
            @ptrCast(@alignCast(node_data.ptr)),
            node_data.len,
            attr.type,
        );
        std.log.info("duration: {f}", .{timestamp.untilNow(io, .awake)});
        // for (node_data) |node| {
        //     std.log.debug("{f}", .{node});
        // }
    }
}

fn browseAddressSpace(
    client: ?*open62541.UA_Client,
    /// Node to browse
    node_id: open62541.UA_NodeId,
) !void {
    var bReq: open62541.UA_BrowseRequest = .{
        .nodesToBrowse = @ptrCast(@alignCast(open62541.UA_new(open62541.UA_DataType_get(open62541.UA_TYPES_BROWSEDESCRIPTION)))),
        .nodesToBrowseSize = 1,
    };
    bReq.nodesToBrowse[0] = .{
        .nodeId = node_id,
        .resultMask = open62541.UA_BROWSERESULTMASK_ALL,
    };
    const c_bResp = open62541.UA_Client_Service_browse_ptr(client, bReq);
    defer open62541.UA_delete(
        @ptrCast(@alignCast(c_bResp)),
        open62541.UA_DataType_get(open62541.UA_TYPES_BROWSERESPONSE),
    );
    const bresp: helper.UA_BrowseResponse = .init(c_bResp);
    const bresp_header: helper.UA_ResponseHeader = .init(bresp.response_header);
    try helper.checkStatusCode(bresp_header.service_result);
    for (bresp.results[0..bresp.result_size]) |result| {
        for (result.references[0..result.referencesSize]) |ref| {
            const node_class: helper.UANodeClass = @enumFromInt(ref.nodeClass);
            const id_type: helper.UANodeIdType =
                @enumFromInt(ref.nodeId.nodeId.identifierType);
            var identifier_buf: [128]u8 = undefined;
            std.log.info("{s} (ns={};{s}={s}) -- {t}", .{
                ref.browseName.name.data[0..ref.browseName.name.length],
                ref.nodeId.nodeId.namespaceIndex,
                switch (id_type) {
                    .STRING => "s",
                    .BYTESTRING => "b",
                    .GUID => "g",
                    .NUMERIC => "n",
                    _ => unreachable,
                },
                identifier: {
                    switch (id_type) {
                        .STRING => {
                            const node = ref.nodeId.nodeId.identifier.string;
                            break :identifier try std.fmt.bufPrint(
                                &identifier_buf,
                                "{s}",
                                .{node.data[0..node.length]},
                            );
                        },
                        .BYTESTRING => {
                            const node =
                                ref.nodeId.nodeId.identifier.byteString;
                            break :identifier try std.fmt.bufPrint(
                                &identifier_buf,
                                "{s}",
                                .{node.data[0..node.length]},
                            );
                        },
                        .GUID => {
                            const node =
                                ref.nodeId.nodeId.identifier.guid;
                            break :identifier try std.fmt.bufPrint(
                                &identifier_buf,
                                "{x:0>8}-{x:0>4}-{x:0>4}-{x:0>2}{x:0>2}-{x:0>2}{x:0>2}{x:0>2}{x:0>2}{x:0>2}{x:0>2}",
                                .{
                                    node.data1,
                                    node.data2,
                                    node.data3,
                                    node.data4[0],
                                    node.data4[1],
                                    node.data4[2],
                                    node.data4[3],
                                    node.data4[4],
                                    node.data4[5],
                                    node.data4[6],
                                    node.data4[7],
                                },
                            );
                        },
                        .NUMERIC => {
                            const node = ref.nodeId.nodeId.identifier.numeric;
                            break :identifier try std.fmt.bufPrint(
                                &identifier_buf,
                                "{}",
                                .{node},
                            );
                        },
                        _ => unreachable,
                    }
                },
                node_class,
            });

            if (node_class == .UA_NODECLASS_OBJECT) {
                try browseAddressSpace(client, ref.nodeId.nodeId);
            }
        }
    }
}

/// Read Variant from server and return it.
fn read_attribute(
    client: ?*open62541.UA_Client,
    /// NodeID to be read
    node_id: open62541.UA_NodeId,
) !open62541.UA_Variant {
    var variant: open62541.UA_Variant = .{};
    const code = open62541.UA_Client_readValueAttribute(
        client,
        node_id,
        &variant,
    );
    try helper.checkStatusCode(code);
    return variant;
}

fn writeAttribute(
    client: ?*open62541.UA_Client,
    node_id: open62541.UA_NodeId,
    value: ?*anyopaque,
    size: usize,
    T: ?*const open62541.UA_DataType,
) !void {
    var variant: open62541.UA_Variant = .{};
    open62541.UA_Variant_setArray(&variant, value, size, T);
    try helper.checkStatusCode(
        open62541.UA_Client_writeValueAttribute(client, node_id, &variant),
    );
}
