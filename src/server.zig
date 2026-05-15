const std = @import("std");
const open62541 = @import("open62541");
const helper = @import("helper.zig");

pub fn main(init: std.process.Init) !void {
    _ = init;
    errdefer {
        if (@errorReturnTrace()) |trace| {
            std.debug.dumpErrorReturnTrace(trace);
        }
    }
    const server = open62541.UA_Server_new();
    defer {
        _ = open62541.UA_Server_delete(server);
        std.log.info("Server deleted properly", .{});
    }
    try simulatePLCInformationModel(server);
    _addVariable(server);
    // var new_value: u32 = 43;
    // writeVariable(server, &new_value);
    const code = open62541.UA_Server_runUntilInterrupt(server);
    if (open62541.UA_StatusCode_isGood(code) == false) {
        std.log.err("{s}", .{open62541.UA_StatusCode_name(code)});
    }

    {
        var variant: open62541.UA_Variant = .{};
        const code_ = open62541.UA_Server_readValue(
            server,
            open62541.UA_NODEID_STRING(1, @constCast("OPC_Node_Data")),
            &variant,
        );
        try helper.checkStatusCode(code_);
        std.log.debug(
            "{}",
            .{@as(*helper.OPCNodeData, @ptrCast(@alignCast(variant.data)))},
        );
    }
}

fn _addVariable(server: ?*open62541.struct_UA_Server) void {
    var attr = open62541.UA_VariableAttributes_default;
    var my_int: u32 = 42;
    const variant_type = open62541.UA_DataType_get(open62541.UA_TYPES_INT32);
    open62541.UA_Variant_setScalar(&attr.value, &my_int, variant_type);
    attr.description = open62541.UA_LOCALIZEDTEXT(@constCast("en-us"), @constCast("the answer"));
    attr.displayName = open62541.UA_LOCALIZEDTEXT(@constCast("en-us"), @constCast("the answer"));
    attr.dataType = open62541.UA_DataType_get_typeId(variant_type.?).*;
    attr.accessLevel = open62541.UA_ACCESSLEVELMASK_READ |
        open62541.UA_ACCESSLEVELMASK_WRITE;

    const my_int_node_id = open62541.UA_NODEID_STRING(1, @constCast("the.answer"));
    const my_int_name = open62541.UA_QUALIFIEDNAME(1, @constCast("the answer"));
    const parent_node_id = open62541.UA_NODEID_NUMERIC(
        0,
        open62541.UA_NS0ID_OBJECTSFOLDER,
    );
    const parent_reference_node_id = open62541.UA_NODEID_NUMERIC(
        0,
        open62541.UA_NS0ID_ORGANIZES,
    );
    const type_def = open62541.UA_NODEID_NUMERIC(
        0,
        open62541.UA_NS0ID_BASEDATAVARIABLETYPE,
    );
    const code = open62541.UA_Server_addVariableNode(
        server,
        my_int_node_id,
        parent_node_id,
        parent_reference_node_id,
        my_int_name,
        type_def,
        attr,
        null,
        null,
    );
    if (open62541.UA_StatusCode_isBad(code)) {
        std.log.err("{s}", .{open62541.UA_StatusCode_name(code)});
    } else if (open62541.UA_StatusCode_isUncertain(code)) {
        std.log.warn("{s}", .{open62541.UA_StatusCode_name(code)});
    }
}

fn writeVariable(server: ?*open62541.struct_UA_Server, val: *u32) void {
    const my_int_node_id = open62541.UA_NODEID_STRING(1, @constCast("the.answer"));
    var my_var: open62541.UA_Variant = undefined;
    const variant_type = open62541.UA_DataType_get(open62541.UA_TYPES_INT32);
    open62541.UA_Variant_setScalar(&my_var, val, variant_type);
    const code = open62541.UA_Server_writeValue(server, my_int_node_id, my_var);
    if (open62541.UA_StatusCode_isBad(code)) {
        std.log.err("{s}", .{open62541.UA_StatusCode_name(code)});
    } else if (open62541.UA_StatusCode_isUncertain(code)) {
        std.log.warn("{s}", .{open62541.UA_StatusCode_name(code)});
    }
}

