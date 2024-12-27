const std = @import("std");
const logger = @import("logger.zig").Logger;

pub const Args = struct {
    // Default level to use, if not specified
    // Default: info_e
    level: logger.Level = logger.Level.info_e,

    // Whether to include the time in the log
    // Default: false
    time: bool = false,

    // Create a new instance of the `Args` class
    pub fn init(level: ?logger.Level, time: ?bool) Args {
        return Args{
            .level = level orelse logger.Level.info_e,
            .time = time orelse false,
        };
    }

    // Parse the flags passed into the program
    pub fn parse(alloc: std.mem.Allocator) !Args {
        var args = Args.init(null, null);

        const params = try std.process.argsAlloc(alloc);
        defer std.process.argsFree(alloc, params);

        for (0.., params) |i, arg| {
            std.debug.print("[{d}] {s}\n", .{ i, arg });

            if (std.mem.eql(u8, "-t", arg)) {
                args.time = true;
            }
        }

        return args;
    }
};
