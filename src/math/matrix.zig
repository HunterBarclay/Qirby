//! Matrix for Qirby

const std = @import("std");
const assert = std.debug.assert;

pub const MatrixError = error{
    MisMatchedDimensions,
};

pub fn Matrix(comptime T: type) type {
    comptime {
        assert(std.meta.hasMethod(T, "init"));
        assert(std.meta.hasMethod(T, "identity"));
        assert(std.meta.hasMethod(T, "zero"));
        assert(std.meta.hasMethod(T, "add"));
        assert(std.meta.hasMethod(T, "mult"));
        assert(std.meta.hasMethod(T, "toString"));
    }

    return struct {
        const Self = @This();

        elements: std.ArrayList(std.ArrayList(T)),
        nRows: usize,
        nCols: usize,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, nRows: usize, nCols: usize) !Self {
            var elems = try std.ArrayList(std.ArrayList(T)).initCapacity(allocator, nRows);

            var r: usize = 0;
            while (r < nRows) : (r += 1) {
                var row = try std.ArrayList(T).initCapacity(allocator, nCols);
                var c: usize = 0;
                while (c < nCols) : (c += 1) {
                    try row.append(T.zero());
                }
                try elems.append(row);
            }
            return Self{
                .elements = elems,
                .nRows = nRows,
                .nCols = nCols,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: Self) void {
            for (self.elements.items) |row| {
                row.deinit();
            }
            self.elements.deinit();
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

        // pub fn mult(self: Self, b: anytype, resType: T) MatrixError!T {
        //     return try blk: {
        //         break :blk .{};
        //     } catch MatrixError.MisMatchedDimensions;
        // }

        pub fn identity(allocator: std.mem.Allocator, nRows: usize, nCols: usize) !Self {
            assert(nRows == nCols);

            const m = try Self.init(allocator, nRows, nCols);

            var i: usize = 0;
            while (i < nRows) : (i += 1) {
                m.elements.items[i].items[i] = T.identity();
            }

            return m;
        }
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
