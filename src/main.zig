const std = @import("std");
const fs = std.fs;
const Child = std.process.Child;
const builtin = @import("builtin");

const HostSection = @import("./sections/HostSection.zig");
const PathSection = @import("./sections/PathSection.zig");
const GitSection = @import("./sections/WorkspaceSection/GitSection.zig");
const WorkspaceSection = @import("./sections/WorkspaceSection/WorkspaceSection.zig");
const ArrowSection = @import("./sections/ArrowSection.zig");

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

    // Host name
    const host_section = HostSection.init(allocator) catch "";
    defer allocator.free(host_section);

    // Icon and Programming Language
    const workspace_section = WorkspaceSection.init(allocator, cwd) catch "";
    defer allocator.free(workspace_section);

    // Git Branch
    const git_section = GitSection.init(allocator) catch "";
    defer allocator.free(git_section);

    // Path
    const path_section = PathSection.init(allocator, cwd) catch "";
    defer allocator.free(path_section);

    const arrow_section = try ArrowSection.init(allocator);
    defer allocator.free(arrow_section);

    _ = try stdout.print(
        " {s} | {s} {s}{s} \n {s} ",
        .{
            host_section,
            workspace_section,
            git_section,
            path_section,
            arrow_section,
        },
    );
}
