const std = @import("std");

const Workspace = @import("./workspaces/Workspace.zig").Workspace;

/// Caller owns the memory
pub fn init(allocator: std.mem.Allocator, dir: std.fs.Dir) ![]const u8 {
    const workspaces = [_]Workspace{
        .{ .zig = .{} },
        .{ .deno = .{} },
        .{ .go = .{} },
        .{ .node = .{} },
    };

    for (workspaces) |ws| {
        if (ws.checkRoot(dir)) {
            const section = try ws.init(allocator);
            return section;
        }
    }

    const default_ws = Workspace{ .default = .{} };
    const section = try default_ws.init(allocator);
    return section;
}
