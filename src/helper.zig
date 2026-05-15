const std = @import("std");
const open62541 = @import("open62541");
const options = @import("options");

pub fn checkStatusCode(code: open62541.UA_StatusCode) Error!void {
    const code_name = open62541.UA_StatusCode_name(code);
    if (open62541.UA_StatusCode_isBad(code)) {
        std.log.err("{s}", .{code_name});
        const ti = @typeInfo(Error).error_set;
        inline for (ti.?) |field| {
            if (std.mem.eql(u8, std.mem.span(code_name), field.name)) {
                return @field(Error, field.name);
            }
        }
        unreachable;
    } else if (open62541.UA_StatusCode_isUncertain(code)) {
        std.log.warn("{s}", .{code_name});
    }
}

pub fn UA_Clear(p: ?*anyopaque, type_idx: usize) void {
    open62541.UA_clear(
        p,
        open62541.UA_DataType_get(type_idx),
    );
}

/// Generated Bad StatusCode from OPC UA as error set
pub const Error = err: {
    var T: type = error{};
    @setEvalBranchQuota(70000);
    const status_code_file = @embedFile("Opc.Ua.StatusCodes.csv");
    var iterator = std.mem.tokenizeAny(u8, status_code_file, "\n");
    while (iterator.next()) |line| {
        // Guaranteed to be found each line.
        const delimiter_idx = std.mem.find(u8, line, ",").?;
        if (std.mem.startsWith(u8, line, "Bad")) {
            T = T || @TypeOf(@field(anyerror, line[0..delimiter_idx]));
        }
    }
    break :err T;
};

pub const UA_BrowseResponse = extern struct {
    response_header: ?*const open62541.UA_ResponseHeader,
    result_size: usize,
    results: [*c]const open62541.UA_BrowseResult,
    diagnostic_infos_size: usize,
    diagnostic_infos: ?*const open62541.UA_DiagnosticInfo,

    /// Translate open62541 BrowseResponse native to zig
    pub fn init(bResp: ?*const open62541.UA_BrowseResponse) UA_BrowseResponse {
        return .{
            .response_header = open62541.UA_BrowseResponse_getHeader(bResp),
            .result_size = open62541.UA_BrowseResponse_getResultsSize(bResp),
            .results = open62541.UA_BrowseResponse_getResults(bResp),
            .diagnostic_infos_size = open62541.UA_BrowseResponse_getDiagnosticInfosSize(bResp),
            .diagnostic_infos = open62541.UA_BrowseResponse_getDiagnosticInfos(bResp),
        };
    }
};

pub const UA_ResponseHeader = extern struct {
    timestamp: open62541.UA_DateTime,
    request_handle: open62541.UA_UInt32,
    service_result: open62541.UA_StatusCode,
    service_diagnostics: ?*const open62541.UA_DiagnosticInfo,
    string_table_size: usize,
    string_table: [*c]const open62541.UA_String,
    additional_header: ?*const open62541.UA_ExtensionObject,

    /// Translate open62541 ResponseHeader native to Zig using C readers
    pub fn init(header: ?*const open62541.UA_ResponseHeader) UA_ResponseHeader {
        return .{
            .timestamp = open62541.UA_ResponseHeader_getTimestamp(header),
            .request_handle = open62541.UA_ResponseHeader_getRequestHandle(header),
            .service_result = open62541.UA_ResponseHeader_getServiceResult(header),
            .service_diagnostics = open62541.UA_ResponseHeader_getServiceDiagnostics(header),
            .string_table_size = open62541.UA_ResponseHeader_getStringTableSize(header),
            .string_table = open62541.UA_ResponseHeader_getStringTable(header),
            .additional_header = open62541.UA_ResponseHeader_getAdditionalHeader(header),
        };
    }
};

pub const UANodeIdType = enum(c_int) {
    NUMERIC = 0,
    STRING = 3,
    GUID = 4,
    BYTESTRING = 5,
    _,
};

pub const UANodeClass = enum(c_int) {
    UA_NODECLASS_UNSPECIFIED = 0,
    UA_NODECLASS_OBJECT = 1,
    UA_NODECLASS_VARIABLE = 2,
    UA_NODECLASS_METHOD = 4,
    UA_NODECLASS_OBJECTTYPE = 8,
    UA_NODECLASS_VARIABLETYPE = 16,
    UA_NODECLASS_REFERENCETYPE = 32,
    UA_NODECLASS_DATATYPE = 64,
    UA_NODECLASS_VIEW = 128,
    __UA_NODECLASS_FORCE32BIT = 0x7fffffff,
};

