const std = @import("std");

fn includeExtensions(extensions: []const []const u8, filename: []const u8) bool {
    for (extensions) |ext| {
        if (std.mem.endsWith(u8, filename, ext)) {
            return true;
        }
    }
    return false;
}
