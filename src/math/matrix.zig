//! Matrix for Qirby

const std = @import("std");
const assert = std.debug.assert;

pub fn Matrix(comptime T: type, R: usize, C: usize) type {
    comptime {
        assert(std.meta.hasMethod(T, "init"));
        assert(std.meta.hasMethod(T, "identity"));
        assert(std.meta.hasMethod(T, "zero"));
        assert(std.meta.hasMethod(T, "add"));
        assert(std.meta.hasMethod(T, "mult"));
        assert(std.meta.hasMethod(T, "toString"));
    }

    return struct {
        pub const numCols = C;
        pub const numRows = R;
        const Self = @This();

        elements: [R][C]T,

        pub fn init() Self {
            return Self{
                .elements = .{.{T.zero()} ** C} ** R,
            };
        }

        pub fn get(self: *const Self, r: usize, c: usize) *const T {
            return &self.elements[r][c];
        }

        pub fn getMut(self: *Self, r: usize, c: usize) *T {
            return &self.elements[r][c];
        }

        pub fn set(self: *Self, r: usize, c: usize, val: T) void {
            self.elements[r][c] = val;
        }

        pub fn getNumCols(self: Self) usize {
            _ = self;
            return Self.numCols;
        }

        pub fn getNumRows(self: Self) usize {
            _ = self;
            return Self.numRows;
        }

        pub const identity: Self = blk: {
            var m = Self.init();

            // Weird indexing practice to avoid overflow and respect bounds of usize.
            var i = (if (R < C) R else C);
            while (i > 0) {
                i -= 1;
                m.set(i, i, T.identity());
            }

            break :blk m;
        };
    };
}

fn QiMatrixScalar(comptime T: type, toStr: fn (T, std.mem.Allocator) []const u8) type {
    return struct {
        const Self = @This();

        value: T,

        pub fn init() Self {
            return .{ .value = 0.0 };
        }

        pub fn identity() Self {
            return .{ .value = 1.0 };
        }

        pub fn zero() Self {
            return .{ .value = 0.0 };
        }

        pub fn add(self: Self, b: Self) Self {
            return .{ .value = self.value + b.value };
        }

        pub fn mult(self: Self, b: Self) Self {
            return .{ .value = self.value * b.value };
        }

        pub fn toString(self: Self, allocator: std.mem.Allocator) []const u8 {
            return toStr(self.value, allocator);
        }
    };
}

pub const QiF32 = QiMatrixScalar(f32, struct {
    pub fn toStr(v: f32, allocator: std.mem.Allocator) []const u8 {
        return std.fmt.allocPrint(allocator, "{d}", v) catch "ERR";
    }
}.toStr);

pub const QiI32 = QiMatrixScalar(i32, struct {
    pub fn toStr(v: i32, allocator: std.mem.Allocator) []const u8 {
        return std.fmt.allocPrint(allocator, "{d}", v) catch "ERR";
    }
}.toStr);
