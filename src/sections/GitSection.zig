const std = @import("std");
const Allocator = std.mem.Allocator;

const set_color = struct {
    const red = "\x1b[31m";
    const normal = "\x1b[39m";
};

const GitStatus = struct {
    const Self = @This();

    is_repo: bool,
    branch: []const u8,

    // Caller owns the memory
    fn init(allocator: Allocator) !*Self {
        const argv = [_][]const u8{ "git", "status" };
        const git_status_cmd = try std.process.Child.run(.{
            .allocator = allocator,
            .argv = &argv,
        });

        defer allocator.free(git_status_cmd.stdout);
        defer allocator.free(git_status_cmd.stderr);

        const is_repo = git_status_cmd.term.Exited == 0;

        const branch = blk: {
            if (!is_repo) break :blk "";

            var iter = std.mem.splitScalar(u8, git_status_cmd.stdout, '\n');

            const first_line = iter.first();
            break :blk try allocator.dupe(u8, first_line[10..]);
        };

        const git_status = try allocator.create(GitStatus);
        git_status.* = Self{
            .is_repo = is_repo,
            .branch = branch,
        };

        return git_status;
    }

    fn deinit(self: *Self, allocator: Allocator) void {
        allocator.free(self.branch);
        allocator.destroy(self);
    }
};

// Caller owns the memory
pub fn init(allocator: Allocator) ![]const u8 {
    const git_status = try GitStatus.init(allocator);
    defer git_status.deinit(allocator);

    if (!git_status.is_repo) return "";

    const section = try std.fmt.allocPrint(
        allocator,
        "on {s}{s} {s}{s}",
        .{ set_color.red, "", git_status.branch, set_color.normal },
    );

    return section;
}

// TODO: Detect git dirty
// TODO: Add tests
