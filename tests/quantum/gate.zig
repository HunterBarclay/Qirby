//!  Quantum Gate testing

const std = @import("std");
const qirby = @import("qirby");

const util = @import("../util.zig");

const expect = @import("std").testing.expect;

const Complex = qirby.math.Complex;
const Gate = qirby.quantum.Gate;

test "gate init" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const values = [_]Complex{
        Complex.identity(), Complex.zero(),
        Complex.zero(),     Complex.identity(),
    };
    const ident = try Gate.init(allocator, 1, values[0..]);

    try expect(ident.nLanes == 1);
    try expect(ident.matrix.nRows == 2);
    try expect(ident.matrix.nCols == 2);

    ident.matrix.debugPrint(allocator, "18");

    util.print("gate init passed\n");
}

test "gate from" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var hadamard = try qirby.math.Matrix(Complex).init(allocator, 2, 2);
    defer hadamard.deinit();

    const hadamardValues = [_]Complex{
        Complex.from(std.math.sqrt1_2, 0.0), Complex.from(std.math.sqrt1_2, 0.0),
        Complex.from(std.math.sqrt1_2, 0.0), Complex.from(-std.math.sqrt1_2, 0.0),
    };
    try hadamard.setAll(hadamardValues[0..]);
    const hGate = try Gate.from(1, hadamard);

    try expect(hGate.nLanes == 1);
    try expect(hGate.matrix.nRows == 2);
    try expect(hGate.matrix.nCols == 2);

    hGate.matrix.debugPrint(allocator, "18");

    util.print("gate from passed\n");
}

test "gate identity" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const ident = try Gate.identity(allocator);

    try expect(ident.nLanes == 1);
    try expect(ident.matrix.nRows == 2);
    try expect(ident.matrix.nCols == 2);

    const complexIdent = Complex.identity();
    const complexZero = Complex.zero();

    try expect(ident.matrix.get(0, 0).eq(complexIdent));
    try expect(ident.matrix.get(0, 1).eq(complexZero));
    try expect(ident.matrix.get(1, 0).eq(complexZero));
    try expect(ident.matrix.get(1, 1).eq(complexIdent));

    ident.matrix.debugPrint(allocator, "18");

    util.print("gate identity passed\n");
}

test "gate identity 5" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const ident = try Gate.identityN(allocator, 5);

    try expect(ident.nLanes == 5);
    try expect(ident.matrix.nRows == 32);
    try expect(ident.matrix.nCols == 32);

    const complexIdent = Complex.identity();
    const complexZero = Complex.zero();

    var r: usize = 0;
    while (r < 32) : (r += 1) {
        var c: usize = 0;
        while (c < 32) : (c += 1) {
            if (r == c) {
                try expect(ident.matrix.get(r, c).eq(complexIdent));
            } else {
                try expect(ident.matrix.get(r, c).eq(complexZero));
            }
        }
    }

    util.print("gate identity 5 passed\n");
}
