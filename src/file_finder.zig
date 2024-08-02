const std = @import("std");

// Example usage of includeExtensions
pub fn filterFiles(currentDir: []const u8, filter: fn ([]const u8) bool) ![]const []const u8 {
    const allocator = std.heap.page_allocator;
    var fs = std.fs.cwd();
    var dir = try fs.openDir(currentDir, .{});
    defer dir.close();

    var fileList = std.ArrayList([]const u8).init(allocator);

    while (try dir.readDir()) |entry| {
        if (filter(entry.name)) {
            try fileList.append(entry.name);
        }
    }

    return fileList.toOwnedSlice();
}
