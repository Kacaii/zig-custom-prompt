//! Wraps information about the current git repository.

const std = @import("std");

/// Wraps information about the current git repository.
const Self = @This();

/// Current working branch.
branch: []const u8,
/// Returns true if the current git repository is dirty.
is_dirty: bool,
/// Returns true if a git repository is detected.
is_repo: bool,
/// Root directory of the current git repository.
/// Returns an empty string if no repository is detected.
root: []const u8,

/// Initializes a GitData struct.
/// Caller owns the memory.
pub fn init(allocator: std.mem.Allocator) !*Self {
    const git_status_arv = [_][]const u8{ "git", "status" };
    const git_status_cmd = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &git_status_arv,
    });

    defer allocator.free(git_status_cmd.stdout);
    defer allocator.free(git_status_cmd.stderr);

    const is_repo = git_status_cmd.term.Exited == 0;

    const branch = blk: {
        if (!is_repo) break :blk "";

        var iter = std.mem.splitScalar(u8, git_status_cmd.stdout, '\n');

        const first_line = iter.first();
        break :blk try allocator.dupe(u8, first_line[10..]);
    };

    const git_root_argv = [_][]const u8{ "git", "rev-parse", "--show-toplevel" };
    const git_root_cmd = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &git_root_argv,
    });

    defer allocator.free(git_root_cmd.stdout);
    defer allocator.free(git_root_cmd.stderr);

    const root = blk: {
        if (!is_repo) break :blk "";
        const parsed = std.mem.trimRight(u8, git_root_cmd.stdout, "\n");
        break :blk try allocator.dupe(u8, parsed);
    };

    const git_dirty_argv = [_][]const u8{ "git", "diff-files", "--quiet" };
    const git_dirty_cmd = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &git_dirty_argv,
    });

    defer allocator.free(git_dirty_cmd.stdout);
    defer allocator.free(git_dirty_cmd.stderr);

    const is_dirty = if (git_dirty_cmd.term.Exited == 1) true else false;

    const git_data = try allocator.create(Self);
    git_data.* = Self{
        .is_repo = is_repo,
        .branch = branch,
        .root = root,
        .is_dirty = is_dirty,
    };

    return git_data;
}

/// Deinitializes a GitData struct.
/// Frees the memory.
pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
    defer allocator.destroy(self);

    allocator.free(self.branch);
    allocator.free(self.root);
}
