const std = @import("std");
const Child = std.process.Child;

const GitData = @import("../GitData.zig");

const set_color = struct {
    const green = "\x1b[32m";
    const default = "\x1b[39m";
};

const root_file = "package.json";

const Self = @This();

/// Returns NodeJS's icon and version number.
/// Caller owns the memory
pub fn init(_: Self, allocator: std.mem.Allocator) ![]const u8 {
    const argv = [_][]const u8{ "node", "--version" };
    const node_version_cmd = try Child.run(.{
        .allocator = allocator,
        .argv = &argv,
    });

    defer allocator.free(node_version_cmd.stdout);
    defer allocator.free(node_version_cmd.stderr);

    const version = std.mem.trimRight(u8, node_version_cmd.stdout[1..], "\n");

    const section = std.fmt.allocPrint(
        allocator,
        "{s} {s}{s}",
        .{ set_color.green, version, set_color.default },
    );

    return section;
}

/// Returns true if "package.json" is found
pub fn checkRoot(_: Self, allocator: std.mem.Allocator, dir: std.fs.Dir) !bool {
    var git_data: GitData = undefined;
    try git_data.init(allocator);
    defer git_data.deinit(allocator);

    // Check if "package.json" is found in the current working directory
    if (dir.access(
        root_file,
        .{ .mode = .read_only },
    )) |_| return true else |_| {
        // If the root file isnt in the current working directory,
        // and you are not a git repository, return false.
        if (!git_data.is_repo) return false;

        // Check if "package.json" is found in the current git repository.
        var git_root_dir = try dir.openDir(git_data.root, .{});
        defer git_root_dir.close();

        if (git_root_dir.access(
            root_file,
            .{ .mode = .read_only },
        )) |_| return true else |_| return false;
    }
}
