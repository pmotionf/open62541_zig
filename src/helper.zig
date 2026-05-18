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

pub const CustomDataTypes = struct {
    types: []UA_DataType.Extern,

    pub fn init(gpa: std.mem.Allocator, size: usize) !CustomDataTypes {
        return .{ .types = try gpa.alloc(UA_DataType.Extern, size) };
    }

    pub fn deinit(self: CustomDataTypes, gpa: std.mem.Allocator) void {
        gpa.free(self.types);
    }
};

pub const OPCNodeData = extern struct {
    LineNo: open62541.UA_Int16,
    BoardNo: open62541.UA_Int16,
    MotorNo: open62541.UA_Int16,
    IsShuttle: open62541.UA_Int16,
    // ConnetLines: [3]open62541.UA_Int16, // ARRAY[0..2] of INT
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
};

pub const UA_DataType = struct {
    typeName: []const u8,
    typeId: open62541.UA_NodeId,
    binaryEncodingId: open62541.UA_NodeId,
    xmlEncodingId: open62541.UA_NodeId,
    flags: UA_DataType.Flag,
    members: []Member,

    pub const Extern = extern struct {
        typeName: [*]const u8,
        typeId: open62541.UA_NodeId,
        binaryEncodingId: open62541.UA_NodeId,
        xmlEncodingId: open62541.UA_NodeId,
        flags: UA_DataType.Flag,
        members: [*c]Member,

        pub fn init(data_type: UA_DataType) Extern {
            return .{
                .typeName = data_type.typeName.ptr,
                .typeId = data_type.typeId,
                .binaryEncodingId = data_type.binaryEncodingId,
                .xmlEncodingId = data_type.xmlEncodingId,
                .flags = data_type.flags,
                .members = data_type.members.ptr,
            };
        }
    };

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

    pub const Extended = struct {
        data_type: UA_DataType,
        extern_data_type: UA_DataType.Extern,

        pub fn init(
            gpa: std.mem.Allocator,
            T: type,
            name: [:0]const u8,
            type_id: open62541.UA_NodeId,
            binary_encoding_id: open62541.UA_NodeId,
            xml_encoding_id: open62541.UA_NodeId,
            flags: Flag,
        ) !Extended {
            const data_type: UA_DataType = try .init(
                gpa,
                T,
                name,
                type_id,
                binary_encoding_id,
                xml_encoding_id,
                flags,
            );
            return .{
                .data_type = data_type,
                .extern_data_type = .init(data_type),
            };
        }

        pub fn deinit(self: Extended, gpa: std.mem.Allocator) void {
            self.data_type.deinit(gpa);
        }
    };

    pub fn toExtern(self: *UA_DataType) Extern {
        return .{
            .typeName = self.typeName.ptr,
            .typeId = self.typeId,
            .binaryEncodingId = self.binaryEncodingId,
            .xmlEncodingId = self.xmlEncodingId,
            .flags = self.flags,
            .members = self.members.ptr,
        };
    }

    pub fn init(
        gpa: std.mem.Allocator,
        T: type,
        name: [:0]const u8,
        type_id: open62541.UA_NodeId,
        binary_encoding_id: open62541.UA_NodeId,
        xml_encoding_id: open62541.UA_NodeId,
        flags: UA_DataType.Flag,
    ) !UA_DataType {
        const ti = @typeInfo(T).@"struct";
        var members = try gpa.alloc(UA_DataType.Member, ti.fields.len);
        errdefer gpa.free(members);
        inline for (ti.fields, 0..) |field, i| {
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
        }
        return .{
            .typeName = try gpa.dupe(u8, name),
            .typeId = type_id,
            .binaryEncodingId = binary_encoding_id,
            .xmlEncodingId = xml_encoding_id,
            .flags = flags,
            .members = members,
        };
    }

    pub fn deinit(self: UA_DataType, gpa: std.mem.Allocator) void {
        gpa.free(self.typeName);
        gpa.free(self.members);
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
