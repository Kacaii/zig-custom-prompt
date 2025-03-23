const std = @import("std");
const Child = std.process.Child;

const set_color = struct {
    const blue = "\x1b[34m";
    const normal = "\x1b[39m";
};

const root_file = ".config";

const Self = @This();

/// Caller owns the memory
pub fn init(self: Self, allocator: std.mem.Allocator) ![]const u8 {
    _ = self;

    const section = try std.fmt.allocPrint(allocator, "{s}{s}", .{
        set_color.blue,
        set_color.normal,
    });
    return section;
}

/// Returns true if current directory is ".config"
pub fn checkRoot(self: Self, allocator: std.mem.Allocator, dir: std.fs.Dir) !bool {
    _ = self;

    const path = dir.realpathAlloc(allocator, ".") catch return false;
    defer allocator.free(path);

    var path_iter = std.mem.splitScalar(u8, path, '/');

    // /
    _ = path_iter.first();

    // /home/
    _ = path_iter.next();

    // /home/user/
    _ = path_iter.next();

    // /home/user/.config/
    const config_directory = path_iter.next().?;
    const is_config = std.mem.eql(u8, config_directory, root_file);

    // Checks if ".config" is the last entry in the path
    const next_entry = path_iter.next();

    return is_config and (next_entry == null);
}
