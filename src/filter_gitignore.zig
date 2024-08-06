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

test "isIgnored with typical patterns" {
    const patterns = &[_][]const u8{ ".idea", "*.log", "node_modules/", "build/", ".DS_Store" };

    try std.testing.expect(isIgnored(patterns, "example.log"));
    try std.testing.expect(!isIgnored(patterns, "example.txt"));
    try std.testing.expect(isIgnored(patterns, "node_modules/package.json"));
    try std.testing.expect(isIgnored(patterns, "build/test.o"));
    try std.testing.expect(isIgnored(patterns, ".DS_Store"));
}

test "isIgnored with empty patterns list" {
    const patterns = &[_][]const u8{};

    try std.testing.expect(!isIgnored(patterns, "example.log"));
    try std.testing.expect(!isIgnored(patterns, "example.txt"));
    try std.testing.expect(!isIgnored(patterns, "node_modules/package.json"));
}

test "isIgnored with patterns matching directories" {
    const patterns = &[_][]const u8{ "node_modules/", "build/", "test/" };

    try std.testing.expect(isIgnored(patterns, "node_modules/package.json"));
    try std.testing.expect(isIgnored(patterns, "build/test.o"));
    try std.testing.expect(isIgnored(patterns, "test/test.cpp"));
    try std.testing.expect(!isIgnored(patterns, "src/test.cpp"));
}

test "isIgnored with partial matches" {
    const patterns = &[_][]const u8{ ".log", "build" };

    try std.testing.expect(isIgnored(patterns, "example.log"));
    try std.testing.expect(isIgnored(patterns, "example.build"));
    try std.testing.expect(!isIgnored(patterns, "build_directory/file.txt"));
    try std.testing.expect(!isIgnored(patterns, "logging/example.log.txt"));
}

test "isIgnored with leading dot patterns" {
    const patterns = &[_][]const u8{ ".hidden", ".DS_Store" };

    try std.testing.expect(isIgnored(patterns, ".hidden"));
    try std.testing.expect(!isIgnored(patterns, "visible"));
    try std.testing.expect(isIgnored(patterns, ".DS_Store"));
}

test "isIgnored with mixed patterns" {
    const patterns = &[_][]const u8{ "*.log", "node_modules/", "test/" };

    try std.testing.expect(isIgnored(patterns, "error.log"));
    try std.testing.expect(isIgnored(patterns, "node_modules/package.json"));
    try std.testing.expect(isIgnored(patterns, "test/example.cpp"));
    try std.testing.expect(!isIgnored(patterns, "src/test.cpp"));
    try std.testing.expect(!isIgnored(patterns, "example.log.txt"));
}
