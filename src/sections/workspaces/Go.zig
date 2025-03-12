const std = @import("std");
const Child = std.process.Child;

const set_color = struct {
    const cyan = "\x1b[36m";
    const normal = "\x1b[39m";
};

const Self = @This();

/// Returns true if "go.mod" is found
pub fn checkRoot(self: Self, dir: std.fs.Dir) bool {
    _ = self;
    if (dir.access(
        "go.mod",
        .{ .mode = .read_only },
    )) |_| return true else |_| return false;
}

/// Caller owns the memory
pub fn init(self: Self, allocator: std.mem.Allocator) ![]const u8 {
    _ = self;

    const go_version_cmd = try Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "go", "version" },
    });

    defer allocator.free(go_version_cmd.stdout);
    defer allocator.free(go_version_cmd.stderr);

    const go_version = go_version_cmd.stdout[13..17];

    const go_section = try std.mem.concat(
        allocator,
        u8,
        &[_][]const u8{ set_color.cyan, "[ Go ", go_version, "]", set_color.normal },
    );

    return go_section;
}
