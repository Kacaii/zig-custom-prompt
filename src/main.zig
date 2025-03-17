const std = @import("std");
const fs = std.fs;
const Child = std.process.Child;
const builtin = @import("builtin");

const HostSection = @import("./sections/HostSection.zig");
const PathSection = @import("./sections/PathSection.zig");
const WorkspaceSection = @import("./sections/WorkspaceSection.zig");
const GitSection = @import("./sections/GitSection.zig");

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
    const host_section = try HostSection.init(allocator);
    defer allocator.free(host_section);

    // Icon and Programming Language
    const workspace_section = try WorkspaceSection.init(allocator, cwd);
    defer allocator.free(workspace_section);

    // Git Branch
    const git_section = try GitSection.init(allocator);
    defer allocator.free(git_section);

    // Path
    const path_section = try PathSection.init(allocator, cwd);
    defer allocator.free(path_section);

    // TODO: Make and arrow section so you can customize the color.
    _ = try stdout.print(
        " {s} │ {s} {s} {s} \n  ",
        .{ host_section, workspace_section, git_section, path_section },
    );
}
