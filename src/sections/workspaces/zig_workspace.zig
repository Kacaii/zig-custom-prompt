const std = @import("std");
const fs = std.fs;
const testing = std.testing;

const Child = std.process.Child;
const Allocator = std.mem.Allocator;

const WorkspaceTags = @import("../workspace.zig").WorkspaceTags;

const set_color = struct {
    const yellow = "\x1b[33m";
    const normal = "\x1b[39m";
};

pub const ZigWorkspace = struct {
    pub const tag: WorkspaceTags = .zig;
    const root_file = "build.zig";

    pub fn checkRoot(dir: fs.Dir) bool {
        if (dir.openFile(root_file, .{ .mode = .read_only })) |_| return true else |_| return false;
    }

    /// Caller owns the memory
    pub fn init(allocator: Allocator) ![]const u8 {
        const zig_version_run = try Child.run(.{
            .allocator = allocator,
            .argv = &[_][]const u8{ "zig", "version" },
        });

        defer allocator.free(zig_version_run.stdout);
        defer allocator.free(zig_version_run.stderr);

        const zig_version_output = zig_version_run.stdout;
        const zig_version = std.mem.trimRight(
            u8,
            zig_version_output,
            "\n",
        );

        const zig_section = try std.mem.concat(
            allocator,
            u8,
            &[_][]const u8{
                set_color.yellow,
                "[ Zig ",
                zig_version,
                "]",
                set_color.normal,
            },
        );
        return zig_section;
    }
};

test " detect zig root" {
    var tempdir = testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile(ZigWorkspace.root_file, .{});
    defer temp_file.close();

    try testing.expect(ZigWorkspace.checkRoot(tempdir.dir) == true);
}
