const std = @import("std");
const Child = std.process.Child;

const set_color = struct {
    const yellow = "\x1b[33m";
    const normal = "\x1b[39m";
};

const Self = @This();

/// Returns true if "build.zig" is found
pub fn checkRoot(self: Self, dir: std.fs.Dir) bool {
    _ = self;
    if (dir.access(
        "build.zig",
        .{ .mode = .read_only },
    )) |_| return true else |_| return false;
}

/// Caller owns the memory
pub fn init(self: Self, allocator: std.mem.Allocator) ![]const u8 {
    _ = self;

    const zig_version_cmd = try Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "zig", "version" },
    });

    defer allocator.free(zig_version_cmd.stdout);
    defer allocator.free(zig_version_cmd.stderr);

    const zig_version = std.mem.trimRight(u8, zig_version_cmd.stdout, "\n");

    const zig_section = try std.mem.concat(
        allocator,
        u8,
        &[_][]const u8{ set_color.yellow, "[ Zig ", zig_version, "]", set_color.normal },
    );

    return zig_section;
}
