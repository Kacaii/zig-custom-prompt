const std = @import("std");
const Child = std.process.Child;

const set_color = struct {
    const green = "\x1b[32m";
    const normal = "\x1b[39m";
};

const Self = @This();

/// Returns true if "deno.json" is found
pub fn checkRoot(self: Self, dir: std.fs.Dir) bool {
    _ = self;
    if (dir.access(
        "deno.json",
        .{ .mode = .read_only },
    )) |_| return true else |_| return false;
}

/// Caller owns the memory
pub fn init(self: Self, allocator: std.mem.Allocator) ![]const u8 {
    _ = self;

    const deno_version_cmd = try Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "deno", "--version" },
    });

    defer allocator.free(deno_version_cmd.stdout);
    defer allocator.free(deno_version_cmd.stderr);

    const deno_version_first_line = std.mem.trimRight(u8, deno_version_cmd.stdout, "\n");
    const needle_index = std.mem.indexOf(u8, deno_version_first_line, "(");
    const deno_version = deno_version_first_line[0 .. needle_index.? - 1];

    const deno_section = try std.mem.concat(
        allocator,
        u8,
        &[_][]const u8{ set_color.green, "[ ", deno_version, "]", set_color.normal },
    );

    return deno_section;
}
