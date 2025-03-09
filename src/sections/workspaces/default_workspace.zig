const std = @import("std");
const fs = std.fs;
const testing = std.testing;

const Child = std.process.Child;
const Allocator = std.mem.Allocator;

const set_color = struct {
    const magenta = "\x1b[95m";
    const normal = "\x1b[39m";
};

pub const DefaultWorkspace = struct {
    /// Caller owns the memory
    pub fn init(allocator: Allocator) ![]const u8 {
        const default_section = std.mem.concat(
            allocator,
            u8,
            &[_][]const u8{ set_color.magenta, "[]", set_color.normal },
        );

        return default_section;
    }
};

test " print correct information" {
    var alloc = testing.allocator;

    var tempdir = testing.tmpDir(.{});
    defer tempdir.cleanup();

    const output = try DefaultWorkspace.init(alloc);
    defer alloc.free(output);

    try testing.expectEqualStrings("\x1b[95m[]\x1b[39m", output);
}
