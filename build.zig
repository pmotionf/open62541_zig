const std = @import("std");

const Translator = @import("translate_c").Translator;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const build_examples = b.option(
        bool,
        "build_example",
        "Build working OPC UA examples in zig",
    ) orelse false;

    const translate_c = b.dependency("translate_c", .{});
    const open62541 = buildLibOpen62541(b, target, optimize);

    const trans_open62541: Translator = .init(translate_c, .{
        .c_source_file = b.addWriteFiles().add("c.h",
            \\#include <open62541.h>
            \\#include <OPC_types_helper.h>
        ),
        .target = target,
        .optimize = optimize,
    });
    trans_open62541.linkLibrary(open62541);

    const zigopc = b.addModule("zigopc", .{
        .root_source_file = b.path("src/opc.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "open62541", .module = trans_open62541.mod },
        },
    });
    if (build_examples) {
        const server = b.createModule(.{
            .root_source_file = b.path("examples/server.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zigopc", .module = zigopc },
            },
        });
        const client = b.createModule(.{
            .root_source_file = b.path("examples/client.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zigopc", .module = zigopc },
            },
        });
        const plc_client = b.createModule(.{
            .root_source_file = b.path("examples/PLC_client.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zigopc", .module = zigopc },
            },
        });
        const server_exe = b.addExecutable(
            .{ .name = "server", .root_module = server },
        );
        const client_exe = b.addExecutable(
            .{ .name = "client", .root_module = client },
        );
        const plc_client_exe = b.addExecutable(
            .{ .name = "plc_client", .root_module = plc_client },
        );
        b.installArtifact(server_exe);
        b.installArtifact(client_exe);
        b.installArtifact(plc_client_exe);
    }
}

fn buildLibOpen62541(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    // mod.addObjectFile(b.path("vendor/libopen62541.a"));
    mod.addCSourceFiles(.{
        .root = b.path("deps"),
        .files = &.{ "open62541.c", "OPC_types_helper.c" },
        // Required to ignore memory bugs in open62541
        .flags = &.{"-fno-sanitize=undefined"},
    });
    const lib = b.addLibrary(.{
        .name = "open62541",
        .root_module = mod,
    });
    // Install the headers, so that linking this library makes those headers available.
    lib.installHeader(
        b.path("deps/open62541.h"),
        "open62541.h",
    );
    lib.installHeader(
        b.path("deps/OPC_types_helper.h"),
        "OPC_types_helper.h",
    );
    return lib;
}
