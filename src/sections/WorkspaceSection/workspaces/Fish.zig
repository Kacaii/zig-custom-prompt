const std = @import("std");
const Child = std.process.Child;

const set_color = struct {
    const green = "\x1b[32m";
    const normal = "\x1b[39m";
};

const root_file = "fish";

const Self = @This();

/// Returns Fish Shell's icon and version number.
/// Caller owns the memory
pub fn init(_: Self, allocator: std.mem.Allocator) ![]const u8 {
    const argv = [_][]const u8{ "fish", "--version" };
    const fish_version_cmd = try Child.run(.{
        .allocator = allocator,
        .argv = &argv,
    });

    defer allocator.free(fish_version_cmd.stdout);
    defer allocator.free(fish_version_cmd.stderr);

    const stdout = std.mem.trimRight(u8, fish_version_cmd.stdout, "\n");

    const section = try std.fmt.allocPrint(
        allocator,
        "{s} {s}{s}",
        .{ set_color.green, stdout[14..], set_color.normal },
    );

    return section;
}

/// Returns true if current directory is "/home/user/.config/fish"
pub fn checkRoot(_: Self, allocator: std.mem.Allocator, dir: std.fs.Dir) !bool {
    const path = dir.realpathAlloc(allocator, ".") catch return false;
    defer allocator.free(path);

    var path_iter = std.mem.tokenizeScalar(u8, path, '/');

    var directories: std.ArrayListUnmanaged([]const u8) = .empty;
    defer directories.deinit(allocator);

    while (path_iter.next()) |path_entry| {
        try directories.append(allocator, path_entry);
    }

    const fish_directory = directories.items[3];
    const is_fish_config = std.mem.eql(u8, fish_directory, root_file);

    return is_fish_config;
}
