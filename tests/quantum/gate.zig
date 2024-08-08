//!  Quantum Gate testing

const std = @import("std");
const qirby = @import("qirby");

const util = @import("../util.zig");

const expect = @import("std").testing.expect;

const Complex = qirby.math.Complex;
const Gate = qirby.quantum.Gate;
const State = qirby.quantum.State;

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

test "gate hadamard" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const hadamard = try Gate.hadamard(allocator);

    try expect(hadamard.nLanes == 1);
    try expect(hadamard.matrix.nRows == 2);
    try expect(hadamard.matrix.nCols == 2);

    try expect(hadamard.matrix.get(0, 0).eq(Complex.from(std.math.sqrt1_2, 0)));
    try expect(hadamard.matrix.get(0, 1).eq(Complex.from(std.math.sqrt1_2, 0)));
    try expect(hadamard.matrix.get(1, 0).eq(Complex.from(std.math.sqrt1_2, 0)));
    try expect(hadamard.matrix.get(1, 1).eq(Complex.from(-std.math.sqrt1_2, 0)));

    hadamard.matrix.debugPrint(allocator, "18");

    util.print("gate hadamard passed\n");
}

test "gate cx" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const cx = try Gate.cx(allocator);

    try expect(cx.nLanes == 2);
    try expect(cx.matrix.nRows == 4);
    try expect(cx.matrix.nCols == 4);

    const complexIdent = Complex.identity();
    const complexZero = Complex.zero();

    try expect(cx.matrix.get(0, 0).eq(complexIdent));
    try expect(cx.matrix.get(0, 1).eq(complexZero));
    try expect(cx.matrix.get(0, 2).eq(complexZero));
    try expect(cx.matrix.get(0, 3).eq(complexZero));

    try expect(cx.matrix.get(1, 0).eq(complexZero));
    try expect(cx.matrix.get(1, 1).eq(complexIdent));
    try expect(cx.matrix.get(1, 2).eq(complexZero));
    try expect(cx.matrix.get(1, 3).eq(complexZero));

    try expect(cx.matrix.get(2, 0).eq(complexZero));
    try expect(cx.matrix.get(2, 1).eq(complexZero));
    try expect(cx.matrix.get(2, 2).eq(complexZero));
    try expect(cx.matrix.get(2, 3).eq(complexIdent));

    try expect(cx.matrix.get(3, 0).eq(complexZero));
    try expect(cx.matrix.get(3, 1).eq(complexZero));
    try expect(cx.matrix.get(3, 2).eq(complexIdent));
    try expect(cx.matrix.get(3, 3).eq(complexZero));

    cx.matrix.debugPrint(allocator, "18");

    util.print("gate cx passed\n");
}

test "gate create mapping [0 1 2 3 4 5] -> [3 5 1 ...]" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const mapping = [_]usize{ 3, 5, 1 };
    const swapOperators = try Gate.createMapping(allocator, 6, mapping[0..]);

    const compIdentity = Complex.identity();
    const compZero = Complex.zero();

    var s = try State.init(allocator, 6);
    s.matrix.set(0, 0, compZero);
    s.matrix.set(21, 0, compIdentity);

    // Swap qubits and verify order
    {
        const g = try Gate.from(6, swapOperators.to);
        try s.applyGate(allocator, g);

        var stateRow: usize = 0;
        while (stateRow < s.matrix.nRows) : (stateRow += 1) {
            if (stateRow == 56) {
                try expect(s.matrix.get(stateRow, 0).eq(compIdentity));
            } else {
                try expect(s.matrix.get(stateRow, 0).eq(compZero));
            }
        }
    }

    // Unswap qubits and verify order
    {
        const g = try Gate.from(6, swapOperators.from);
        try s.applyGate(allocator, g);

        var stateRow: usize = 0;
        while (stateRow < s.matrix.nRows) : (stateRow += 1) {
            if (stateRow == 21) {
                try expect(s.matrix.get(stateRow, 0).eq(compIdentity));
            } else {
                try expect(s.matrix.get(stateRow, 0).eq(compZero));
            }
        }
    }

    // Verify Unitary
    const ident = try swapOperators.from.mult(allocator, swapOperators.to);
    // ident.debugPrint(allocator, "14");

    var r: usize = 0;
    while (r < ident.nRows) : (r += 1) {
        var c: usize = 0;
        while (c < ident.nCols) : (c += 1) {
            if (r == c) {
                try expect(ident.get(r, c).eq(compIdentity));
            } else {
                try expect(ident.get(r, c).eq(compZero));
            }
        }
    }

    util.print("gate create mapping [0 1 2 3 4 5] -> [3 5 1 ...] passed\n");
}
