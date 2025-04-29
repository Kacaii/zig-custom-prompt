const std = @import("std");
const Child = std.process.Child;

const GitData = @import("../GitData.zig");

const set_color = struct {
    const magenta = "\x1b[35m";
    const default = "\x1b[39m";
};

const root_file = "gleam.toml";

const Self = @This();

/// Returns Gleam's icon and version number.
/// Caller owns the memory
pub fn init(_: Self, allocator: std.mem.Allocator) ![]const u8 {
    const argv = [_][]const u8{ "gleam", "--version" };
    const version_cmd = try Child.run(.{
        .allocator = allocator,
        .argv = &argv,
    });

    defer allocator.free(version_cmd.stdout);
    defer allocator.free(version_cmd.stderr);

    const stdout = std.mem.trim(u8, version_cmd.stdout, "\n");

    const version_number = stdout[6..];
    const section = try std.fmt.allocPrint(
        allocator,
        "{s} {s}{s}",
        .{ set_color.magenta, version_number, set_color.default },
    );

    return section;
}

/// Returns true if "gleam.toml" is found
pub fn checkRoot(_: Self, allocator: std.mem.Allocator, dir: std.fs.Dir) !bool {
    var git_data: GitData = undefined;
    try git_data.init(allocator);
    defer git_data.deinit(allocator);

    // Check if "gleam.toml" is found in the current working directory
    if (dir.access(
        root_file,
        .{ .mode = .read_only },
    )) |_| return true else |_| {
        // If the root file isnt in the current working directory,
        // and you are not a git repository, return false.
        if (!git_data.is_repo) return false;

        // Check if "gleam.toml" is found in the current git repository.
        var git_root_dir = try dir.openDir(git_data.root, .{});
        defer git_root_dir.close();

        if (git_root_dir.access(
            root_file,
            .{ .mode = .read_only },
        )) |_| return true else |_| return false;
    }
}
