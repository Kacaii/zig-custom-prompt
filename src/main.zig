const std = @import("std");
const fs = std.fs;
const builtin = @import("builtin");
const Child = std.process.Child;

const Workspace = @import("./sections/Workspace.zig");

pub fn main() !void {
    const cwd = fs.cwd();
    const stdout = std.io.getStdOut().writer();

    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const allocator, const is_debug = switch (builtin.mode) {
        .Debug, .ReleaseSafe => .{ debug_allocator.allocator(), true },
        .ReleaseFast, .ReleaseSmall => .{ std.heap.smp_allocator, false },
    };

    defer if (is_debug) {
        _ = debug_allocator.deinit();
    };

    const workspace_section = try Workspace.init(allocator, cwd);
    defer allocator.free(workspace_section);

    _ = try stdout.print(" {s} \n 󰁕 ", .{workspace_section});
}
