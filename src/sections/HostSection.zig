const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn init(allocator: Allocator) ![]u8 {
    var buffer: [std.posix.HOST_NAME_MAX]u8 = undefined;

    const hostname = try std.posix.gethostname(&buffer);
    const section = std.fmt.allocPrint(allocator, "{s}", .{hostname});

    return section;
}
