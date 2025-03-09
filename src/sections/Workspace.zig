const std = @import("std");
const fs = std.fs;
const testing = std.testing;

const ZigWorkspace = @import("./workspaces/zig_workspace.zig").ZigWorkspace;
const DenoWorkspace = @import("./workspaces/deno_workspace.zig").DenoWorkspace;
const DefaultWorkspace = @import("./workspaces/default_workspace.zig").DefaultWorkspace;

const Allocator = std.mem.Allocator;

pub const Tags = enum {
    zig,
    deno,
    default_workspace,
};

/// Caller owns the memory
pub fn init(allocator: Allocator, dir: fs.Dir) ![]const u8 {
    const workspace_tag: Tags = tag: {
        if (ZigWorkspace.checkRoot(dir)) break :tag .zig;
        if (DenoWorkspace.checkRoot(dir)) break :tag .deno;

        break :tag .default_workspace;
    };

    const workspace = try switch (workspace_tag) {
        .zig => ZigWorkspace.init(allocator),
        .deno => DenoWorkspace.init(allocator),
        .default_workspace => DefaultWorkspace.init(allocator),
    };

    return workspace;
}
