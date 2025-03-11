const std = @import("std");
const Child = std.process.Child;
const Allocator = std.mem.Allocator;

const set_color = struct {
    const yellow = "\x1b[33m";
    const normal = "\x1b[39m";
};

pub const Zig = struct {
    const root_file = "build.zig";

    pub fn checkRoot(self: Zig, dir: std.fs.Dir) bool {
        if (dir.access(self.root_file, .{ .mode = .read_only })) |_| return true else |_| return false;
    }

    pub fn init(self: Zig, allocator: Allocator) ![]const u8 {
        _ = self;

        const zig_version_cmd = try Child.run(.{
            .allocator = allocator,
            .argv = &[_][]const u8{ "zig", "version" },
        });

        defer allocator.free(zig_version_cmd.stdout);
        defer allocator.free(zig_version_cmd.stderr);

        const zig_version = std.mem.trimRight(u8, zig_version_cmd.stdout, "\n");

        const zig_section = try std.mem.concat(
            allocator,
            u8,
            &[_][]const u8{ set_color.yellow, "[ Zig ", zig_version, "]", set_color.normal },
        );

        return zig_section;
    }
};
