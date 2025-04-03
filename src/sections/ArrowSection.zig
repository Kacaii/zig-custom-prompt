const std = @import("std");

const set_color = struct {
    const green = "\x1b[32m";
    const default = "\x1b[39m";
};

pub fn init(allocator: std.mem.Allocator) ![]const u8 {
    return try std.fmt.allocPrint(
        allocator,
        "{s}${s}",
        .{ set_color.green, set_color.default },
    );
}
