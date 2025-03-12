const std = @import("std");
const Child = std.process.Child;

const set_color = struct {
    const magenta = "\x1b[95m";
    const normal = "\x1b[39m";
};

const Self = @This();

pub fn checkRoot(self: Self, dir: std.fs.Dir) bool {
    _ = self;
    _ = dir;

    return true;
}

/// Caller owns the memory
pub fn init(self: Self, allocator: std.mem.Allocator) ![]const u8 {
    _ = self;

    const default_section = std.mem.concat(
        allocator,
        u8,
        &[_][]const u8{ set_color.magenta, "[]", set_color.normal },
    );

    return default_section;
}
