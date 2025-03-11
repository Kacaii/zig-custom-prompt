const std = @import("std");
const fs = std.fs;
const testing = std.testing;
const Child = std.process.Child;
const Allocator = std.mem.Allocator;

const Workspace = @import("./Workspace.zig");

//FIXME:

const set_color = struct {
    const yellow = "\x1b[33m";
    const normal = "\x1b[39m";
};

pub const Zig: Workspace = .{
    .init = init,
    .root_file = "build.zig",
    .tag = .zig,
    .check_root = checkRoot,
};

pub fn checkRoot(self: Workspace.Self, dir: std.fs.Dir) bool {
    if (dir.access(
        self.root_file,
        .{ .mode = .read_only },
    )) |_| return true else |_| return false;
}

fn init(allocator: Allocator) ![]const u8 {
    const zig_version_cmd = Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "zig", "version" },
    }) catch return Workspace.WorkspaceError.OutOfMemory;

    defer allocator.free(zig_version_cmd.stdout);
    defer allocator.free(zig_version_cmd.stderr);

    const zig_version = std.mem.trimRight(u8, zig_version_cmd.stdout, "\n");

    const zig_section = std.mem.concat(
        allocator,
        u8,
        &[_][]const u8{ set_color.yellow, "[ Zig ", zig_version, "]", set_color.normal },
    ) catch return Workspace.WorkspaceError.OutOfMemory;

    return zig_section;
}

test " detect zig root" {
    var tempdir = testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile("build.zig", .{});
    defer temp_file.close();

    try testing.expect(Zig.check_root(Zig, tempdir.dir) == true);
}
