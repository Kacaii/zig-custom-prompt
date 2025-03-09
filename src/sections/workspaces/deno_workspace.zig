const std = @import("std");
const fs = std.fs;
const testing = std.testing;

const Child = std.process.Child;
const Allocator = std.mem.Allocator;

const WorkspaceTags = @import("../workspace.zig").WorkspaceTags;

const set_color = struct {
    const green = "\x1b[32m";
    const normal = "\x1b[39m";
};

pub const DenoWorkspace = struct {
    pub const tag: WorkspaceTags = .deno;
    const root_file = "deno.json";

    pub fn checkRoot(dir: std.fs.Dir) bool {
        if (dir.openFile(root_file, .{ .mode = .read_only })) |_| return true else |_| return false;
    }
};

pub fn init(allocator: Allocator) ![]const u8 {}

test " detect deno root" {
    var tempdir = testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile(DenoWorkspace.root_file, .{});
    defer temp_file.close();

    try testing.expect(DenoWorkspace.checkRoot(tempdir.dir) == true);
}