pub const UADataTypeKind = enum(std.math.IntFittingRange(
    0,
    open62541.UA_DATATYPEKINDS - 1,
)) {
    UA_DATATYPEKIND_BOOLEAN = 0,
    UA_DATATYPEKIND_SBYTE = 1,
    UA_DATATYPEKIND_BYTE = 2,
    UA_DATATYPEKIND_INT16 = 3,
    UA_DATATYPEKIND_UINT16 = 4,
    UA_DATATYPEKIND_INT32 = 5,
    UA_DATATYPEKIND_UINT32 = 6,
    UA_DATATYPEKIND_INT64 = 7,
    UA_DATATYPEKIND_UINT64 = 8,
    UA_DATATYPEKIND_FLOAT = 9,
    UA_DATATYPEKIND_DOUBLE = 10,
    UA_DATATYPEKIND_STRING = 11,
    UA_DATATYPEKIND_DATETIME = 12,
    UA_DATATYPEKIND_GUID = 13,
    UA_DATATYPEKIND_BYTESTRING = 14,
    UA_DATATYPEKIND_XMLELEMENT = 15,
    UA_DATATYPEKIND_NODEID = 16,
    UA_DATATYPEKIND_EXPANDEDNODEID = 17,
    UA_DATATYPEKIND_STATUSCODE = 18,
    UA_DATATYPEKIND_QUALIFIEDNAME = 19,
    UA_DATATYPEKIND_LOCALIZEDTEXT = 20,
    UA_DATATYPEKIND_EXTENSIONOBJECT = 21,
    UA_DATATYPEKIND_DATAVALUE = 22,
    UA_DATATYPEKIND_VARIANT = 23,
    UA_DATATYPEKIND_DIAGNOSTICINFO = 24,
    UA_DATATYPEKIND_DECIMAL = 25,
    UA_DATATYPEKIND_ENUM = 26,
    UA_DATATYPEKIND_STRUCTURE = 27,
    UA_DATATYPEKIND_OPTSTRUCT = 28,
    UA_DATATYPEKIND_UNION = 29,
    UA_DATATYPEKIND_BITFIELDCLUSTER = 30,
    _,
};

pub var NodeDataType: UA_DataType = undefined;