fn simulatePLCInformationModel(server: ?*open62541.UA_Server) !void {
    const ns_idx = 1;
    // Add Dummy Data Type
    const dummy_data_type = try addDataType(
        server,
        ns_idx,
        helper.OPCNodeData,
        "OPC_Node_Data_Type",
        "OPC Node Data Type",
        open62541.UA_NODEID_NUMERIC(0, open62541.UA_NS0ID_STRUCTURE),
        open62541.UA_NODEID_NUMERIC(0, open62541.UA_NS0ID_HASSUBTYPE),
    );
    // const config = open62541.UA_Server_getConfig(server);
    // var customDataTypes: open62541.UA_DataTypeArray = .{
    //     .next = config.*.customDataTypes,
    //     .typesSize = 1,
    //     .types = @ptrCast(@alignCast(&dummy_data_type)),
    //     .cleanup = false,
    // };
    // config.*.customDataTypes = &customDataTypes;
    // Add Dummy variable type node
    const dummy_variable_type_node = try addVariableType(
        server,
        ns_idx,
        helper.OPCNodeData,
        dummy_data_type,
        "OPC_Node_Data_Variable_Type",
        "OPC Node Data",
        open62541.UA_NODEID_NUMERIC(0, open62541.UA_NS0ID_BASEDATAVARIABLETYPE),
        open62541.UA_NODEID_NUMERIC(0, open62541.UA_NS0ID_HASSUBTYPE),
        open62541.UA_NODEID_NUMERIC(0, open62541.UA_NS0ID_BASEDATAVARIABLETYPE),
    );
    // Add new_Controller_0 object into Object folder
    const controller_node = try addObject(
        server,
        ns_idx,
        "new_Controller_0",
        "new_Controller_0",
        open62541.UA_NODEID_NUMERIC(0, open62541.UA_NS0ID_OBJECTSFOLDER),
        open62541.UA_NODEID_NUMERIC(0, open62541.UA_NS0ID_ORGANIZES),
        open62541.UA_NODEID_NUMERIC(0, open62541.UA_NS0ID_BASEOBJECTTYPE),
    );
    // Add GlobalVars object into new_Controller_0 folder
    const global_vars_node = try addObject(
        server,
        ns_idx,
        "GlobalVars",
        "GlobalVars",
        controller_node,
        open62541.UA_NODEID_NUMERIC(0, open62541.UA_NS0ID_HASCOMPONENT),
        open62541.UA_NODEID_NUMERIC(0, open62541.UA_NS0ID_BASEOBJECTTYPE),
    );
    // Add dummy variable node
    var init_val = std.mem.zeroInit(
        helper.OPCNodeData,
        .{
            .LineNo = 10,
            .IsShuttle = 10,
            .OverCurrent = true,
            .Test = 10,
        },
    );
    const var_node = try addVariable(
        server,
        ns_idx,
        helper.OPCNodeData,
        &init_val,
        dummy_data_type,
        "OPC_Node_Data",
        "OPC Node Data",
        global_vars_node,
        open62541.UA_NODEID_NUMERIC(0, open62541.UA_NS0ID_HASCOMPONENT),
        dummy_variable_type_node,
    );
    var variant: open62541.UA_Variant = .{};
    const code = open62541.UA_Server_readValue(server, var_node, &variant);
    try helper.checkStatusCode(code);
    std.log.debug(
        "{}",
        .{@as(*helper.OPCNodeData, @ptrCast(@alignCast(variant.data)))},
    );
}

/// Create data type that can be easily used for creating variable in server.
/// When using the returning data type, the data type must be converted to
/// opaque type.
fn addDataType(
    server: ?*open62541.UA_Server,
    ns_idx: open62541.UA_UInt16,
    T: type,
    node_identifier_string: []const u8,
    node_display_name: []const u8,
    parent_node_id: open62541.UA_NodeId,
    parent_reference_node_id: open62541.UA_NodeId,
) !helper.UA_DataType {
    if (@typeInfo(T) != .@"struct") @compileError("Type must be struct");
    const res: helper.UA_DataType = .create(
        T,
        "OPC Node Data",
        open62541.UA_NODEID_STRING(
            ns_idx,
            @ptrCast(@constCast(node_identifier_string)),
        ),
        open62541.UA_NODEID_STRING(ns_idx, @constCast("OPC_Node_Data_Binary")),
        open62541.UA_NODEID_STRING(ns_idx, @constCast("OPC_Node_Data_XML")),
        .{
            .memSize = @sizeOf(T),
            .typeKind = open62541.UA_DATATYPEKIND_STRUCTURE,
            .pointerFree = true,
            .overlayable = false,
            .membersSize = @typeInfo(T).@"struct".fields.len,
        },
    );
    var attr = open62541.UA_DataTypeAttributes_default;
    attr.displayName = open62541.UA_LOCALIZEDTEXT(
        @constCast("en-US"),
        @ptrCast(@constCast(node_display_name)),
    );

    const code = open62541.UA_Server_addDataTypeNode(
        server,
        res.typeId,
        parent_node_id,
        parent_reference_node_id,
        open62541.UA_QUALIFIEDNAME(ns_idx, @ptrCast(@constCast(node_display_name))),
        attr,
        null,
        null,
    );
    try helper.checkStatusCode(code);
    return res;
}

