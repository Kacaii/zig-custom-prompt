const std = @import("std");
const builtin = @import("builtin");
const Child = std.process.Child;

const WorkSpace = @import("./workspace.zig");

pub fn main() !void {
    // const stdout = std.io.getStdOut().writer();
    //
    // var debug_allocator: std.heap.DebugAllocator(.{}) = .init;
    // const allocator, const is_debug = switch (builtin.mode) {
    //     .Debug, .ReleaseSafe => .{ debug_allocator.allocator(), true },
    //     .ReleaseFast, .ReleaseSmall => .{ std.heap.smp_allocator, false },
    // };
    //
    // defer if (is_debug) {
    //     _ = debug_allocator.deinit();
    // };
}
