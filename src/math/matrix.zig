//! Matrix for Qirby
//! TODO:
//! - Bound checks for get/set

const std = @import("std");
const assert = std.debug.assert;

pub const MatrixError = error{
    MisMatchedDimensions,
};

pub const print = std.debug.print;

pub fn Matrix(comptime T: type) type {
    comptime {
        assert(std.meta.hasMethod(T, "init"));
        assert(std.meta.hasMethod(T, "identity"));
        assert(std.meta.hasMethod(T, "zero"));
        assert(std.meta.hasMethod(T, "makeIdentity"));
        assert(std.meta.hasMethod(T, "mutAdd"));
        assert(std.meta.hasMethod(T, "mutMult"));
        assert(std.meta.hasMethod(T, "clone"));
        assert(std.meta.hasMethod(T, "toString"));
    }

    return struct {
        const Self = @This();

        elements: std.ArrayList(T),
        nRows: usize,
        nCols: usize,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator, nRows: usize, nCols: usize) !Self {
            assert(nRows > 0);
            assert(nCols > 0);

            var elems = try std.ArrayList(T).initCapacity(allocator, nRows * nCols);

            var r: usize = 0;
            while (r < elems.capacity) : (r += 1) {
                try elems.append(T.zero());
            }
            return Self{
                .elements = elems,
                .nRows = nRows,
                .nCols = nCols,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: Self) void {
            self.elements.deinit();
        }

        pub fn setAll(self: *Self, all: []const T) !void {
            assert(all.len == self.elements.items.len);

            for (all, 0..) |elem, i| {
                self.elements.items[i] = elem;
            }
        }

        pub inline fn get(self: *const Self, r: usize, c: usize) *const T {
            return &self.elements.items[r * self.nCols + c];
        }

        pub inline fn getMut(self: *Self, r: usize, c: usize) *T {
            return &self.elements.items[r * self.nCols + c];
        }

        pub inline fn set(self: *Self, r: usize, c: usize, val: T) void {
            self.elements.items[r * self.nCols + c] = val;
        }

        pub fn mult(self: Self, allocator: std.mem.Allocator, b: Matrix(T)) !Matrix(T) {
            assert(self.nCols == b.nRows);

            var resMatrix = try Matrix(T).init(allocator, self.nRows, b.nCols);

            var aRow: usize = 0;
            var tmpMult: T = T.identity();
            while (aRow < self.nRows) : (aRow += 1) {
                var bCol: usize = 0;
                while (bCol < b.nCols) : (bCol += 1) {
                    var prodSum: T = T.zero();
                    var sharedDim: usize = 0;
                    while (sharedDim < self.nCols) : (sharedDim += 1) {
                        _ = tmpMult.mutMult(self.get(aRow, sharedDim).*);
                        _ = tmpMult.mutMult(b.get(sharedDim, bCol).*);
                        _ = prodSum.mutAdd(tmpMult);
                        tmpMult.makeIdentity();
                    }
                    resMatrix.set(aRow, bCol, prodSum);
                }
            }

            return resMatrix;
        }

        pub fn tensor(self: Self, allocator: std.mem.Allocator, b: Matrix(T)) !Matrix(T) {
            // Not really a pure tensor, but works for my use case so its fine.
            // I'll be going with the simple solution.
            assert(self.nCols == self.nRows);
            assert(b.nCols == b.nRows);

            const size = self.nRows * b.nRows;
            var resMatrix = try Matrix(T).init(allocator, size, size);
            var aRow: usize = 0;
            // NASTY... yet depending on which variable you choose, this is actually O(n) which makes me want to vomit.
            while (aRow < self.nRows) : (aRow += 1) {
                var aCol: usize = 0;
                while (aCol < self.nCols) : (aCol += 1) {
                    const aValue = self.get(aRow, aCol);
                    var bRow: usize = 0;
                    while (bRow < b.nRows) : (bRow += 1) {
                        var bCol: usize = 0;
                        while (bCol < b.nCols) : (bCol += 1) {
                            var insertValue = aValue.clone();
                            _ = insertValue.mutMult(b.get(bRow, bCol).*);
                            resMatrix.set(aRow * b.nRows + bRow, aCol * b.nCols + bCol, insertValue);
                        }
                    }
                }
            }

            return resMatrix;
        }

        pub fn identity(allocator: std.mem.Allocator, nRows: usize, nCols: usize) !Self {
            assert(nRows == nCols);

            var m = try Self.init(allocator, nRows, nCols);

            var i: usize = 0;
            while (i < nRows) : (i += 1) {
                m.set(i, i, T.identity());
            }

            return m;
        }

        pub fn debugPrint(self: Self, allocator: std.mem.Allocator, comptime elementStride: []const u8) void {
            print("==== START MATRIX ====\n", .{});
            var r: usize = 0;
            while (r < self.nRows) : (r += 1) {
                var c: usize = 0;
                while (c < self.nCols) : (c += 1) {
                    print("{s:>" ++ elementStride ++ "},", .{self.get(r, c).toString(allocator)});
                }
                print("\n", .{});
            }
            print("==== END MATRIX ====\n", .{});
        }
    };
}

fn MatrixScalar(comptime T: type, toStr: fn (T, std.mem.Allocator) []const u8) type {
    return struct {
        const Self = @This();

        value: T,

        pub fn init() Self {
            return .{ .value = 0 };
        }

        pub fn from(val: T) Self {
            return .{ .value = val };
        }

        pub fn identity() Self {
            return .{ .value = 1 };
        }

        pub fn zero() Self {
            return .{ .value = 0 };
        }

        pub fn makeIdentity(self: *Self) void {
            self.value = 1;
        }

        pub fn mutAdd(self: *Self, b: Self) *Self {
            self.value += b.value;
            return self;
        }

        pub fn mutMult(self: *Self, b: Self) *Self {
            self.value *= b.value;
            return self;
        }

        pub fn clone(self: Self) Self {
            return Self{ .value = self.value };
        }

        pub fn toString(self: Self, allocator: std.mem.Allocator) []const u8 {
            return toStr(self.value, allocator);
        }
    };
}

pub const MFloat = MatrixScalar(f32, struct {
    pub fn toStr(v: f32, allocator: std.mem.Allocator) []const u8 {
        return std.fmt.allocPrint(allocator, "{d}", v) catch "ERR";
    }
}.toStr);

pub const MInt = MatrixScalar(i32, struct {
    pub fn toStr(v: i32, allocator: std.mem.Allocator) []const u8 {
        return std.fmt.allocPrint(allocator, "{d}", v) catch "ERR";
    }
}.toStr);

// Verify QiMatrixScalars are compatible.

comptime {
    _ = Matrix(MFloat);
    _ = Matrix(MInt);
}
