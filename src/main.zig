const std = @import("std");
const utils = @import("utils.zig");
const Logger = @import("logger.zig").Logger;
const Args = @import("args.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var stdin = std.io.getStdIn().reader();

    const read = try stdin.readAllAlloc(allocator, 1024 * 4);
    defer allocator.free(read);

    const args = Args.Args.parse(allocator) catch |err| {
        const writer = std.io.getStdErr().writer();

        switch (err) {
            Args.ParserError.MissingLevel => try writer.print("Level flag requires an argument. For help use '-h'.\n", .{}),
            Args.ParserError.InvalidLevel => try writer.print("Invalid level argument. For help use '-h'.\n", .{}),
            else => try writer.print("Error parsing arguments: {}\n", .{err}),
        }

        try writer.print("Error parsing arguments: {}\n", .{err});

        return;
    };

    // If the help flag is provided, print the help
    // menu and exit.
    if (args.help) {
        return Logger.write_help(std.io.getStdOut().writer());
    }

    var log = Logger.init(allocator, args);
    try log.log(read);
}
