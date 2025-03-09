const std = @import("std");
const fs = std.fs;
const testing = std.testing;

const Child = std.process.Child;
const Allocator = std.mem.Allocator;

const set_color = struct {
    const green = "\x1b[32m";
    const normal = "\x1b[39m";
};

pub const DenoWorkspace = struct {
    const root_file = "deno.json";

    pub fn checkRoot(dir: fs.Dir) bool {
        if (dir.openFile(root_file, .{ .mode = .read_only })) |_| return true else |_| return false;
    }

    /// Caller owns the memory
    pub fn init(allocator: Allocator) ![]const u8 {
        const deno_version_cmd = try Child.run(.{
            .allocator = allocator,
            .argv = &[_][]const u8{ "deno", "--version" },
        });

        defer allocator.free(deno_version_cmd.stdout);
        defer allocator.free(deno_version_cmd.stderr);

        const deno_version_first_line = std.mem.trimRight(u8, deno_version_cmd.stdout, "\n");
        const index_of_parenthesis = std.mem.indexOf(u8, deno_version_first_line, "(");
        const deno_version = deno_version_first_line[0 .. index_of_parenthesis.? - 1];

        const deno_section = try std.mem.concat(
            allocator,
            u8,
            &[_][]const u8{ set_color.green, "[ ", deno_version, "]", set_color.normal },
        );

        return deno_section;
    }
};

test " detect deno root" {
    var tempdir = testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile(DenoWorkspace.root_file, .{});
    defer temp_file.close();

    try testing.expect(DenoWorkspace.checkRoot(tempdir.dir) == true);
}

test " print correct information" {
    var alloc = testing.allocator;

    var tempdir = testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile(DenoWorkspace.root_file, .{});
    defer temp_file.close();

    const output = try DenoWorkspace.init(alloc);
    defer alloc.free(output);

    // HACK: This needs to be updated manually
    try testing.expectEqualStrings("\x1b[32m[ deno 2.1.10]\x1b[39m", output);
}
