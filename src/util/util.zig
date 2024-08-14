pub const UsizeContext = struct {
    pub fn hash(self: UsizeContext, a: usize) u32 {
        _ = self;
        return @intCast(a);
    }

    pub fn eql(self: UsizeContext, a: usize, b: usize) bool {
        _ = self;
        return a == b;
    }
};

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
