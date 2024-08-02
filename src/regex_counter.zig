const std = @import("std");
const Regex = @import("regex").Regex;

// Define the function to count matches outside of the main function
fn countMatches(content: []const u8, regexList: []Regex) usize {
    var count: usize = 0;
    var i: usize = 0;

    while (i < content.len) : (i += 1) {
        for (regexList) |regex| {
            if (regex.match(content[i..])) |m| {
                count += 1;
                // Skip matched length to avoid overlapping matches
                i += m.len - 1;
                break;
            }
        }
    }
    return count;
}

pub fn countTokensByRegex(content: []const u8) !usize {
    const allocator = std.heap.page_allocator;

    // Define patterns for multi-character operators and other tokens
    const tokenPatterns = [_][]const u8{
        // Multi-character operators
        "==", "!=", "<=", ">=", "&&", "||", "++", "--", "->", "=>", "::", ":::", "##", "%%", "\\[\\]", "\\{\\}",
        // Single-character operators
        "[(){};,.:<>+\\-*/&|^%!=]",
        // Keywords and identifiers
        "\\b[_a-zA-Z][_a-zA-Z0-9]*\\b",
        // Numeric literals
        "\\b\\d+\\b",
        // String literals
        "\"(\\\\.|[^\"\\\\])*\"",
        // Single-line comments
        "//[^\n]*",
        // Multi-line comments
        "/\\*([^*]|\\*+[^*/])*\\*+/"
    };

    // Compile all regex patterns
    var regexList = try allocator.alloc(Regex, tokenPatterns.len);
    defer allocator.free(regexList);

    for (tokenPatterns) |pattern, i| {
        regexList[i] = try Regex.compile(allocator, pattern, .{}, .{});
    }

    return countMatches(content, regexList);
}

// Unit Tests for countTokensByRegex
test "countTokensByRegex basic test" {
    const content = "int main() { return 0; }";
    const expected_tokens = [_][]const u8{ "int", "main", "(", ")", "{", "return", "0", ";", "}" };
    const count = try countTokensByRegex(content);
    std.testing.expect(count == expected_tokens.len);
}

test "countTokensByRegex with operators" {
    const content = "a == b && c != d;";
    const expected_tokens = [_][]const u8{ "a", "==", "b", "&&", "c", "!=", "d", ";" };
    const count = try countTokensByRegex(content);
    std.testing.expect(count == expected_tokens.len);
}

test "countTokensByRegex with comments" {
    const content = "int a = 0; // This is a comment\n/* Multi-line\ncomment */";
    const expected_tokens = [_][]const u8{ "int", "a", "=", "0", ";", "// This is a comment", "/* Multi-line\ncomment */" };
    const count = try countTokensByRegex(content);
    std.testing.expect(count == expected_tokens.len);
}

test "countTokensByRegex with strings" {
    const content = "char* str = \"Hello, world!\";";
    const expected_tokens = [_][]const u8{ "char", "*", "str", "=", "\"Hello, world!\"", ";" };
    const count = try countTokensByRegex(content);
    std.testing.expect(count == expected_tokens.len);
}

// Unit Tests for countMatches
test "countMatches basic test" {
    const allocator = std.testing.allocator;
    const patterns = [_][]const u8{ "\\b[_a-zA-Z][_a-zA-Z0-9]*\\b", "\\b\\d+\\b", "[(){};,.:<>+\\-*/&|^%!=]" };
    var regexList = try allocator.alloc(Regex, patterns.len);
    defer allocator.free(regexList);

    for (patterns) |pattern, i| {
        regexList[i] = try Regex.compile(allocator, pattern, .{}, .{});
    }

    const content = "int main() { return 0; }";
    const expected_tokens = [_][]const u8{ "int", "main", "(", ")", "{", "return", "0", ";", "}" };
    const count = countMatches(content, regexList);
    std.testing.expect(count == expected_tokens.len);
}

test "countMatches with operators" {
    const allocator = std.testing.allocator;
    const patterns = [_][]const u8{ "==", "!=", "\\b[_a-zA-Z][_a-zA-Z0-9]*\\b", "[(){};,.:<>+\\-*/&|^%!=]" };
    var regexList = try allocator.alloc(Regex, patterns.len);
    defer allocator.free(regexList);

    for (patterns) |pattern, i| {
        regexList[i] = try Regex.compile(allocator, pattern, .{}, .{});
    }

    const content = "a == b && c != d;";
    const expected_tokens = [_][]const u8{ "a", "==", "b", "&&", "c", "!=", "d", ";" };
    const count = countMatches(content, regexList);
    std.testing.expect(count == expected_tokens.len);
}

test "countMatches with comments" {
    const allocator = std.testing.allocator;
    const patterns = [_][]const u8{ "\\b[_a-zA-Z][_a-zA-Z0-9]*\\b", "\\b\\d+\\b", "[(){};,.:<>+\\-*/&|^%!=]", "//[^\n]*", "/\\*([^*]|\\*+[^*/])*\\*+/" };
    var regexList = try allocator.alloc(Regex, patterns.len);
    defer allocator.free(regexList);

    for (patterns) |pattern, i| {
        regexList[i] = try Regex.compile(allocator, pattern, .{}, .{});
    }

    const content = "int a = 0; // This is a comment\n/* Multi-line\ncomment */";
    const expected_tokens = [_][]const u8{ "int", "a", "=", "0", ";", "// This is a comment", "/* Multi-line\ncomment */" };
    const count = countMatches(content, regexList);
    std.testing.expect(count == expected_tokens.len);
}

test "countMatches with strings" {
    const allocator = std.testing.allocator;
    const patterns = [_][]const u8{ "\\b[_a-zA-Z][_a-zA-Z0-9]*\\b", "\\b\\d+\\b", "[(){};,.:<>+\\-*/&|^%!=]", "\"(\\\\.|[^\"\\\\])*\"" };
    var regexList = try allocator.alloc(Regex, patterns.len);
    defer allocator.free(regexList);

    for (patterns) |pattern, i| {
        regexList[i] = try Regex.compile(allocator, pattern, .{}, .{});
    }

    const content = "char* str = \"Hello, world!\";";
    const expected_tokens = [_][]const u8{ "char", "*", "str", "=", "\"Hello, world!\"", ";" };
    const count = countMatches(content, regexList);
    std.testing.expect(count == expected_tokens.len);
}
