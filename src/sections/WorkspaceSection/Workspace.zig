//! This module is an interface that handles the detection of
//! the programming language being used on the current project.

const std = @import("std");

const Default = @import("./workspaces/Default.zig");
const Deno = @import("./workspaces/Deno.zig");
const Go = @import("./workspaces/Go.zig");
const Node = @import("./workspaces/NodeJS.zig");
const Zig = @import("./workspaces/Zig.zig");

pub const Workspace = union(enum) {
    default: Default,
    deno: Deno,
    go: Go,
    node: Node,
    zig: Zig,

    /// Returns the programming language being used on the current project, and its version.
    /// Caller owns the memory.
    pub fn init(self: Workspace, allocator: std.mem.Allocator) ![]const u8 {
        switch (self) {
            inline else => |w| return w.init(allocator),
        }
    }

    /// Returns true if a root file of any of the workspaces is detected.
    pub fn checkRoot(self: Workspace, allocator: std.mem.Allocator, dir: std.fs.Dir) !bool {
        switch (self) {
            inline else => |w| return w.checkRoot(allocator, dir),
        }
    }
};

test Workspace {
    const allocator = std.testing.allocator;
    var tmp_dir = std.testing.tmpDir(.{});
    defer tmp_dir.cleanup();

    const path = try tmp_dir.dir.realpathAlloc(allocator, ".");
    defer allocator.free(path);

    var argv = [_][]const u8{ "git", "init" };
    const git_init_cmd = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &argv,
        .cwd = path,
    });

    defer allocator.free(git_init_cmd.stdout);
    defer allocator.free(git_init_cmd.stderr);

    _ = try tmp_dir.dir.createFile("deno.json", .{ .read = true });
    const ws = Workspace{ .deno = .{} };

    try std.testing.expect(try ws.checkRoot(allocator, tmp_dir.dir));

    const expected = "\x1b[32m";
    const actual = try ws.init(allocator);
    defer allocator.free(actual);

    try std.testing.expectStringStartsWith(actual, expected);
}
