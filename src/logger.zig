const std = @import("std");
const utils = @import("utils.zig");

pub const Logger = struct {
    base: Level,
    time: bool,
    allocator: std.mem.Allocator,

    pub const Level = enum {
        info_e, // 0
        warn_e, // 1
        error_e, // 2
        debug_e, // 3
    };

    pub fn init(alloc: std.mem.Allocator, level: Level, time: bool) Logger {
        return Logger{
            .allocator = alloc,
            .base = level,
            .time = time,
        };
    }

    // Input: [0]Hello, world!      -> Output: [INFO] Hello, world!
    // Input: [1]Hello, world!      -> Output: [WARN] Hello, world!
    // Input: [2]     Hello, world! -> Output: [ERROR] Hello, world!
    // Input: [3]Hello, world!      -> Output: [DEBUG] Hello, world!
    // Input  Hello, world!         -> Output: [<base>] Hello, world!
    pub fn log(self: *Logger, message: []const u8) !void {
        const writer = std.io.getStdOut().writer();
        if (std.mem.eql(u8, message[0..3], "[0]")) {
            try writer.writeAll("[INFO] ");
        } else if (std.mem.eql(u8, message[0..3], "[1]")) {
            try writer.writeAll("[WARN] ");
        } else if (std.mem.eql(u8, message[0..3], "[2]")) {
            try writer.writeAll("[ERROR] ");
        } else if (std.mem.eql(u8, message[0..3], "[3]")) {
            try writer.writeAll("[DEBUG] ");
        } else {
            switch (self.base) {
                Logger.Level.info_e => try writer.writeAll("[INFO] "),
                Logger.Level.warn_e => try writer.writeAll("[WARN] "),
                Logger.Level.error_e => try writer.writeAll("[ERROR] "),
                Logger.Level.debug_e => try writer.writeAll("[DEBUG] "),
            }
            // Catch cases where the user inputs [n] where n is not a valid level
            // Actually: We will ignore this, in cases where [n] is > 9 or < 0, the
            // parsing will become erroneous. Better to just require the user to use
            // a valid level.
            // if (message[0] == '[' and message[2] == ']') {
            //     try writer.writeAll(utils.trim(message[3..]));
            // } else {
            //     try writer.writeAll(utils.trim(message));
            // }

            try writer.writeAll(utils.trim(message));
            try writer.writeByte('\n');

            return;
        }

        if (self.time) {
            const time = try std.fmt.allocPrint(self.allocator, "[{d}]", .{std.time.milliTimestamp()});
            defer self.allocator.free(time);

            try writer.writeAll(time);
        }

        try writer.writeByte(' ');
        try writer.writeAll(utils.trim(message[3..]));
        try writer.writeByte('\n');
    }
};
