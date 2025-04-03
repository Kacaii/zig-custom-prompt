//! This module returns the current git branch and dirty status.

const std = @import("std");
const Allocator = std.mem.Allocator;

const GitData = @import("./GitData.zig");

/// Used for colorizing the output
const set_color = struct {
    const red = "\x1b[31m";
    const default = "\x1b[39m";
};

/// Returns the branch name and current git dirty status.
/// Returns an empty string if no repository is detected.
/// Caller owns the memory
pub fn init(allocator: Allocator) ![]const u8 {
    var git_data: GitData = undefined;
    try git_data.init(allocator);
    defer git_data.deinit(allocator);

    if (!git_data.is_repo) return "";

    const is_dirty = if (git_data.is_dirty) "*" else "";

    const section = try std.fmt.allocPrint(
        allocator,
        "on {s}{s} {s}{s}{s} ",
        .{ set_color.red, "", git_data.branch, is_dirty, set_color.default },
    );

    return section;
}
