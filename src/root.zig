const std = @import("std");

pub const Workspace = @import("sections/WorkspaceSection/Workspace.zig");

test {
    std.testing.refAllDecls(@This());
}