pub const OPCNodeData = extern struct {
    LineNo: open62541.UA_Int16,
    BoardNo: open62541.UA_Int16,
    MotorNo: open62541.UA_Int16,
    IsShuttle: open62541.UA_Int16,
    ConnetLines: [3]open62541.UA_Int16, // ARRAY[0..2] of INT
    CarrierID: open62541.UA_Int16,
    CarrierState: open62541.UA_Int16,
    ConnectCCLink: open62541.UA_Boolean,
    CommandReady: open62541.UA_Boolean,
    StopEnable: open62541.UA_Boolean,
    MotorActive: open62541.UA_Boolean,
    FrontHall: open62541.UA_Boolean,
    BackHall: open62541.UA_Boolean,
    UnderVoltage: open62541.UA_Boolean,
    OverVoltage: open62541.UA_Boolean,
    BeforDriverError: open62541.UA_Boolean,
    AfterDriverError: open62541.UA_Boolean,
    InverterOverheat: open62541.UA_Boolean,
    OverCurrent: open62541.UA_Boolean,
    WaitPull: open62541.UA_Boolean,
    WaitPush: open62541.UA_Boolean,
    Test: open62541.UA_Int16,

    pub fn createDataType() UA_DataType {
        var members: [@typeInfo(OPCNodeData).@"struct".fields.len]UA_DataType.Member =
            undefined;
        const ti = @typeInfo(OPCNodeData).@"struct";
        inline for (ti.fields, 0..) |field, i| {
            members[i] = .{
                .memberName = @constCast(field.name),
                .memberType = typeToDataType(field.type),
                .flags = .{
                    .padding = if (i == 0)
                        0
                    else
                        @bitOffsetOf(OPCNodeData, field.name) -
                            @offsetOf(OPCNodeData, ti.fields[i - 1].name) -
                            @sizeOf(ti.fields[i - 1].type),
                    .isArray = if (@typeInfo(field.type) == .array)
                        true
                    else
                        false,
                    .isOptional = false,
                },
            };
        }
        return .{
            .typeName = 0,
            .typeId = 0,
            .binaryEncodingId = 0,
            .xmlEncodingId = 0,
            .flags = 0,
            .members = 0,
        };
        // members[0] = .{
        //     .memberName = @constCast("LineNo"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = 0,
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[1] = .{
        //     .memberName = @constCast("BoardNo"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @offsetOf(OPCNodeData, "BoardNo") - @offsetOf(OPCNodeData, "LineNo") - @sizeOf(@TypeOf(@field(OPCNodeData, "LineNo"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[2] = .{
        //     .memberName = @constCast("MotorNo"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "MotorNo") -
        //             @offsetOf(OPCNodeData, "BoardNo") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "BoardNo"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[3] = .{
        //     .memberName = @constCast("IsShuttle"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "IsShuttle") -
        //             @offsetOf(OPCNodeData, "MotorNo") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "MotorNo"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[4] = .{
        //     .memberName = @constCast("ConnetLines"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "ConnetLines") -
        //             @offsetOf(OPCNodeData, "IsShuttle") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "IsShuttle"))),
        //         .isArray = true,
        //         .isOptional = false,
        //     },
        // };
        // members[5] = .{
        //     .memberName = @constCast("CarrierID"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "CarrierID") -
        //             @offsetOf(OPCNodeData, "ConnetLines") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "ConnetLines"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[6] = .{
        //     .memberName = @constCast("CarrierState"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "CarrierState") -
        //             @offsetOf(OPCNodeData, "CarrierID") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "CarrierID"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[7] = .{
        //     .memberName = @constCast("ConnectCCLink"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "ConnectCCLink") -
        //             @offsetOf(OPCNodeData, "CarrierState") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "CarrierState"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[8] = .{
        //     .memberName = @constCast("CommandReady"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "CommandReady") -
        //             @offsetOf(OPCNodeData, "ConnectCCLink") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "ConnectCCLink"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[9] = .{
        //     .memberName = @constCast("StopEnable"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "StopEnable") -
        //             @offsetOf(OPCNodeData, "CommandReady") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "CommandReady"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[10] = .{
        //     .memberName = @constCast("MotorActive"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "MotorActive") -
        //             @offsetOf(OPCNodeData, "StopEnable") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "StopEnable"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[11] = .{
        //     .memberName = @constCast("FrontHall"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "FrontHall") -
        //             @offsetOf(OPCNodeData, "MotorActive") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "MotorActive"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[12] = .{
        //     .memberName = @constCast("BackHall"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "BackHall") -
        //             @offsetOf(OPCNodeData, "FrontHall") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "FrontHall"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[13] = .{
        //     .memberName = @constCast("UnderVoltage"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "UnderVoltage") -
        //             @offsetOf(OPCNodeData, "BackHall") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "BackHall"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[14] = .{
        //     .memberName = @constCast("OverVoltage"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "OverVoltage") -
        //             @offsetOf(OPCNodeData, "UnderVoltage") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "UnderVoltage"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[15] = .{
        //     .memberName = @constCast("BeforDriverError"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "BeforDriverError") -
        //             @offsetOf(OPCNodeData, "OverVoltage") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "OverVoltage"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[16] = .{
        //     .memberName = @constCast("AfterDriverError"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "AfterDriverError") -
        //             @offsetOf(OPCNodeData, "BeforDriverError") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "BeforDriverError"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[17] = .{
        //     .memberName = @constCast("InverterOverheat"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "InverterOverheat") -
        //             @offsetOf(OPCNodeData, "AfterDriverError") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "AfterDriverError"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[18] = .{
        //     .memberName = @constCast("OverCurrent"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "OverCurrent") -
        //             @offsetOf(OPCNodeData, "InverterOverheat") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "InverterOverheat"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[19] = .{
        //     .memberName = @constCast("WaitPull"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "WaitPull") -
        //             @offsetOf(OPCNodeData, "OverCurrent") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "OverCurrent"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[20] = .{
        //     .memberName = @constCast("WaitPush"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "WaitPush") -
        //             @offsetOf(OPCNodeData, "WaitPull") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "WaitPull"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
        // members[21] = .{
        //     .memberName = @constCast("Test"),
        //     .memberType = open62541.UA_DataType_get(open62541.UA_TYPES_UINT16),
        //     .flags = .{
        //         .padding = @bitOffsetOf(OPCNodeData, "Test") -
        //             @offsetOf(OPCNodeData, "WaitPush") -
        //             @sizeOf(@TypeOf(@field(OPCNodeData, "WaitPush"))),
        //         .isArray = false,
        //         .isOptional = false,
        //     },
        // };
    }
};

pub const UA_DataType = extern struct {
    typeName: [*]const u8,
    typeId: open62541.UA_NodeId,
    binaryEncodingId: open62541.UA_NodeId,
    xmlEncodingId: open62541.UA_NodeId,
    flags: UA_DataType.Flag,
    members: [*]Member,
    pub const Flag = packed struct(u32) {
        memSize: u16,
        typeKind: u6,
        pointerFree: bool,
        overlayable: bool,
        membersSize: u8,
    };

    pub const Member = extern struct {
        memberName: [*c]const u8,
        memberType: ?*const open62541.UA_DataType,
        flags: Member.Flag,
        pub const Flag = packed struct(u8) {
            padding: u6,
            isArray: bool,
            isOptional: bool,
        };

        pub fn toOpaque(self: *Member) ?*anyopaque {
            return @ptrCast(@alignCast(self));
        }
    };

    pub fn toOpaque(self: *UA_DataType) ?*anyopaque {
        return @ptrCast(@alignCast(self));
    }

    pub fn create(
        T: type,
        name: [:0]const u8,
        type_id: open62541.UA_NodeId,
        binary_encoding_id: open62541.UA_NodeId,
        xml_encoding_id: open62541.UA_NodeId,
        flags: UA_DataType.Flag,
    ) UA_DataType {
        var members: [@typeInfo(T).@"struct".fields.len]UA_DataType.Member =
            undefined;
        const ti = @typeInfo(T).@"struct";
        inline for (ti.fields, 0..) |field, i| {
            // @compileLog(field.name, @offsetOf(T, field.name));
            members[i] = .{
                .memberName = @constCast(field.name),
                .memberType = typeToDataType(field.type),
                .flags = .{
                    .padding = if (i == 0)
                        0
                    else
                        @offsetOf(T, field.name) -
                            @offsetOf(T, ti.fields[i - 1].name) -
                            @sizeOf(ti.fields[i - 1].type),
                    .isArray = if (@typeInfo(field.type) == .array)
                        true
                    else
                        false,
                    .isOptional = false,
                },
            };
            // @compileLog(
            //     if (@typeInfo(field.type) == .array)
            //         true
            //     else
            //         false,
            // );
        }
        return .{
            .typeName = @ptrCast(@constCast(name)),
            .typeId = type_id,
            .binaryEncodingId = binary_encoding_id,
            .xmlEncodingId = xml_encoding_id,
            .flags = flags,
            .members = &members,
        };
    }
};

fn typeToDataType(T: type) ?*const open62541.UA_DataType {
    switch (@typeInfo(T)) {
        .array => |array| {
            return typeToDataType(array.child);
        },
        .int => |int| {
            if (int.bits == 8) {
                switch (int.signedness) {
                    .signed => return open62541.UA_DataType_get(open62541.UA_SByte),
                    .unsigned => return open62541.UA_DataType_get(open62541.UA_Byte),
                }
            } else if (int.bits == 16) {
                switch (int.signedness) {
                    .signed => return open62541.UA_DataType_get(
                        @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_INT16),
                    ),
                    .unsigned => return open62541.UA_DataType_get(
                        @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_UINT16),
                    ),
                }
            } else if (int.bits == 32) {
                switch (int.signedness) {
                    .signed => return open62541.UA_DataType_get(
                        @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_INT32),
                    ),
                    .unsigned => return open62541.UA_DataType_get(
                        @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_UINT32),
                    ),
                }
            } else if (int.bits == 64) {
                switch (int.signedness) {
                    .signed => return open62541.UA_DataType_get(
                        @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_INT64),
                    ),
                    .unsigned => return open62541.UA_DataType_get(
                        @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_UINT64),
                    ),
                }
            } else @compileError(std.fmt.comptimePrint("Unsupported integer type: {}", .{int}));
        },
        .float => |float| {
            if (float.bits == 32)
                return open62541.UA_DataType_get(
                    @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_FLOAT),
                )
            else if (float.bits == 64)
                return open62541.UA_DataType_get(
                    @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_DOUBLE),
                )
            else
                @compileError(std.fmt.comptimePrint(
                    "Unsupported floating type: {}",
                    .{float},
                ));
        },
        .bool => return open62541.UA_DataType_get(
            @intFromEnum(UADataTypeKind.UA_DATATYPEKIND_BOOLEAN),
        ),
        else => |tag| @compileError(
            std.fmt.comptimePrint("Unsupported type: {t}", .{tag}),
        ), // TODO: Support more data type.
    }
}
