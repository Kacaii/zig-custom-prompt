const std = @import("std");
const Child = std.process.Child;

const GitData = @import("../GitSection.zig").GitData;

const set_color = struct {
    const yellow = "\x1b[33m";
    const normal = "\x1b[39m";
};

const Self = @This();

/// Returns true if "build.zig" is found
pub fn checkRoot(self: Self, allocator: std.mem.Allocator, dir: std.fs.Dir) !bool {
    _ = self;

    const git_data = try GitData.init(allocator);
    defer git_data.deinit(allocator);

    if (!git_data.is_repo) return false;

    var git_root_dir = try dir.openDir(git_data.root, .{});
    defer git_root_dir.close();

    if (git_root_dir.access(
        "build.zig",
        .{ .mode = .read_only },
    )) |_| return true else |_| return false;
}

/// Caller owns the memory
pub fn init(self: Self, allocator: std.mem.Allocator) ![]const u8 {
    _ = self;

    const argv = [_][]const u8{ "zig", "version" };
    const zig_version_cmd = try Child.run(.{
        .allocator = allocator,
        .argv = &argv,
    });

    defer allocator.free(zig_version_cmd.stdout);
    defer allocator.free(zig_version_cmd.stderr);

    const version = std.mem.trimRight(u8, zig_version_cmd.stdout, "\n");

    const section = try std.fmt.allocPrint(
        allocator,
        "{s} {s}{s}",
        .{ set_color.yellow, version, set_color.normal },
    );

    return section;
}
