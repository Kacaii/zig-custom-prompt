//! This module is an interface that handles
//! detecting what language you are using for your project.

const std = @import("std");

const Default = @import("./Default.zig");
const Deno = @import("./Deno.zig");
const Go = @import("./Go.zig");
const Node = @import("./NodeJS.zig");
const Zig = @import("./Zig.zig");

pub const Workspace = union(enum) {
    default: Default,
    deno: Deno,
    go: Go,
    node: Node,
    zig: Zig,

    pub fn init(self: Workspace, allocator: std.mem.Allocator) ![]const u8 {
        switch (self) {
            inline else => |w| return w.init(allocator),
        }
    }

    pub fn checkRoot(self: Workspace, dir: std.fs.Dir) bool {
        switch (self) {
            inline else => |w| return w.checkRoot(dir),
        }
    }
};
