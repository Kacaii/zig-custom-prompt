const std = @import("std");

const Workspace = @import("./workspaces/Workspace.zig").Workspace;
const Zig = @import("./workspaces/Zig.zig");
const Deno = @import("./workspaces/Deno.zig");
const Default = @import("./workspaces/Default.zig");

/// Caller owns the memory
pub fn init(allocator: std.mem.Allocator, dir: std.fs.Dir) ![]const u8 {
    const workspaces = [_]Workspace{
        .{ .zig = Zig{} },
        .{ .deno = Deno{} },
    };

    for (workspaces) |ws| {
        if (ws.checkRoot(dir)) {
            const section = try ws.init(allocator);
            return section;
        }
    }

    const default_ws = Workspace{ .default = Default{} };
    const section = try default_ws.init(allocator);
    return section;
}
