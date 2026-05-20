const opc = @import("zigopc");
const open62541 = opc.c;
const std = @import("std");

pub const OPCNodeData = extern struct {
    LineNo: open62541.UA_Int16,
    BoardNo: open62541.UA_Int16,
    MotorNo: open62541.UA_Int16,
    IsShuttle: open62541.UA_Int16,
    ConnetLines: Slice(open62541.UA_Int16), // ARRAY[0..2] of INT
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

    fn Slice(T: type) type {
        return @Struct(
            .@"extern",
            null,
            &.{ "len", "ptr" },
            &.{ usize, [*]allowzero T },
            &.{ .{}, .{} },
        );
    }

    pub fn format(
        self: @This(),
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        std.debug.assert(@typeInfo(@TypeOf(self)) == .@"struct");
        try writer.writeAll("\nOPC Node Data: .{\n");
        const ti = @typeInfo(@TypeOf(self)).@"struct";
        inline for (ti.fields) |field| {
            try writer.writeAll("    ");
            const field_ti = @typeInfo(field.type);
            switch (field_ti) {
                .bool, .int, .float => {
                    try writer.print(
                        "{s}: {},\n",
                        .{ field.name, @field(self, field.name) },
                    );
                },
                .@"enum" => {
                    try writer.print(
                        "{s}: {t},\n",
                        .{ field.name, @field(self, field.name) },
                    );
                },
                .@"struct" => {
                    if (@hasField(field.type, "ptr") and
                        @hasField(field.type, "len"))
                    {
                        const slice = @field(self, field.name);
                        const ptr = @field(slice, "ptr");
                        const len = @field(slice, "len");
                        try writer.print("{s}: {{", .{field.name});
                        for (0..len) |i| {
                            if (i == len - 1) {
                                try writer.print("{}}},", .{ptr[i]});
                            } else {
                                try writer.print("{}, ", .{ptr[i]});
                            }
                        }
                    } else {
                        @compileError("Unsupported printing format.");
                    }
                    try writer.writeByte('\n');
                },
                else => unreachable,
            }
        }
        try writer.writeAll("}");
    }
};
