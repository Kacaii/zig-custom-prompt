const std = @import("std");
const fs = std.fs;
const builtin = @import("builtin");
const Child = std.process.Child;

const WorkspaceSection = @import("./sections/WorkspaceSection.zig");
const PathSection = @import("./sections/PathSection.zig");

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

    // Path
    const path_section = try PathSection.init(allocator, cwd);
    defer allocator.free(path_section);

    // Icon and Programming Language
    const workspace_section = try WorkspaceSection.init(allocator, cwd);
    defer allocator.free(workspace_section);

    _ = try stdout.print(" {s} │ {s} \n 󰁕 ", .{ path_section, workspace_section });
}
