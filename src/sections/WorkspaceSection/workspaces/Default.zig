const std = @import("std");
const Child = std.process.Child;

const GitData = @import("../GitData.zig");

const set_color = struct {
    const magenta = "\x1b[95m";
    const normal = "\x1b[39m";
};

const Self = @This();

/// Returns the default workspace's icon ""
/// Caller owns the memory
pub fn init(self: Self, allocator: std.mem.Allocator) ![]const u8 {
    _ = self;

    const default_section = std.fmt.allocPrint(
        allocator,
        "{s}{s}{s}",
        .{ set_color.magenta, "", set_color.normal },
    );

    return default_section;
}

/// Always returns true, doest allocate anything.
pub fn checkRoot(self: Self, allocator: std.mem.Allocator, dir: std.fs.Dir) bool {
    _ = self;
    _ = allocator;
    _ = dir;

    return true;
}
