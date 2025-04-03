const std = @import("std");
const Child = std.process.Child;

const GitData = @import("../GitData.zig");

const set_color = struct {
    const cyan = "\x1b[36m";
    const normal = "\x1b[39m";
};

const root_file = "go.mod";

const Self = @This();

/// Returns Golang's icon and version number.
/// Caller owns the memory
pub fn init(_: Self, allocator: std.mem.Allocator) ![]const u8 {
    const argv = [_][]const u8{ "go", "version" };
    const go_version_cmd = try Child.run(.{
        .allocator = allocator,
        .argv = &argv,
    });

    defer allocator.free(go_version_cmd.stdout);
    defer allocator.free(go_version_cmd.stderr);

    const version = blk: {
        const needle_index = std.mem.indexOf(u8, go_version_cmd.stdout, "l");

        break :blk go_version_cmd.stdout[13 .. needle_index.? - 1];
    };

    const section = try std.fmt.allocPrint(
        allocator,
        "{s} {s}{s}",
        .{ set_color.cyan, version, set_color.normal },
    );

    return section;
}

/// Returns true if "go.mod" is found in the current directory or git repository.
pub fn checkRoot(self: Self, allocator: std.mem.Allocator, dir: std.fs.Dir) !bool {
    _ = self;

    const git_data = try GitData.init(allocator);
    defer git_data.deinit(allocator);

    // Check if "go.mod" is found in the current working directory
    if (dir.access(
        root_file,
        .{ .mode = .read_only },
    )) |_| return true else |_| {
        // If the root file isnt in the current working directory,
        // and you are not a git repository, return false.
        if (!git_data.is_repo) return false;

        // Check if "deno.json" is found in the current git repository.
        var git_root_dir = try dir.openDir(git_data.root, .{});
        defer git_root_dir.close();

        if (git_root_dir.access(
            root_file,
            .{ .mode = .read_only },
        )) |_| return true else |_| return false;
    }
}
