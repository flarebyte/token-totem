const std = @import("std");
const testing = std.testing;

const multiCharOperators = [_][]const u8{
    "[]", "->", "=>", "::", "==", "!=", "<=", ">=", "&&", "||", "++", "--", "+=", "-=", "*=", "/=", "%=", "&=", "|=", "^=", "<<", ">>", ">>>",
    // Add more multi-character operators as needed
};

fn isMultiCharOperator(content: []const u8, index: usize) ?usize {
    for (multiCharOperators) |op| {
        if (std.mem.startsWith(u8, content[index..], op)) {
            return op.len;
        }
    }
    return null;
}

fn isSingleCharOperator(c: u8) bool {
    return switch (c) {
        '!', '%', '^', '&', '*', '(', ')', '-', '+', '=', '{', '}', '[', ']', '|', '\\', ':', ';', '"', '\'', '<', '>', ',', '.', '?', '/', '~', '`' => true,
        else => false,
    };
}

fn isWhitespace(c: u8) bool {
    return switch (c) {
        ' ', '\t', '\n', '\r' => true,
        else => false,
    };
}

fn isWordChar(c: u8) bool {
    return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c >= '0' and c <= '9') or (c == '_');
}

pub fn countTokensBySpecificSequence(content: []const u8) usize {
    var index: usize = 0;
    var tokenCount: usize = 0;

    while (index < content.len) {
        // Skip whitespace
        while (index < content.len and isWhitespace(content[index])) {
            index += 1;
        }

        if (index >= content.len) break;

        if (isMultiCharOperator(content, index)) |opLen| {
            // Found a multi-character operator
            index += opLen;
            tokenCount += 1;
        } else if (isSingleCharOperator(content[index])) {
            // Found a single-character operator
            index += 1;
            tokenCount += 1;
        } else if (isWordChar(content[index])) {
            // Found a word
            while (index < content.len and isWordChar(content[index])) {
                index += 1;
            }
            tokenCount += 1;
        } else {
            // Unknown single character token
            index += 1;
            tokenCount += 1;
        }
    }

    return tokenCount;
}

pub fn main() void {
    const content = "int main() { return 0; }";
    const tokenCount = countTokensBySpecificSequence(content);
    std.debug.print("Token count: {}\n", .{tokenCount});
}

test "test isMultiCharOperator" {
    const content = "=>";
    try testing.expect(isMultiCharOperator(content, 0) == 2);
    try testing.expect(isMultiCharOperator("abc", 0) == null);
}

test "test isSingleCharOperator" {
    try testing.expect(isSingleCharOperator('+') == true);
    try testing.expect(isSingleCharOperator('a') == false);
}

test "test isWhitespace" {
    try testing.expect(isWhitespace(' ') == true);
    try testing.expect(isWhitespace('\t') == true);
    try testing.expect(isWhitespace('a') == false);
}

test "test isWordChar" {
    try testing.expect(isWordChar('a') == true);
    try testing.expect(isWordChar('_') == true);
    try testing.expect(isWordChar('1') == true);
    try testing.expect(isWordChar('-') == false);
}

test "test countTokensBySpecificSequence basic" {
    const content = "int main() { return 0; }";
    try testing.expect(countTokensBySpecificSequence(content) == 7);
}

test "test countTokensBySpecificSequence multi-char operators" {
    const content = "a == b && c || d -> e";
    try testing.expect(countTokensBySpecificSequence(content) == 9);
}

test "test countTokensBySpecificSequence mixed tokens" {
    const content = "if (x >= 10 && y <= 20) { z++; }";
    try testing.expect(countTokensBySpecificSequence(content) == 14);
}

test "test countTokensBySpecificSequence edge cases" {
    const content = " ";
    try testing.expect(countTokensBySpecificSequence(content) == 0);

    const content2 = "";
    try testing.expect(countTokensBySpecificSequence(content2) == 0);

    const content3 = "===>===";
    try testing.expect(countTokensBySpecificSequence(content3) == 5);

    const content4 = "a--b++c";
    try testing.expect(countTokensBySpecificSequence(content4) == 5);
}
