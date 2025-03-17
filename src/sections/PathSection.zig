const std = @import("std");
const Allocator = std.mem.Allocator;

const set_color = struct {
    const dim = "\x1b[2m";
    const normal = "\x1b[39m";
};

/// Returns the path for the current working directory.
/// Caller owns the memory
pub fn init(allocator: Allocator, dir: std.fs.Dir) ![]const u8 {
    const path = try dir.realpathAlloc(allocator, ".");
    defer allocator.free(path);

    const section = try std.fmt.allocPrint(
        allocator,
        "{s}{s}{s}",
        .{ set_color.dim, path, set_color.normal },
    );

    return section;
}
