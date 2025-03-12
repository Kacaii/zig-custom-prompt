//! This module is an interface that handles
//! detecting what language you are using for your project.

const std = @import("std");

const Default = @import("./Default.zig");
const Deno = @import("./Deno.zig");
const Go = @import("./Go.zig");
const Node = @import("./NodeJS.zig");
const Zig = @import("./Zig.zig");

pub const Workspace = union(enum) {
    default: Default,
    deno: Deno,
    go: Go,
    node: Node,
    zig: Zig,

    pub fn init(self: Workspace, allocator: std.mem.Allocator) ![]const u8 {
        switch (self) {
            inline else => |w| return w.init(allocator),
        }
    }

    pub fn checkRoot(self: Workspace, dir: std.fs.Dir) bool {
        switch (self) {
            inline else => |w| return w.checkRoot(dir),
        }
    }
};

test " zig workspace" {
    const alloc = std.testing.allocator;

    var tempdir = std.testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile("build.zig", .{});
    defer temp_file.close();

    const ws: Workspace = .{ .zig = Zig{} };

    const actual = try ws.init(alloc);
    defer alloc.free(actual);

    try std.testing.expect(ws.checkRoot(tempdir.dir));
    try std.testing.expectStringStartsWith(actual, "\x1b[33m[");
}

test " deno workspace" {
    const alloc = std.testing.allocator;

    var tempdir = std.testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile("deno.json", .{});
    defer temp_file.close();

    const ws: Workspace = .{ .deno = Deno{} };

    const actual = try ws.init(alloc);
    defer alloc.free(actual);

    try std.testing.expect(ws.checkRoot(tempdir.dir));
    try std.testing.expectStringStartsWith(actual, "\x1b[32m[");
}

test " default workspace" {
    const alloc = std.testing.allocator;

    var tempdir = std.testing.tmpDir(.{});
    defer tempdir.cleanup();

    const ws: Workspace = .{ .default = Default{} };
    const actual = try ws.init(alloc);
    defer alloc.free(actual);

    try std.testing.expectEqualStrings("\x1b[95m[]\x1b[39m", actual);
}

test " go workspace" {
    const alloc = std.testing.allocator;

    var tempdir = std.testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile("go.mod", .{});
    defer temp_file.close();

    const ws: Workspace = .{ .go = Go{} };

    const actual = try ws.init(alloc);
    defer alloc.free(actual);

    try std.testing.expect(ws.checkRoot(tempdir.dir));
    try std.testing.expectStringStartsWith(actual, "\x1b[36m[");
}

test " node workspace" {
    const alloc = std.testing.allocator;

    var tempdir = std.testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile("package.json", .{});
    defer temp_file.close();

    const ws: Workspace = .{ .node = Node{} };

    const actual = try ws.init(alloc);
    defer alloc.free(actual);

    try std.testing.expect(ws.checkRoot(tempdir.dir));
    try std.testing.expectStringStartsWith(actual, "\x1b[32m[");
}
