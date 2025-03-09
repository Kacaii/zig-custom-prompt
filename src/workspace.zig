const std = @import("std");
const fs = std.fs;

const Allocator = std.mem.Allocator;

const WorkspaceTag = union(enum) {
    deno,
    zig,
    not_workspace,
};

pub const WorkspaceError = std.process.Child.RunError | std.fs.File.OpenError | Allocator.Error;

pub const Workspace = struct {
    root: []const u8,
    color: []const u8,
    tag: WorkspaceTag,
    init_fn: fn (Allocator) WorkspaceError![]const u8,
};
