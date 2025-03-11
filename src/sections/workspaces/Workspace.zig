const std = @import("std");
const Allocator = std.mem.Allocator;

const Zig = @import("./Zig.zig").Zig;
const Deno = @import("./Deno.zig").Deno;

pub const Workspace = union(enum) {
    zig: Zig,
    deno: Deno,

    pub fn init(self: Workspace, allocator: Allocator) ![]const u8 {
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
