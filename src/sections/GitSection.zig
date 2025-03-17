const std = @import("std");
const Allocator = std.mem.Allocator;

const set_color = struct {
    const red = "\x1b[31m";
    const normal = "\x1b[39m";
};

// Caller owns the memory
pub fn init(allocator: Allocator) ![]const u8 {
    if (!try isGitRepo(allocator)) return "";

    const section = try std.fmt.allocPrint(
        allocator,
        "on {s}{s}{s}",
        .{ set_color.red, "", set_color.normal },
    );

    return section;
}

fn isGitRepo(allocator: Allocator) !bool {
    const argv = [_][]const u8{ "git", "status" };
    const git_status_cmd = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &argv,
    });

    defer allocator.free(git_status_cmd.stdout);
    defer allocator.free(git_status_cmd.stderr);

    return switch (git_status_cmd.term.Exited) {
        0 => true, // Everything is working
        else => false,
    };
}

// TODO: Detect git branch
// TODO: Detect git dirty
// TODO: Add tests