/// Add variable type node to the server and return the resulting node.
fn addVariableType(
    server: ?*open62541.UA_Server,
    ns_idx: open62541.UA_UInt16,
    T: type,
    data_type: helper.UA_DataType,
    node_identifier_string: []const u8,
    node_display_name: []const u8,
    parent_node_id: open62541.UA_NodeId,
    parent_reference_node_id: open62541.UA_NodeId,
    type_definition_node_id: open62541.UA_NodeId,
) !open62541.UA_NodeId {
    if (@typeInfo(T) != .@"struct") @compileError("Type must be struct");
    const res = open62541.UA_NODEID_STRING(
        ns_idx,
        @ptrCast(@constCast(node_identifier_string)),
    );
    var attr = open62541.UA_VariableTypeAttributes_default;
    attr.displayName = open62541.UA_LOCALIZEDTEXT(
        @constCast("en-us"),
        @ptrCast(@constCast(node_display_name)),
    );
    attr.dataType = data_type.typeId;
    attr.valueRank = open62541.UA_VALUERANK_SCALAR;
    var zero_val = std.mem.zeroInit(T, .{});
    open62541.UA_Variant_setScalar(
        &attr.value,
        @ptrCast(&zero_val),
        @ptrCast(@alignCast(&data_type)),
    );

    const code = open62541.UA_Server_addVariableTypeNode(
        server,
        res,
        parent_node_id,
        parent_reference_node_id,
        open62541.UA_QUALIFIEDNAME(ns_idx, @ptrCast(@constCast(node_display_name))),
        type_definition_node_id,
        attr,
        null,
        null,
    );
    try helper.checkStatusCode(code);
    return res;
}

/// Add variable node to the server and return the resulting node.
fn addVariable(
    server: ?*open62541.UA_Server,
    ns_idx: open62541.UA_UInt16,
    T: type,
    val: *T,
    data_type: helper.UA_DataType,
    node_identifier_string: []const u8,
    node_display_name: []const u8,
    parent_node_id: open62541.UA_NodeId,
    parent_reference_node_id: open62541.UA_NodeId,
    type_definition_node_id: open62541.UA_NodeId,
) !open62541.UA_NodeId {
    if (@typeInfo(T) != .@"struct") @compileError("Type must be struct");
    const res = open62541.UA_NODEID_STRING(
        ns_idx,
        @ptrCast(@constCast(node_identifier_string)),
    );
    var attr = open62541.UA_VariableAttributes_default;
    attr.displayName = open62541.UA_LOCALIZEDTEXT(
        @constCast("en-us"),
        @ptrCast(@constCast(node_display_name)),
    );
    attr.dataType = data_type.typeId;
    attr.valueRank = open62541.UA_VALUERANK_SCALAR;
    open62541.UA_Variant_setScalar(
        &attr.value,
        @ptrCast(@alignCast(val)),
        @ptrCast(@alignCast(&data_type)),
    );

    const code = open62541.UA_Server_addVariableNode(
        server,
        res,
        parent_node_id,
        parent_reference_node_id,
        open62541.UA_QUALIFIEDNAME(ns_idx, @ptrCast(@constCast(node_display_name))),
        type_definition_node_id,
        attr,
        null,
        null,
    );
    try helper.checkStatusCode(code);
    return res;
}

// Add object node to the server and return the resulting node.
fn addObject(
    server: ?*open62541.UA_Server,
    ns_idx: open62541.UA_UInt16,
    node_identifier_string: []const u8,
    node_display_name: []const u8,
    parent_node_id: open62541.UA_NodeId,
    parent_reference_node_id: open62541.UA_NodeId,
    type_definition_node_id: open62541.UA_NodeId,
) !open62541.UA_NodeId {
    const res = open62541.UA_NODEID_STRING(
        ns_idx,
        @ptrCast(@constCast(node_identifier_string)),
    );
    var attr = open62541.UA_ObjectAttributes_default;
    attr.displayName = open62541.UA_LOCALIZEDTEXT(
        @constCast("en-us"),
        @ptrCast(@constCast(node_display_name)),
    );

    const code = open62541.UA_Server_addObjectNode(
        server,
        res,
        parent_node_id,
        parent_reference_node_id,
        open62541.UA_QUALIFIEDNAME(ns_idx, @ptrCast(@constCast(node_display_name))),
        type_definition_node_id,
        attr,
        null,
        null,
    );
    try helper.checkStatusCode(code);
    return res;
}
