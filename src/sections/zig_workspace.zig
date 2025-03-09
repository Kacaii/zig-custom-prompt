const std = @import("std");

const Child = std.process.Child;
const Allocator = std.mem.Allocator;

const W = @import("../workspace.zig");

const set_color = struct {
    const yellow = "\x1b[33m";
    const normal = "\x1b[39m";
};

pub const ZigWorkspace: W.Workspace = .{
    .color = set_color.yellow,
    .root = "build.zig",
    .init_fn = init,
};

fn init(allocator: Allocator) W.WorkspaceError![]u8 {
    const zig_version_run = try Child.run(.{
        .allocator = allocator,
        .argv = &[_][]const u8{ "zig", "version" },
    });

    defer allocator.free(zig_version_run.stdout);
    defer allocator.free(zig_version_run.stderr);

    const zig_version_output = zig_version_run.stdout;
    const zig_version = std.mem.trimRight(
        u8,
        zig_version_output,
        "\n",
    );

    const zig_section = try std.mem.concat(
        allocator,
        u8,
        &[_][]const u8{
            set_color.yellow,
            "[ Zig ",
            zig_version,
            "]",
            set_color.normal,
        },
    );
    return zig_section;
}
