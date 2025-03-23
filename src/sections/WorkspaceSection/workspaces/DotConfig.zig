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

/// Returns true if current directory is "/home/user/.config"
pub fn checkRoot(self: Self, allocator: std.mem.Allocator, dir: std.fs.Dir) !bool {
    _ = self;

    const path = dir.realpathAlloc(allocator, ".") catch return false;
    defer allocator.free(path);

    var path_iter = std.mem.splitScalar(u8, path, '/');

    var directories: std.ArrayListUnmanaged([]const u8) = .empty;
    defer directories.deinit(allocator);

    _ = path_iter.first(); // skip first
    while (path_iter.next()) |path_entry| {
        try directories.append(allocator, path_entry);
    }

    const config_directory = directories.items[2];
    const is_config = std.mem.eql(u8, config_directory, root_file);

    return is_config and (directories.items.len == 3);
}
