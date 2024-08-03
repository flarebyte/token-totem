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
    const allocator = std.heap.page_allocator;
    var patterns = std.ArrayList([]const u8).init(allocator);
    var linesIt = std.mem.splitSequence(u8, content, "\n");

    while (linesIt.next()) |line| {
        const trimmed = std.mem.trimRight(u8, line, " \r\n");
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

test "parseGitIgnoreContent with typical content" {
    const gitIgnoreContent =
        \\# This is a comment
        \\.idea
        \\*.log
        \\node_modules/
        \\build/
        \\.DS_Store
        \\"
    ;

    const patterns = try parseGitIgnoreContent(gitIgnoreContent);

    try std.testing.expectEqualStrings(".idea", patterns[0]);
    try std.testing.expectEqualStrings("*.log", patterns[1]);
    try std.testing.expectEqualStrings("node_modules/", patterns[2]);
    try std.testing.expectEqualStrings("build/", patterns[3]);
    try std.testing.expectEqualStrings(".DS_Store", patterns[4]);
}

test "parseGitIgnoreContent with empty content" {
    const gitIgnoreContent = "";
    const patterns = try parseGitIgnoreContent(gitIgnoreContent);
    try std.testing.expect(patterns.len == 0);
}

test "parseGitIgnoreContent with only comments and whitespace" {
    const gitIgnoreContent =
        \\# Comment 1
        \\
        \\  # Comment 2
        \\
        \\# Comment 3
        \\
    ;

    const patterns = try parseGitIgnoreContent(gitIgnoreContent);
    try std.testing.expect(patterns.len == 0);
}
