const std = @import("std");
const Child = std.process.Child;

const set_color = struct {
    const blue = "\x1b[34m";
    const default = "\x1b[39m";
};

const root_file = ".config";

const Self = @This();

/// Returns the .config icon
/// Caller owns the memory
pub fn init(_: Self, allocator: std.mem.Allocator) ![]const u8 {
    const section = try std.fmt.allocPrint(allocator, "{s}{s}", .{
        set_color.blue,
        set_color.default,
    });
    return section;
}

/// Returns true if current directory is "/home/user/.config"
pub fn checkRoot(_: Self, allocator: std.mem.Allocator, dir: std.fs.Dir) !bool {
    const path = dir.realpathAlloc(allocator, ".") catch return false;
    defer allocator.free(path);

    var path_iter = std.mem.tokenizeScalar(u8, path, '/');

    var directories: std.ArrayListUnmanaged([]const u8) = .empty;
    defer directories.deinit(allocator);

    while (path_iter.next()) |path_entry| {
        try directories.append(allocator, path_entry);
    }

    const config_directory = directories.items[2];
    const is_config = std.mem.eql(u8, config_directory, root_file);

    return is_config and (directories.items.len == 3);
}
