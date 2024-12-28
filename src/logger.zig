const std = @import("std");
const utils = @import("utils.zig");
const Args = @import("args.zig").Args;
const Time = @import("./libs/zig-time/time.zig");

pub const Logger = struct {
    // The base level to use when the message
    // does not include a level prefix
    // Default: info
    base: Level = Level.info_e,

    // Should the time be included in the
    // log message
    // Default: false
    time: bool = false,

    // The format to use when displaying the
    // time in the log message. Only applied
    // when the `time` flag is set to true
    // Default: "YYYY-MM-DDThh:mm:ss"
    time_fmt: []const u8 = "YYYY-MM-DDThh:mm:ss",

    // Allocator to use when allocating memory.
    // This is required to be passed in as the
    // logger will need to allocate memory for
    // writing
    allocator: std.mem.Allocator,

    // Level that that can be used in the log
    pub const Level = enum {
        info_e, // 0
        warn_e, // 1
        error_e, // 2
        debug_e, // 3
    };

    pub fn init(alloc: std.mem.Allocator, args: Args) Logger {
        return Logger{
            .allocator = alloc,
            .base = args.level,
            .time = args.time,
            .time_fmt = args.time_fmt,
        };
    }

    // Example I/O for the log function:
    // -------------------------------------------------------------------------
    // Input: [0]Hello, world!       -> Output: [INFO] Hello, world!
    // Input: [1]Hello, world!       -> Output: [WARN] Hello, world!
    // Input: [2]     Hello, world!  -> Output: [ERROR] Hello, world!
    // Input: [3]Hello, world!       -> Output: [DEBUG] Hello, world!
    // Input: [n]Hello, world!       -> Output: [<base>] [n]Hello, world!
    // Input: [n] Hello, world!      -> Output: [<base>] [n] Hello, world!
    // Input: [n]      Hello, world! -> Output: [<base>] [n]      Hello, world!
    // Input  Hello, world!          -> Output: [<base>] Hello, world!
    // -------------------------------------------------------------------------
    pub fn log(self: *Logger, message: []const u8) !void {
        const writer = std.io.getStdOut().writer();
        if (std.mem.eql(u8, message[0..3], "[0]")) {
            writer.writeAll("[INFO] ") catch unreachable;
        } else if (std.mem.eql(u8, message[0..3], "[1]")) {
            writer.writeAll("[WARN] ") catch unreachable;
        } else if (std.mem.eql(u8, message[0..3], "[2]")) {
            writer.writeAll("[ERROR] ") catch unreachable;
        } else if (std.mem.eql(u8, message[0..3], "[3]")) {
            writer.writeAll("[DEBUG] ") catch unreachable;
        } else {
            // Nothing was provided, use the base level
            switch (self.base) {
                Logger.Level.info_e => try writer.writeAll("[INFO] "),
                Logger.Level.warn_e => try writer.writeAll("[WARN] "),
                Logger.Level.error_e => try writer.writeAll("[ERROR] "),
                Logger.Level.debug_e => try writer.writeAll("[DEBUG] "),
            }

            try self.write_time(writer);

            // Write message and append a newline character
            writer.writeAll(utils.trim(message)) catch unreachable;
            writer.writeByte('\n') catch unreachable;

            return;
        }

        try self.write_time(writer);

        // Write message and append a newline character
        writer.writeAll(utils.trim(message[3..])) catch unreachable;
        writer.writeByte('\n') catch unreachable;
    }

    // Helper function to write the time to the log
    // Will only run when the `time` flag is set to true
    // This function will only error out if the allocation
    // fails in some way.
    //
    // The time is always printed in UTC time.
    fn write_time(self: *Logger, writer: anytype) !void {
        if (self.time) {
            // Default time is in the format of: YYYY-MM-DDThh:mm:ss
            // Which is defined in the ISO 8601 standard
            //
            // WIP: Cannot use the `formatAlloc` with a value not known
            // at compile time. Need to find a way around this, for now
            // the default time format will be used while the value is
            // still captured from the args.
            const time = try Time.DateTime.now().formatAlloc(self.allocator, "YYYY-MM-DDThh:mm:ss");
            defer self.allocator.free(time);
            writer.writeAll("[") catch unreachable;
            writer.writeAll(time) catch unreachable;
            writer.writeAll("] ") catch unreachable;
        }
    }

    // Write the help menu to the writer provided.
    // This function will not error out as it is
    // a very rare case where a stdout write fails.
    pub fn write_help(writer: anytype) void {
        writer.print(
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
        ,
            .{},
        ) catch unreachable;
    }
};
