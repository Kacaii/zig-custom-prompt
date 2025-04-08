const std = @import("std");
const fs = std.fs;
const Child = std.process.Child;
const builtin = @import("builtin");

const HostSection = @import("./sections/HostSection.zig");
const PathSection = @import("./sections/PathSection.zig");
const GitSection = @import("./sections/WorkspaceSection/GitSection.zig");
const WorkspaceSection = @import("./sections/WorkspaceSection/WorkspaceSection.zig");
const PromptSymbol = @import("./sections/PromptSymbolSection.zig");

pub fn main() !void {
    const cwd = fs.cwd();
    const stdout = std.io.getStdOut().writer();

    var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    const gpa, const is_debug = switch (builtin.mode) {
        .Debug, .ReleaseSafe => .{ debug_allocator.allocator(), true },
        .ReleaseFast, .ReleaseSmall => .{ std.heap.smp_allocator, false },
    };

    defer if (is_debug) {
        _ = debug_allocator.deinit();
    };

    // Host name
    const host_section = HostSection.init(gpa) catch "";
    defer gpa.free(host_section);

    // Icon and Programming Language
    const workspace_section = WorkspaceSection.init(gpa, cwd) catch "";
    defer gpa.free(workspace_section);

    // Git Branch
    const git_section = GitSection.init(gpa) catch "";
    defer gpa.free(git_section);

    // Path
    const path_section = PathSection.init(gpa, cwd) catch "";
    defer gpa.free(path_section);

    // Arrow
    const prompt_symbol = PromptSymbol.init(gpa) catch " $ ";
    defer gpa.free(prompt_symbol);

    _ = try stdout.print(
        " {s} | {s} | {s}{s} \n {s} ",
        .{ host_section, workspace_section, git_section, path_section, prompt_symbol },
    );
}
