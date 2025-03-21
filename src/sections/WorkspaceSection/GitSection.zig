//! This module returns the current git branch and dirty status.

const std = @import("std");
const Allocator = std.mem.Allocator;

const GitData = @import("./GitData.zig");

/// Used for colorizing the output
const set_color = struct {
    const red = "\x1b[31m";
    const normal = "\x1b[39m";
};

/// Returns the branch name and current git dirty status.
/// Returns an empty string if no repository is detected.
/// Caller owns the memory
pub fn init(allocator: Allocator) ![]const u8 {
    const git_status = try GitData.init(allocator);
    defer git_status.deinit(allocator);

    if (!git_status.is_repo) return "";

    const is_dirty = if (git_status.is_dirty) "*" else "";

    const section = try std.fmt.allocPrint(
        allocator,
        "on {s}{s} {s}{s}{s} ",
        .{ set_color.red, "", git_status.branch, is_dirty, set_color.normal },
    );

    return section;
}
