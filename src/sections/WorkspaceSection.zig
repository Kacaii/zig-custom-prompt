const std = @import("std");

const Workspace = @import("./workspaces/Workspace.zig").Workspace;

/// Caller owns the memory
pub fn init(allocator: std.mem.Allocator, dir: std.fs.Dir) ![]const u8 {
    const workspaces = [_]Workspace{
        .{ .zig = .{} },
        .{ .deno = .{} },
        .{ .go = .{} },
        .{ .node = .{} },
    };

    for (workspaces) |ws| {
        if (try ws.checkRoot(allocator, dir)) {
            const section = try ws.init(allocator);
            return section;
        }
    }

    const default_ws = Workspace{ .default = .{} };
    const section = try default_ws.init(allocator);
    return section;
}

// TEST: Update tests! Root directory needs to be a git repository
test " zig workspace" {
    const alloc = std.testing.allocator;

    var tempdir = std.testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile("build.zig", .{});
    defer temp_file.close();

    const ws: Workspace = .{ .zig = .{} };

    const actual = try ws.init(alloc);
    defer alloc.free(actual);

    try std.testing.expect(ws.checkRoot(tempdir.dir));
    try std.testing.expectStringStartsWith(actual, "\x1b[33m");
}

test " deno workspace" {
    const alloc = std.testing.allocator;

    var tempdir = std.testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile("deno.json", .{});
    defer temp_file.close();

    const ws: Workspace = .{ .deno = .{} };

    const actual = try ws.init(alloc);
    defer alloc.free(actual);

    try std.testing.expect(ws.checkRoot(tempdir.dir));
    try std.testing.expectStringStartsWith(actual, "\x1b[32m");
}

test " default workspace" {
    const alloc = std.testing.allocator;

    var tempdir = std.testing.tmpDir(.{});
    defer tempdir.cleanup();

    const ws: Workspace = .{ .default = .{} };
    const actual = try ws.init(alloc);
    defer alloc.free(actual);

    try std.testing.expectEqualStrings("\x1b[95m\x1b[39m", actual);
}

test " go workspace" {
    const alloc = std.testing.allocator;

    var tempdir = std.testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile("go.mod", .{});
    defer temp_file.close();

    const ws: Workspace = .{ .go = .{} };

    const actual = try ws.init(alloc);
    defer alloc.free(actual);

    try std.testing.expect(ws.checkRoot(tempdir.dir));
    try std.testing.expectStringStartsWith(actual, "\x1b[36m");
}

test " node workspace" {
    const alloc = std.testing.allocator;

    var tempdir = std.testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile("package.json", .{});
    defer temp_file.close();

    const ws: Workspace = .{ .node = .{} };

    const actual = try ws.init(alloc);
    defer alloc.free(actual);

    try std.testing.expect(ws.checkRoot(tempdir.dir));
    try std.testing.expectStringStartsWith(actual, "\x1b[32m");
}
