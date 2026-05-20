const std = @import("std");
const opc = @import("zigopc");
const open62541 = opc.c;
const types = @import("types.zig");

pub fn main(_: std.process.Init) !void {
    errdefer {
        if (@errorReturnTrace()) |trace| {
            std.debug.dumpErrorReturnTrace(trace);
        }
    }
    const client = open62541.UA_Client_new();
    defer open62541.UA_Client_delete(client);
    try opc.checkStatusCode(
        open62541.UA_ClientConfig_setDefault(
            open62541.UA_Client_getConfig(client),
        ),
    );
    try opc.checkStatusCode(
        open62541.UA_Client_connect(
            client,
            @constCast("opc.tcp://192.168.250.1:4840"),
        ),
    );
    const config = open62541.UA_Client_getConfig(client);
    var custom_data_types: [*c]open62541.UA_DataTypeArray = null;
    try opc.checkStatusCode(
        open62541.UA_Client_getRemoteDataTypes(
            client,
            0,
            null,
            &custom_data_types,
        ),
    );
    config.*.customDataTypes = custom_data_types;
    const target =
        open62541.UA_NODEID_STRING(4, @constCast("NodeData"));
    for (1..11) |i| {
        const attr = try readAttribute(client, target);
        var node_data: []types.OPCNodeData = &.{};
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
    }
}

/// Read Variant from server and return it.
fn readAttribute(
    client: ?*open62541.UA_Client,
    /// NodeID to be read
    node_id: open62541.UA_NodeId,
) !open62541.UA_Variant {
    var variant = std.mem.zeroInit(open62541.UA_Variant, .{});
    try opc.checkStatusCode(
        open62541.UA_Client_readValueAttribute(client, node_id, &variant),
    );
    return variant;
}

fn writeAttribute(
    client: ?*open62541.UA_Client,
    node_id: open62541.UA_NodeId,
    value: ?*anyopaque,
    size: usize,
    T: ?*const open62541.UA_DataType,
) !void {
    var variant = std.mem.zeroInit(open62541.UA_Variant, .{});
    open62541.UA_Variant_setArray(&variant, value, size, T);
    try opc.checkStatusCode(
        open62541.UA_Client_writeValueAttribute(client, node_id, &variant),
    );
}
