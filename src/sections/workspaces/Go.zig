const std = @import("std");
const Child = std.process.Child;

const set_color = struct {
    const cyan = "\x1b[36m";
    const normal = "\x1b[39m";
};

const Self = @This();

/// Returns true if "go.mod" is found
pub fn checkRoot(self: Self, dir: std.fs.Dir) bool {
    _ = self;
    if (dir.access(
        "go.mod",
        .{ .mode = .read_only },
    )) |_| return true else |_| return false;
}

/// Caller owns the memory
pub fn init(self: Self, allocator: std.mem.Allocator) ![]const u8 {
    _ = self;

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
