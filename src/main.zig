const std = @import("std");
const utils = @import("utils.zig");
const Logger = @import("logger.zig").Logger;
const Args = @import("args.zig").Args;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var stdin = std.io.getStdIn().reader();

    const read = try stdin.readAllAlloc(allocator, 1024 * 4);
    defer allocator.free(read);

    const args = try Args.parse(allocator);

    var log = Logger.init(allocator, args.level, args.time);
    try log.log(read);
}
