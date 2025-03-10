const ZigWorkspace = @import("./sections/workspaces/zig_workspace.zig");
const DenoWorkspace = @import("./sections/workspaces/deno_workspace.zig");
const DefaultWorkspace = @import("./sections/workspaces/default_workspace.zig");

// Tests goes here. Run `zig build test`.
test {
    _ = ZigWorkspace;
    _ = DenoWorkspace;
    _ = DefaultWorkspace;
}
