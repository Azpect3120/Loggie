const std = @import("std");
const logger = @import("logger.zig").Logger;

pub const ParserError = error{
    MissingLevel,
    InvalidLevel,
};

pub const Args = struct {
    // Default level to use, if not specified
    // Default: info_e
    level: logger.Level = logger.Level.info_e,

    // Whether to include the time in the log
    // Default: false
    time: bool = false,

    // The time format that should be used
    // Default: "YYYY-MM-DDThh:mm:ss"
    time_fmt: []const u8 = "YYYY-MM-DDThh:mm:ss",

    // Whether to display the help menu
    // All other functions will be ignored when
    // this flag is set
    // Default: false
    help: bool = false,

    // Create a new instance of the `Args` class
    pub fn init(level: ?logger.Level, time: ?bool) Args {
        return Args{
            .level = level orelse logger.Level.info_e,
            .time = time orelse false,
        };
    }

    // Parse the flags passed into the program
    pub fn parse(alloc: std.mem.Allocator, params: [][]const u8) !Args {
        var args = Args.init(null, null);

        for (0.., params) |i, arg| {
            // std.debug.print("[{d}] {s}\n", .{ i, arg });

            // Current parameter is the `help` flag
            if (std.mem.eql(u8, "-h", arg)) {
                args.help = true;
                return args;
            }

            // Current parameter is the `time` flag
            // Next parameter should be the desired time format
            // However, the time flag does not require a parameter
            if (std.mem.eql(u8, "-t", arg)) {
                // std.debug.print("Setting time to true\n", .{});
                args.time = true;

                // Not enough parameters left to check for the time format
                // Will use default time format
                // Default: "YYYY-MM-DDThh:mm:ss" (ISO 8601)
                // Example: "2021-07-01T12:00:00"
                if (i > params.len) {
                    // std.debug.print("No time format specified.\n", .{});
                    continue;
                }

                // Next parameter MIGHT be the desired time format
                // However, it could also be another flag
                // If it is another flag, the time format will be ignored
                // But first, check if anything follows the time flag
                if (i + 1 >= params.len) {
                    // std.debug.print("No time format specified. Nothing follows the time flag.\n", .{});
                    continue;
                } else if (params[i + 1][0] == '-') {
                    // std.debug.print("No time format specified. A flag follows the time flag.\n", .{});
                    continue;
                }

                // A time format was specified
                // Capture the format and use it in the log
                args.time_fmt = params[i + 1];
                // std.debug.print("Setting time format to '{s}'\n", .{args.time_fmt});
            }

            // Current parameter is the `level` flag
            // Next parameter should be the desired level
            if (std.mem.eql(u8, "-l", arg)) {
                if (i + 1 >= params.len) {
                    // Shoot an error: "No level specified"
                    return ParserError.MissingLevel;
                }

                // Ensure the next parameter is not a flag
                // If it is, this function will error and
                // the program will exit.
                if (params[i + 1][0] == '-') {
                    // Shoot an error: "No level specified"
                    return ParserError.MissingLevel;
                }

                // A single character was passed
                // Should be a numeric value: 0..3
                if (params[i + 1].len == 1) {
                    if (params[i + 1][0] == '0') {
                        args.level = logger.Level.info_e;
                    } else if (params[i + 1][0] == '1') {
                        args.level = logger.Level.warn_e;
                    } else if (params[i + 1][0] == '2') {
                        args.level = logger.Level.error_e;
                    } else if (params[i + 1][0] == '3') {
                        args.level = logger.Level.debug_e;
                    } else {
                        // Shoot an error: "Invalid level specified"
                        return ParserError.InvalidLevel;
                    }
                    // More than a single character was passed
                    // Should be a string value: info, warn, error, debug
                } else {
                    const level: []u8 = try std.ascii.allocLowerString(alloc, params[i + 1]);
                    defer alloc.free(level);

                    if (std.mem.eql(u8, level, "info")) {
                        args.level = logger.Level.info_e;
                    } else if (std.mem.eql(u8, level, "warn")) {
                        args.level = logger.Level.warn_e;
                    } else if (std.mem.eql(u8, level, "error")) {
                        args.level = logger.Level.error_e;
                    } else if (std.mem.eql(u8, level, "debug")) {
                        args.level = logger.Level.debug_e;
                    } else {
                        // Shoot an error: "Invalid level specified"
                        return ParserError.InvalidLevel;
                    }
                }
            }
        }

        return args;
    }
};
