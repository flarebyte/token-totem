const std = @import("std");
const delimiter_counter = @import("delimiter_counter.zig");
const specific_seq_counter = @import("specific_seq_counter.zig");

const TokenCountStrategy = enum {
    Delimiter,
    SpecificSequence,
};

const TokenCountResult = struct {
    count: usize,
    filename: []const u8,
};

pub fn countTokensInFile(filepath: []const u8, strategy: TokenCountStrategy) !TokenCountResult {
    const file = try std.fs.cwd().openFile(filepath, .{});
    defer file.close();

    var reader = file.reader();
    const buffer_size = 4096;
    var buffer: [buffer_size]u8 = undefined;

    var total_count: usize = 0;

    while (true) {
        const bytes_read = try reader.read(buffer[0..]);
        if (bytes_read == 0) break;

        const chunk = buffer[0..bytes_read];
        total_count += switch (strategy) {
            TokenCountStrategy.Delimiter => delimiter_counter.countTokensByDelimiter(chunk),
            TokenCountStrategy.SpecificSequence => specific_seq_counter.countTokensBySpecificSequence(chunk),
        };
    }

    return TokenCountResult{
        .count = total_count,
        .filename = filepath,
    };
}
