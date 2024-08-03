const std = @import("std");

fn includeExtensions(extensions: []const []const u8, filename: []const u8) bool {
    for (extensions) |ext| {
        if (std.mem.endsWith(u8, filename, ext)) {
            return true;
        }
    }
    return false;
}

test "includeExtensions with typical extensions" {
    const extensions = &[_][]const u8{ ".js", ".scala" };

    try std.testing.expect(includeExtensions(extensions, "example.js"));
    try std.testing.expect(includeExtensions(extensions, "example.scala"));
    try std.testing.expect(!includeExtensions(extensions, "example.txt"));
    try std.testing.expect(!includeExtensions(extensions, "example.js.txt"));
}

test "includeExtensions with empty extensions list" {
    const extensions = &[_][]const u8{};

    try std.testing.expect(!includeExtensions(extensions, "example.js"));
    try std.testing.expect(!includeExtensions(extensions, "example.scala"));
    try std.testing.expect(!includeExtensions(extensions, "example.txt"));
}

test "includeExtensions with filenames having multiple dots" {
    const extensions = &[_][]const u8{ ".js", ".scala" };

    try std.testing.expect(includeExtensions(extensions, "example.min.js"));
    try std.testing.expect(!includeExtensions(extensions, "example.min.txt"));
    try std.testing.expect(includeExtensions(extensions, "test.version1.scala"));
}

test "includeExtensions with extensions as part of the filename" {
    const extensions = &[_][]const u8{ ".js", ".scala" };

    try std.testing.expect(!includeExtensions(extensions, "examplejs"));
    try std.testing.expect(!includeExtensions(extensions, "examplescala"));
}

test "includeExtensions with mixed case extensions" {
    const extensions = &[_][]const u8{ ".js", ".SCALA" };

    try std.testing.expect(includeExtensions(extensions, "example.js"));
    try std.testing.expect(includeExtensions(extensions, "example.SCALA"));
    try std.testing.expect(!includeExtensions(extensions, "example.scala"));
    try std.testing.expect(!includeExtensions(extensions, "example.JS"));
}

test "includeExtensions with leading dot in extensions" {
    const extensions = &[_][]const u8{ ".js", ".scala" };

    try std.testing.expect(includeExtensions(extensions, "example.js"));
    try std.testing.expect(includeExtensions(extensions, "example.scala"));
    try std.testing.expect(!includeExtensions(extensions, "examplejs"));
    try std.testing.expect(!includeExtensions(extensions, "examplescala"));
}
