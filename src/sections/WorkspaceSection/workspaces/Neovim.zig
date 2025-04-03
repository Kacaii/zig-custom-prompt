const std = @import("std");
const Child = std.process.Child;

const set_color = struct {
    const green = "\x1b[32m";
    const normal = "\x1b[39m";
};

const root_file = "nvim";

const Self = @This();

/// Returns Neovim's icon and version number.
/// Caller owns the memory
pub fn init(_: Self, allocator: std.mem.Allocator) ![]const u8 {
    const argv = [_][]const u8{ "nvim", "--version" };
    const nvim_version_cmd = try Child.run(.{
        .allocator = allocator,
        .argv = &argv,
    });

    defer allocator.free(nvim_version_cmd.stdout);
    defer allocator.free(nvim_version_cmd.stderr);

    const version = blk: {
        var iter = std.mem.tokenizeScalar(u8, nvim_version_cmd.stdout, '\n');
        const first_line = iter.next().?;

        const parsed_first_line = std.mem.trimRight(u8, first_line, "\n");
        break :blk parsed_first_line;
    };

    const section = try std.fmt.allocPrint(
        allocator,
        "{s} {s}{s}",
        .{ set_color.green, version[6..], set_color.normal },
    );

    return section;
}

/// Returns true if current directory is "/home/user/.config/nvim"
pub fn checkRoot(self: Self, allocator: std.mem.Allocator, dir: std.fs.Dir) !bool {
    _ = self;

    const path = dir.realpathAlloc(allocator, ".") catch return false;
    defer allocator.free(path);

    var path_iter = std.mem.tokenizeScalar(u8, path, '/');

    var directories: std.ArrayListUnmanaged([]const u8) = .empty;
    defer directories.deinit(allocator);

    while (path_iter.next()) |path_entry| {
        try directories.append(allocator, path_entry);
    }

    const nvim_directory = directories.items[3];
    const is_nvim_config = std.mem.eql(u8, nvim_directory, root_file);

    return is_nvim_config;
}
