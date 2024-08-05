const std = @import("std");

pub const epsilon = 0.0001;

pub fn print(comptime msg: []const u8) void {
    std.debug.print(msg, .{});
}

pub fn printf(comptime fmt: []const u8, args: anytype) void {
    std.debug.print(fmt, args);
}

pub fn expectF32(expected: f32, actual: f32) !void {
    try std.testing.expectApproxEqAbs(expected, actual, epsilon);
}
