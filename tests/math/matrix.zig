//! Matrix Unit Tests

const std = @import("std");
const qirby = @import("qirby");

const util = @import("../util.zig");

const expect = @import("std").testing.expect;

const MInt = qirby.math.MInt;
const MFloat = qirby.math.MFloat;
const Complex = qirby.math.Complex;

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
    defer ident.deinit();

    try expect(ident.nRows == 4);
    try expect(ident.nCols == 4);

    const compIdent = qirby.math.Complex.identity();
    const compZero = qirby.math.Complex.zero();

    for (ident.elements.items, 0..) |elem, i| {
        if (@divFloor(i, ident.nRows) == @rem(i, ident.nRows)) {
            try expect(compIdent.eq(elem));
        } else {
            try expect(compZero.eq(elem));
        }
    }

    util.print("matrix identity passed\n");
}

test "matrix set all" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var a = try qirby.math.Matrix(MInt).init(allocator, 2, 3);
    defer a.deinit();

    const values = [_]MInt{
        MInt.from(1), MInt.from(2), MInt.from(3),
        MInt.from(4), MInt.from(5), MInt.from(6),
    };
    try a.setAll(values[0..]);

    try expect(a.get(0, 0).value == 1);
    try expect(a.get(0, 1).value == 2);
    try expect(a.get(0, 2).value == 3);
    try expect(a.get(1, 0).value == 4);
    try expect(a.get(1, 1).value == 5);
    try expect(a.get(1, 2).value == 6);

    util.print("matrix set all passed\n");
}

test "matrix mult i32" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var a = try qirby.math.Matrix(MInt).init(allocator, 3, 2);
    defer a.deinit();
    var b = try qirby.math.Matrix(MInt).init(allocator, 2, 4);
    defer b.deinit();

    const valuesA = [_]MInt{
        MInt.from(1), MInt.from(2),
        MInt.from(3), MInt.from(4),
        MInt.from(5), MInt.from(6),
    };
    try a.setAll(valuesA[0..]);

    const valuesB = [_]MInt{
        MInt.from(1), MInt.from(2), MInt.from(3), MInt.from(4),
        MInt.from(5), MInt.from(6), MInt.from(7), MInt.from(8),
    };
    try b.setAll(valuesB[0..]);

    const c = try a.mult(allocator, b);
    defer c.deinit();

    try expect(c.nRows == 3);
    try expect(c.nCols == 4);

    try expect(c.get(0, 0).value == 11);
    try expect(c.get(0, 1).value == 14);
    try expect(c.get(0, 2).value == 17);
    try expect(c.get(0, 3).value == 20);
    try expect(c.get(1, 0).value == 23);
    try expect(c.get(1, 1).value == 30);
    try expect(c.get(1, 2).value == 37);
    try expect(c.get(1, 3).value == 44);
    try expect(c.get(2, 0).value == 35);
    try expect(c.get(2, 1).value == 46);
    try expect(c.get(2, 2).value == 57);
    try expect(c.get(2, 3).value == 68);

    util.print("matrix mult i32 passed\n");
}

test "matrix mult complex [1, 0] * [H]" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var state = try qirby.math.Matrix(Complex).init(allocator, 2, 1);
    defer state.deinit();

    const stateValues = [_]Complex{
        Complex.from(1.0, 0.0),
        Complex.from(0.0, 0.0),
    };
    try state.setAll(stateValues[0..]);

    var hadamard = try qirby.math.Matrix(Complex).init(allocator, 2, 2);
    defer hadamard.deinit();

    const hadamardValues = [_]Complex{
        Complex.from(std.math.sqrt1_2, 0.0), Complex.from(std.math.sqrt1_2, 0.0),
        Complex.from(std.math.sqrt1_2, 0.0), Complex.from(-std.math.sqrt1_2, 0.0),
    };
    try hadamard.setAll(hadamardValues[0..]);

    const out = try hadamard.mult(allocator, state);
    defer out.deinit();

    try expect(out.nRows == 2);
    try expect(out.nCols == 1);

    try expect(out.get(0, 0).eq(Complex.from(std.math.sqrt1_2, 0.0)));
    try expect(out.get(1, 0).eq(Complex.from(std.math.sqrt1_2, 0.0)));

    util.print("matrix mult complex [1, 0] * [H] passed\n");
}

test "matrix tensor [H] x [H]" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var hadamard1 = try qirby.math.Matrix(Complex).init(allocator, 2, 2);
    defer hadamard1.deinit();

    var hadamard2 = try qirby.math.Matrix(Complex).init(allocator, 2, 2);
    defer hadamard2.deinit();

    const hadamardValues = [_]Complex{
        Complex.from(std.math.sqrt1_2, 0.0), Complex.from(std.math.sqrt1_2, 0.0),
        Complex.from(std.math.sqrt1_2, 0.0), Complex.from(-std.math.sqrt1_2, 0.0),
    };
    try hadamard1.setAll(hadamardValues[0..]);
    try hadamard2.setAll(hadamardValues[0..]);

    const h2 = try hadamard1.tensor(allocator, hadamard2);
    defer h2.deinit();

    try expect(h2.nRows == 4);
    try expect(h2.nCols == 4);

    try expect(h2.get(0, 0).eq(Complex.from(0.5, 0.0)));
    try expect(h2.get(0, 1).eq(Complex.from(0.5, 0.0)));
    try expect(h2.get(0, 2).eq(Complex.from(0.5, 0.0)));
    try expect(h2.get(0, 3).eq(Complex.from(0.5, 0.0)));

    try expect(h2.get(1, 0).eq(Complex.from(0.5, 0.0)));
    try expect(h2.get(1, 1).eq(Complex.from(-0.5, 0.0)));
    try expect(h2.get(1, 2).eq(Complex.from(0.5, 0.0)));
    try expect(h2.get(1, 3).eq(Complex.from(-0.5, 0.0)));

    try expect(h2.get(2, 0).eq(Complex.from(0.5, 0.0)));
    try expect(h2.get(2, 1).eq(Complex.from(0.5, 0.0)));
    try expect(h2.get(2, 2).eq(Complex.from(-0.5, 0.0)));
    try expect(h2.get(2, 3).eq(Complex.from(-0.5, 0.0)));

    try expect(h2.get(3, 0).eq(Complex.from(0.5, 0.0)));
    try expect(h2.get(3, 1).eq(Complex.from(-0.5, 0.0)));
    try expect(h2.get(3, 2).eq(Complex.from(-0.5, 0.0)));
    try expect(h2.get(3, 3).eq(Complex.from(0.5, 0.0)));

    h2.debugPrint(allocator, "19");

    util.print("matrix tensor [H] x [H] passed\n");
}
