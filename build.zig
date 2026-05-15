const std = @import("std");

const Translator = @import("translate_c").Translator;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // const translate_c = b.dependency("translate_c", .{});
    // const open62541 = buildLibOpen62541(b, target, optimize);
    // const opc_statuscode_path = b.option([]const u8, "status-code-path", "OPC UA StatusCode source file path.") orelse "vendor/Opc.Ua.StatusCodes.csv";

    // const trans_open62541: Translator = .init(translate_c, .{
    //     .c_source_file = b.addWriteFiles().add("c.h",
    //         \\#include <open62541.h>
    //         \\#include <OPC_types_helper.h>
    //     ),
    //     .target = target,
    //     .optimize = optimize,
    // });
    // trans_open62541.linkLibrary(open62541);
    // std.log.debug("Generated zig file path: {s}", .{trans_open62541.output_file.generated.sub_path});
    // const install_step = b.getInstallStep();
    // const install_file = b.addInstallFile(trans_open62541.output_file, "generated.zig");
    // install_step.dependOn(&install_file.step);

    const open62541_mod = b.addModule("open62541", .{
        .root_source_file = b.path("src/open62541_generated.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    open62541_mod.addCSourceFiles(.{
        .root = b.path("vendor"),
        .files = &.{ "open62541.c", "OPC_types_helper.c" },
        .flags = &.{"-fno-sanitize=undefined"},
    });
    // open62541_mod.addLibraryPath(b.path("vendor"));
    // open62541_mod.linkSystemLibrary("open62541", .{
    //     .needed = true,
    //     .preferred_link_mode = .static,
    // });
    // open62541_mod.addObjectFile(b.path("vendor/libopen62541.a"));
    // const open62541 = b.addLibrary(.{
    //     .name = "open62541",
    //     .linkage = .static,
    //     .root_module = open62541_mod,
    // });
    // b.installArtifact(open62541);
    // open62541_mod.addLibraryPath(b.path("vendor"));
    // const options = b.addOptions();
    // options.addOption([]const u8, "status_code_absolute_path", opc_statuscode_path);
    // options.addOption(?[]const u8, "build_path", b.build_root.path);
    const server = b.createModule(.{
        .root_source_file = b.path("src/server.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "open62541", .module = open62541_mod },
        },
    });
    // server.addOptions("options", options);
    // server.addObjectFile(b.path("vendor/libopen62541.a"));
    const client = b.createModule(.{
        .root_source_file = b.path("src/client.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "open62541", .module = open62541_mod },
        },
    });
    // client.addOptions("options", options);
    // server.addObjectFile(b.path("vendor/libopen62541.a"));
    // client.addObjectFile(b.path("vendor/libopen62541.a"));
    const server_exe = b.addExecutable(
        .{ .name = "server", .root_module = server },
    );
    const client_exe = b.addExecutable(
        .{ .name = "client", .root_module = client },
    );
    // server_exe.root_module.linkLibrary(open62541);
    b.installArtifact(server_exe);
    b.installArtifact(client_exe);
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
        .root = b.path("vendor"),
        .files = &.{ "open62541.c", "OPC_types_helper.c" },
        .flags = &.{"-fno-sanitize=undefined"},
    });
    const lib = b.addLibrary(.{
        .name = "open62541",
        .root_module = mod,
    });
    // Install the headers, so that linking this library makes those headers available.
    lib.installHeader(b.path("vendor/open62541.h"), "open62541.h");
    lib.installHeader(b.path("vendor/OPC_types_helper.h"), "OPC_types_helper.h");
    return lib;
}

fn buildOPCTypesHelper(
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
    mod.addCSourceFile(.{ .file = b.path("vendor/open62541.c") });
    const lib = b.addLibrary(.{
        .name = "open62541",
        .root_module = mod,
    });
    // Install the headers, so that linking this library makes those headers available.
    lib.installHeader(b.path("vendor/open62541.h"), "open62541.h");
    return lib;
}
