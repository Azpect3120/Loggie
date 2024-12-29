const std = @import("std");
const utils = @import("utils.zig");
const Logger = @import("logger.zig").Logger;
const Args = @import("args.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Get the arguments passed to the program
    const params = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, params);

    // Parse the command line arguments
    const args = Args.Args.parse(allocator, params) catch |err| {
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

    // Read this after the help flag is checked to save time.
    const stdin = std.io.getStdIn();

    // Check if no value was passed into the stdin stream.
    if (stdin.isTty()) {
        return;
    }
    const read = try stdin.reader().readAllAlloc(allocator, 1024 * 4);
    defer allocator.free(read);

    var log = Logger.init(allocator, args);
    try log.log(read, std.io.getStdOut().writer());
}

const expect = std.testing.expect;

test "basic function" {
    const alloc = std.testing.allocator;

    // const test_args = [_][][]u8{
    //     [_][]u8{"loggie"},
    //     [_][]u8{ "loggie", "-t" },
    //     [_][]u8{ "loggie", "-t", "YYYY-MM-DD" },
    // };

    var test_args = [_][]const u8{"loggie"};

    const args = Args.Args.parse(alloc, &test_args) catch unreachable;
    var log = Logger.init(alloc, args);

    var list = std.ArrayList(u8).init(alloc);
    defer list.deinit();

    try log.log("Hello, world!", list.writer());
    try expect(std.mem.eql(u8, list.items, "[INFO] Hello, world!\n"));
    list.clearRetainingCapacity();

    try log.log("[0]Hello, world!", list.writer());
    try expect(std.mem.eql(u8, list.items, "[INFO] Hello, world!\n"));
    list.clearRetainingCapacity();

    try log.log("[1]Hello, world!", list.writer());
    try expect(std.mem.eql(u8, list.items, "[WARN] Hello, world!\n"));
    list.clearRetainingCapacity();

    try log.log("[2]Hello, world!", list.writer());
    try expect(std.mem.eql(u8, list.items, "[ERROR] Hello, world!\n"));
    list.clearRetainingCapacity();

    try log.log("[3]Hello, world!", list.writer());
    try expect(std.mem.eql(u8, list.items, "[DEBUG] Hello, world!\n"));
    list.clearRetainingCapacity();

    try log.log("[5]Hello, world!", list.writer());
    try expect(std.mem.eql(u8, list.items, "[INFO] [5]Hello, world!\n"));
    list.clearRetainingCapacity();

    try log.log("[69420]Hello, world!", list.writer());
    try expect(std.mem.eql(u8, list.items, "[INFO] [69420]Hello, world!\n"));
    list.clearRetainingCapacity();
}

test "parse help flag" {
    const alloc = std.testing.allocator;

    var test_args = [_][]const u8{ "loggie", "-h" };
    const args = Args.Args.parse(alloc, &test_args) catch unreachable;
    var list = std.ArrayList(u8).init(alloc);
    defer list.deinit();

    if (args.help) {
        Logger.write_help(list.writer());
    }

    try expect(std.mem.eql(u8, list.items,
        \\Loggie - A simple, configurable logger written in Zig.
        \\Usage:
        \\  loggie [options]
        \\
        \\Options:
        \\  -h                Show this help menu.
        \\  -l <level>        Set the log level. Levels:
        \\                        0: info
        \\                        1: warn
        \\                        2: error
        \\                        3: debug
        \\  -t [time_fmt]    Include the timestamp in log messages.
        \\                        Optional: Specify a time format (default: "YYYY-MM-DDThh:mm:ss").
        \\
        \\Examples:
        \\  loggie -l info -t
        \\  loggie -l 2 -t "YYYY/MM/DD hh:mm:ss"
        \\  loggie -h
        \\
    ));
}

test "parse level flag" {
    std.debug.print("Test for level flag not implemented yet.\n", .{});
}

test "parse time flag" {
    std.debug.print("Test for time flag not implemented yet.\n", .{});
}
