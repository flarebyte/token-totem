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

test "countTokensByDelimiter works with normal text" {
    const content = "int main() {\n    printf(\"Hello, World!\");\n}";
    const expected = 16; // ["int", "main", "(", ")", "{", "printf", "(", "\"", "Hello", ",", "World", "!", "\"", ")", ";", "}"]
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(expected, result);
}

test "countTokensByDelimiter works with empty string" {
    const content = "";
    const expected = 0;
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(expected, result);
}

test "countTokensByDelimiter works with only delimiters" {
    const content = " \t\n\r";
    const expected = 0;
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(expected, result);
}

test "countTokensByDelimiter works with single token" {
    const content = "Hello";
    const expected = 1;
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(expected, result);
}

test "countTokensByDelimiter works with multiple spaces between tokens" {
    const content = "Hello     World";
    const expected = 2; // ["Hello", "World"]
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(expected, result);
}

test "countTokensByDelimiter works with mixed delimiters" {
    const content = "Hello, World! This\tis\na test.";
    const expected = 10; // ["Hello", ",", "World", "!", "This", "is", "a", "test", "."]
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(expected, result);
}

test "countTokensByDelimiter works with delimiters at the start and end" {
    const content = ",;:!Hello World!?;:";
    const expected = 11; // [",", ";", ":", "!", "Hello", "World", "!", "?", ";", ":"]
    const result = countTokensByDelimiter(content);
    try std.testing.expectEqual(expected, result);
}

pub fn main() !void {
    // Run the tests
    const example_content = "int main() {\n    printf(\"Hello, World!\");\n}";
    const token_count = countTokensByDelimiter(example_content);
    std.debug.print("Token count: {}\n", .{token_count});
}
