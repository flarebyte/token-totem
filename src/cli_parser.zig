const std = @import("std");

const ParsedArguments = struct {
    include_files: std.ArrayList([]const u8),
    format: []const u8,
    price_per_token: f64,
    currency: []const u8,
    no_gitignore: bool,
    by_file: bool,
    help: bool,
};

pub fn parseArguments(args: [][]const u8) !ParsedArguments {
    var result = ParsedArguments{
        .include_files = std.ArrayList([]const u8).init(std.heap.page_allocator),
        .format = "human-readable",
        .price_per_token = 1.0,
        .currency = "USD",
        .no_gitignore = false,
        .by_file = false, // By default, it's false, meaning `--by-lang` is the default.
        .help = false,
    };

    var i: usize = 0;
    while (i < args.len) {
        const arg = args[i];

        if (std.mem.eql(u8, arg, "--include")) {
            i += 1;
            while (i < args.len and !std.mem.startsWith(u8, args[i], "--")) {
                result.include_files.append(args[i]) catch {
                    return error.OutOfMemory;
                };
                i += 1;
            }
        } else if (std.mem.eql(u8, arg, "--format")) {
            i += 1;
            if (i < args.len) {
                result.format = args[i];
                i += 1;
            } else {
                return error.InvalidArgument;
            }
        } else if (std.mem.eql(u8, arg, "--price-per-token")) {
            i += 1;
            if (i < args.len) {
                const price_str = args[i];
                result.price_per_token = try std.fmt.parseFloat(f64, price_str);
                i += 1;
                if (i < args.len) {
                    result.currency = args[i];
                    i += 1;
                } else {
                    return error.InvalidArgument;
                }
            } else {
                return error.InvalidArgument;
            }
        } else if (std.mem.eql(u8, arg, "--no-gitignore")) {
            result.no_gitignore = true;
            i += 1;
        } else if (std.mem.eql(u8, arg, "--by-file")) {
            result.by_file = true;
            i += 1;
        } else if (std.mem.eql(u8, arg, "--by-lang")) {
            result.by_file = false;
            i += 1;
        } else if (std.mem.eql(u8, arg, "--help")) {
            result.help = true;
            i += 1;
        } else {
            return error.UnknownArgument;
        }
    }

    return result;
}

test "parseArguments should handle empty arguments with default values" {
    const args: [][]const u8 = &[_][]const u8{};
    const parsed = try parseArguments(args);
    try std.testing.expect(parsed.include_files.items.len == 0);
    try std.testing.expect(std.mem.eql(u8, parsed.format, "human-readable"));
    try std.testing.expect(parsed.price_per_token == 1.0);
    try std.testing.expect(std.mem.eql(u8, parsed.currency, "USD"));
    try std.testing.expect(parsed.no_gitignore == false);
    try std.testing.expect(parsed.by_file == false);
    try std.testing.expect(parsed.help == false);
}

test "parseArguments should parse include files" {
    const args = [_][]const u8{"--include", "file1.py", "file2.js"}[0..];
    const parsed = try parseArguments(args);
    try std.testing.expect(parsed.include_files.items.len == 2);
    try std.testing.expect(std.mem.eql(u8, parsed.include_files.items[0], "file1.py"));
    try std.testing.expect(std.mem.eql(u8, parsed.include_files.items[1], "file2.js"));
}

test "parseArguments should handle format and price-per-token with currency" {
    const args = [_][]const u8{"--format", "csv", "--price-per-token", "0.02", "EUR"}[0..];
    const parsed = try parseArguments(args);
    try std.testing.expect(std.mem.eql(u8, parsed.format, "csv"));
    try std.testing.expect(parsed.price_per_token == 0.02);
    try std.testing.expect(std.mem.eql(u8, parsed.currency, "EUR"));
}

test "parseArguments should handle --no-gitignore flag" {
    const args = [_][]const u8{"--no-gitignore"}[0..];
    const parsed = try parseArguments(args);
    try std.testing.expect(parsed.no_gitignore == true);
}

test "parseArguments should handle --by-file flag" {
    const args = [_][]const u8{"--by-file"}[0..];
    const parsed = try parseArguments(args);
    try std.testing.expect(parsed.by_file == true);
}

test "parseArguments should default to --by-lang if --by-file is absent" {
    const args = [_][]const u8{}[0..];
    const parsed = try parseArguments(args);
    try std.testing.expect(parsed.by_file == false);  // by_lang is default
}

test "parseArguments should handle --help flag" {
    const args = [_][]const u8{"--help"}[0..];
    const parsed = try parseArguments(args);
    try std.testing.expect(parsed.help == true);
}

test "parseArguments should return error for unknown arguments" {
    const args = [_][]const u8{"--unknown"}[0..];
    const parse_result = parseArguments(args);
    std.testing.expect(parse_result == error.UnknownArgument) catch {};
}

test "parseArguments should return error if --price-per-token is missing value" {
    const args = [_][]const u8{"--price-per-token"}[0..];
    const parse_result = parseArguments(args);
    std.testing.expect(parse_result == error.InvalidArgument) catch {};
}

test "parseArguments should return error if --price-per-token is missing currency" {
    const args = [_][]const u8{"--price-per-token", "0.05"}[0..];
    const parse_result = parseArguments(args);
    std.testing.expect(parse_result == error.InvalidArgument) catch {};
}
