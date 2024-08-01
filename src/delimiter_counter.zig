const std = @import("std");

fn isDelimiter(char: u8) bool {
    const delimiters = " \t\n\r";
    for (delimiters) |delimiter| {
        if (char == delimiter) {
            return true;
        }
    }
    return false;
}

fn isPunctuationOrOperator(char: u8) bool {
    const punctuations_and_operators = ".,;:!?()[]{}<>/\\|\"'`~@#$%^&*-+=_";
    for (punctuations_and_operators) |punctuation| {
        if (char == punctuation) {
            return true;
        }
    }
    return false;
}

pub fn countTokensByDelimiter(content: []const u8) usize {
    var token_count: usize = 0;
    var in_token = false;

    for (content) |char| {
        if (isDelimiter(char)) {
            if (in_token) {
                token_count += 1;
                in_token = false;
            }
        } else if (isPunctuationOrOperator(char)) {
            if (in_token) {
                token_count += 1;
                in_token = false;
            }
            token_count += 1;
        } else {
            in_token = true;
        }
    }

    // If the last character was part of a token, count the final token
    if (in_token) {
        token_count += 1;
    }

    return token_count;
}
test "isDelimiter works correctly" {
    const delimiters = " \t\n\r";
    for (delimiters) |delimiter| {
        try std.testing.expect(isDelimiter(delimiter));
    }

    const non_delimiters = "abc123";
    for (non_delimiters) |char| {
        try std.testing.expect(!isDelimiter(char));
    }
}

test "isPunctuationOrOperator works correctly" {
    const punctuations_and_operators = ".,;:!?()[]{}<>/\\|\"'`~@#$%^&*-+=_";
    for (punctuations_and_operators) |punctuation| {
        try std.testing.expect(isPunctuationOrOperator(punctuation));
    }

    const non_punctuations = "abc123";
    for (non_punctuations) |char| {
        try std.testing.expect(!isPunctuationOrOperator(char));
    }
}

test "countTokensByDelimiter works with normal text" {
    const content = "int main() {\n    printf(\"Hello, World!\");\n}";
    const expected_tokens = [_][]const u8{ "int", "main", "(", ")", "{", "printf", "(", "\"", "Hello", ",", "World", "!", "\"", ")", ";", "}" };
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(@as(usize, expected_tokens.len), result);
}

test "countTokensByDelimiter works with empty string" {
    const content = "";
    const expected_tokens = [_][]const u8{};
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(@as(usize, expected_tokens.len), result);
}

test "countTokensByDelimiter works with only delimiters" {
    const content = " \t\n\r";
    const expected_tokens = [_][]const u8{};
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(@as(usize, expected_tokens.len), result);
}

test "countTokensByDelimiter works with single token" {
    const content = "Hello";
    const expected_tokens = [_][]const u8{"Hello"};
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(@as(usize, expected_tokens.len), result);
}

test "countTokensByDelimiter works with multiple spaces between tokens" {
    const content = "Hello     World";
    const expected_tokens = [_][]const u8{ "Hello", "World" };
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(@as(usize, expected_tokens.len), result);
}

test "countTokensByDelimiter works with mixed delimiters" {
    const content = "Hello, World! This\tis\na test.";
    const expected_tokens = [_][]const u8{ "Hello", ",", "World", "!", "This", "is", "a", "test", "." };
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(@as(usize, expected_tokens.len), result);
}

test "countTokensByDelimiter works with delimiters at the start and end" {
    const content = ",;:!Hello World!?;:";
    const expected_tokens = [_][]const u8{ ",", ";", ":", "!", "Hello", "World", "!", "?", ";", ":" };
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(@as(usize, expected_tokens.len), result);
}
