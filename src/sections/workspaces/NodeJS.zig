const std = @import("std");
const Child = std.process.Child;

const set_color = struct {
    const green = "\x1b[32m";
    const normal = "\x1b[39m";
};

const Self = @This();

/// Returns true if "package.json" is found
pub fn checkRoot(self: Self, dir: std.fs.Dir) bool {
    _ = self;
    if (dir.access(
        "package.json",
        .{ .mode = .read_only },
    )) |_| return true else |_| return false;
}

/// Caller owns the memory
pub fn init(self: Self, allocator: std.mem.Allocator) ![]const u8 {
    _ = self;

    const node_version_cmd = try Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "node", "--version" },
    });

    defer allocator.free(node_version_cmd.stdout);
    defer allocator.free(node_version_cmd.stderr);

    const node_version = std.mem.trimRight(u8, node_version_cmd.stdout, "\n");

    const node_section = try std.mem.concat(
        allocator,
        u8,
        &[_][]const u8{ set_color.green, "[ NodeJS ", node_version, "]", set_color.normal },
    );

    return node_section;
}
