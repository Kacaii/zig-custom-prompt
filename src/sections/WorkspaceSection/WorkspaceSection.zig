const std = @import("std");

const Workspace = @import("./Workspace.zig").Workspace;

/// Detects what programming language is being used on the current project.
/// Caller owns the memory
pub fn init(allocator: std.mem.Allocator, dir: std.fs.Dir) ![]const u8 {
    const workspaces = [_]Workspace{
        .{ .zig = .{} },
        .{ .deno = .{} },
        .{ .go = .{} },
        .{ .node = .{} },
    };

    for (workspaces) |ws| {
        if (try ws.checkRoot(allocator, dir)) {
            const section = try ws.init(allocator);
            return section;
        }
    }

    const default_ws = Workspace{ .default = .{} };
    const section = try default_ws.init(allocator);
    return section;
}

// TEST: Update tests! Root directory needs to be a git repository
test " detect deno workspace" {}
