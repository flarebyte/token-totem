const std = @import("std");

fn isIgnored(patterns: []const []const u8, filename: []const u8) bool {
    for (patterns) |pattern| {
        if (std.mem.endsWith(u8, filename, pattern) or std.mem.indexOf(u8, filename, pattern) != null) {
            return true;
        }
    }
    return false;
}

fn parseGitIgnoreContent(content: []const u8) ![]const []const u8 {
    var allocator = std.heap.page_allocator;
    var patterns = std.ArrayList([]const u8).init(allocator);
    var lines = std.mem.split(content, "\n");

    for (lines) |line| {
        const trimmed = std.mem.trimRight(line, " \r\n");
        if (trimmed.len > 0 and !std.mem.startsWith(u8, trimmed, "#")) {
            try patterns.append(trimmed);
        }
    }

    return patterns.toOwnedSlice();
}

fn respectGitIgnore(gitIgnoreContent: []const u8, filename: []const u8) !bool {
    const patterns = try parseGitIgnoreContent(gitIgnoreContent);
    return isIgnored(patterns, filename);
}
