const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    b.installArtifact(b.addStaticLibrary(.{
        .name = "bonk",
        .root_source_file = .{ .path = "src/lib.zig" },
        .target = target,
        .optimize = .ReleaseFast,
    }));
}
