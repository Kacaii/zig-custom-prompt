//! Wraps information about the current git repository.

const std = @import("std");

/// Wraps information about the current git repository.
const Self = @This();

/// Returns the name of the current working branch.
branch: []const u8,
/// Returns true if the current git repository is dirty.
is_dirty: bool,
/// Returns true if a git repository is detected.
is_repo: bool,
/// Root directory of the current git repository.
/// Returns an empty string if no repository is detected.
root: []const u8,

/// Initializes a GitData struct using in-place initialization.
/// Caller owns the memory.
pub fn init(self: *Self, allocator: std.mem.Allocator) !void {
    const is_repo = isRepo(allocator) catch false;
    const branch = getBranch(allocator) catch "";
    const root = getRoot(allocator) catch "";
    const is_dirty = isDirty(allocator) catch false;

    self.* = Self{
        .is_repo = is_repo,
        .branch = branch,
        .root = root,
        .is_dirty = is_dirty,
    };
}

/// Free allocated resources from a GitData struct.
pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
    allocator.free(self.branch);
    allocator.free(self.root);
}

/// Returns whether the user is currently in a Git Repository
fn isRepo(allocator: std.mem.Allocator) !bool {
    const git_status_arv = [_][]const u8{ "git", "status" };
    const git_status_cmd = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &git_status_arv,
    });

    defer allocator.free(git_status_cmd.stdout);
    defer allocator.free(git_status_cmd.stderr);

    return git_status_cmd.term.Exited == 0;
}

/// Returns the current Git Branch, or an empty string if no root is detected.
/// Caller owns the memory.
fn getBranch(allocator: std.mem.Allocator) ![]const u8 {
    if (!try isRepo(allocator)) return "";

    const git_status_arv = [_][]const u8{ "git", "status" };
    const git_status_cmd = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &git_status_arv,
    });

    defer allocator.free(git_status_cmd.stdout);
    defer allocator.free(git_status_cmd.stderr);

    var iter = std.mem.tokenizeScalar(u8, git_status_cmd.stdout, '\n');

    const first_line = iter.next().?;
    return try allocator.dupe(u8, first_line[10..]);
}

/// Returns the root of the current Git Repository, or an empty string if no root is detected.
/// Caller owns the memory
fn getRoot(allocator: std.mem.Allocator) ![]const u8 {
    if (!try isRepo(allocator)) return "";

    const git_root_argv = [_][]const u8{ "git", "rev-parse", "--show-toplevel" };
    const git_root_cmd = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &git_root_argv,
    });

    defer allocator.free(git_root_cmd.stdout);
    defer allocator.free(git_root_cmd.stderr);

    const parsed = std.mem.trimRight(u8, git_root_cmd.stdout, "\n");
    return try allocator.dupe(u8, parsed);
}

/// Returns wheter the current Git Repository is dirty.
fn isDirty(allocator: std.mem.Allocator) !bool {
    const git_dirty_argv = [_][]const u8{ "git", "diff-files", "--quiet" };
    const git_dirty_cmd = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &git_dirty_argv,
    });

    defer allocator.free(git_dirty_cmd.stdout);
    defer allocator.free(git_dirty_cmd.stderr);

    return if (git_dirty_cmd.term.Exited == 1) true else false;
}
