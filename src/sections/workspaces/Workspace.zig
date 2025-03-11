const std = @import("std");
const Allocator = std.mem.Allocator;

const Zig = @import("./ZigWorkspace.zig").Zig;

pub const Workspace = union(enum) {
    zig: Zig,

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

test "Test functionality" {
    const alloc = std.testing.allocator;

    var tempdir = std.testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile("build.zig", .{});
    defer temp_file.close();

    const ws = Workspace{ .zig = Zig{} };
    const actual = try ws.init(alloc);

    defer alloc.free(actual);
    try std.testing.expectStringStartsWith(actual, "\x1b[33m[");
}
