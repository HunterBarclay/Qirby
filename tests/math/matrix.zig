//! Matrix Unit Tests

const std = @import("std");
const qirby = @import("qirby");

const util = @import("../util.zig");

const expect = @import("std").testing.expect;

test "matrix init" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const a = try qirby.math.Matrix(qirby.math.Complex).init(allocator, 4, 4);

    try expect(a.nRows == 4);
    try expect(a.nCols == 4);

    util.print("matrix init passed\n");
}

test "matrix identity" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const ident = try qirby.math.Matrix(qirby.math.Complex).identity(allocator, 4, 4);

    try expect(ident.nRows == 4);
    try expect(ident.nCols == 4);

    const compIdent = qirby.math.Complex.identity();
    const compZero = qirby.math.Complex.zero();

    for (ident.elements.items, 0..) |row, r| {
        for (row.items, 0..) |element, c| {
            if (r == c) {
                try expect(compIdent.eq(element));
            } else {
                try expect(compZero.eq(element));
            }
        }
    }

    util.print("matrix identity passed");
}
