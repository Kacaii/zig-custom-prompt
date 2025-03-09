const std = @import("std");
const Allocator = std.mem.Allocator;

const set_color = struct {
    const blue = "\x1b[34m";
    const normal = "\x1b[39m";
};

/// Returns the path section.
/// Caller owns the memory
pub fn init(allocator: Allocator, dir: std.fs.Dir) ![]const u8 {
    const real_path = try dir.realpathAlloc(allocator, ".");
    defer allocator.free(real_path);

    const parsed_path = try std.mem.replaceOwned(
        u8,
        allocator,
        real_path,
        "/home/kacaii",
        "~",
    );
    defer allocator.free(parsed_path);

    const path = std.mem.concat(
        allocator,
        u8,
        &[_][]const u8{
            set_color.blue,
            parsed_path,
            set_color.normal,
        },
    );

    return path;
}
