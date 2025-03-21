const std = @import("std");
const Allocator = std.mem.Allocator;

const set_color = struct {
    const magenta = "\x1b[35m";
    const normal = "\x1b[39m";
};

/// Returns the user's hostname.
/// Caller owns the memory.
pub fn init(allocator: Allocator) ![]u8 {
    var buffer: [std.posix.HOST_NAME_MAX]u8 = undefined;

    const hostname = try std.posix.gethostname(&buffer);
    const section = std.fmt.allocPrint(
        allocator,
        "{s}{s}{s}",
        .{ set_color.magenta, hostname, set_color.normal },
    );

    return section;
}
