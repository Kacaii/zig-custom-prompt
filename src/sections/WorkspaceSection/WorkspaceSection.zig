//! This module detects what programming language is being used on the current project.

const std = @import("std");

const Workspace = @import("Workspace.zig").Workspace;

/// Returns the programming language being used on the current project, and its version.
/// Caller owns the memory.
pub fn init(allocator: std.mem.Allocator, dir: std.fs.Dir) ![]const u8 {
    const workspaces = [_]Workspace{
        .{ .zig = .{} },
        .{ .deno = .{} },
        .{ .go = .{} },
        .{ .node = .{} },
        .{ .dot_config = .{} },
        .{ .fish = .{} },
        .{ .nvim = .{} },
        .{ .gleam = .{} },
    };

    // Check for existing workspaces
    for (workspaces) |ws| {
        if (try ws.checkRoot(allocator, dir)) {
            const section = try ws.init(allocator);
            return section;
        }
    }

    // Initialize the default one in case that no workspace is found
    const default_ws = Workspace{ .default = .{} };
    const section = try default_ws.init(allocator);
    return section;
}
