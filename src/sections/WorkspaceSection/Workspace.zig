//! This module is an interface that handles
//! detecting what language you are using for your project.

const std = @import("std");

const Default = @import("./workspaces/Default.zig");
const Deno = @import("./workspaces/Deno.zig");
const Go = @import("./workspaces/Go.zig");
const Node = @import("./workspaces/NodeJS.zig");
const Zig = @import("./workspaces/Zig.zig");

pub const Workspace = union(enum) {
    default: Default,
    deno: Deno,
    go: Go,
    node: Node,
    zig: Zig,

    /// Returns the programming language being used on the current project, and its version.
    pub fn init(self: Workspace, allocator: std.mem.Allocator) ![]const u8 {
        switch (self) {
            inline else => |w| return w.init(allocator),
        }
    }

    /// Returns true if a root file of any of the workspaces is detected.
    pub fn checkRoot(self: Workspace, allocator: std.mem.Allocator, dir: std.fs.Dir) !bool {
        switch (self) {
            inline else => |w| return w.checkRoot(allocator, dir),
        }
    }
};
