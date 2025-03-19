const std = @import("std");
const Allocator = std.mem.Allocator;

const set_color = struct {
    const red = "\x1b[31m";
    const normal = "\x1b[39m";
};

pub const GitData = struct {
    const Self = @This();

    branch: []const u8,
    is_dirty: bool,
    is_repo: bool,
    root: []const u8,

    // Caller owns the memory
    pub fn init(allocator: Allocator) !*Self {
        const git_status_arv = [_][]const u8{ "git", "status" };
        const git_status_cmd = try std.process.Child.run(.{
            .allocator = allocator,
            .argv = &git_status_arv,
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

        const git_root_argv = [_][]const u8{ "git", "rev-parse", "--show-toplevel" };
        const git_root_cmd = try std.process.Child.run(.{
            .allocator = allocator,
            .argv = &git_root_argv,
        });

        defer allocator.free(git_root_cmd.stdout);
        defer allocator.free(git_root_cmd.stderr);

        const root = blk: {
            if (!is_repo) break :blk "";
            const parsed = std.mem.trimRight(u8, git_root_cmd.stdout, "\n");
            break :blk try allocator.dupe(u8, parsed);
        };

        const git_dirty_argv = [_][]const u8{ "git", "diff-files", "--quiet" };
        const git_dirty_cmd = try std.process.Child.run(.{
            .allocator = allocator,
            .argv = &git_dirty_argv,
        });

        defer allocator.free(git_dirty_cmd.stdout);
        defer allocator.free(git_dirty_cmd.stderr);

        const is_dirty = if (git_dirty_cmd.term.Exited == 1) true else false;

        const git_data = try allocator.create(GitData);
        git_data.* = Self{
            .is_repo = is_repo,
            .branch = branch,
            .root = root,
            .is_dirty = is_dirty,
        };

        return git_data;
    }

    // Free allocated resources
    pub fn deinit(self: *Self, allocator: Allocator) void {
        defer allocator.destroy(self);

        allocator.free(self.branch);
        allocator.free(self.root);
    }
};

// Caller owns the memory
pub fn init(allocator: Allocator) ![]const u8 {
    const git_status = try GitData.init(allocator);
    defer git_status.deinit(allocator);

    if (!git_status.is_repo) return "";

    const is_dirty = if (git_status.is_dirty) "*" else "";

    const section = try std.fmt.allocPrint(
        allocator,
        "on {s}{s} {s}{s}{s}",
        .{ set_color.red, "", git_status.branch, is_dirty, set_color.normal },
    );

    return section;
}

// TODO: Add tests
