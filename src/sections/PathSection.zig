const std = @import("std");
const Allocator = std.mem.Allocator;

const set_mode = struct {
    const dim = "\x1b[2m";
    const normal = "\x1b[0m";
};

/// Returns the path for the current working directory.
/// Caller owns the memory
pub fn init(allocator: Allocator, dir: std.fs.Dir) ![]const u8 {
    const path = try dir.realpathAlloc(allocator, ".");
    defer allocator.free(path);

    const section = try std.fmt.allocPrint(
        allocator,
        "{s}{s}{s}",
        .{ set_mode.dim, path, set_mode.normal },
    );

    return section;
}
