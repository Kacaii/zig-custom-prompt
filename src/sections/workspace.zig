const std = @import("std");
const fs = std.fs;
const testing = std.testing;

const ZigWorkspace = @import("./workspaces/zig_workspace.zig").ZigWorkspace;
const DenoWorkspace = @import("./workspaces/deno_workspace.zig").DenoWorkspace;

const Allocator = std.mem.Allocator;

pub const WorkspaceTags = enum {
    zig,
    deno,
    default_workspace,
};

pub fn getWorkspace(dir: fs.Dir) WorkspaceTags {
    if (ZigWorkspace.checkRoot(dir)) return .zig;
    if (DenoWorkspace.checkRoot(dir)) return .deno;

    return .not_workspace;
}

test getWorkspace {
    var tempdir = testing.tmpDir(.{});
    defer tempdir.cleanup();

    const temp_file = try tempdir.dir.createFile("build.zig", .{});
    defer temp_file.close();

    try testing.expect(getWorkspace(tempdir.dir) == .zig);
}

/// Caller owns the memory
pub fn init(allocator: Allocator, w: WorkspaceTags) ![]const u8 {
    const workspace = try switch (w) {
        .zig => ZigWorkspace.init(allocator),
        .deno => DenoWorkspace.init(allocator),

        // FIXME: Make a default Workspace so it doesnt break when there is nothing to allocate.
        .default_workspace => "",
    };

    return workspace;
}
