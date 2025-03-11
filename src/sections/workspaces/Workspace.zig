const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Self = @This();

pub const WorkspaceError = error{ NoRootFound, OutOfMemory };

const Tags = enum {};

root_file: []const u8,
tag: union(enum) { zig, deno, default_workspace },
init: fn (Allocator) WorkspaceError![]const u8,
check_root: fn (self: Self, dir: std.fs.Dir) bool,
