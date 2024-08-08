const std = @import("std");
const qirby = @import("qirby");

const util = @import("../util.zig");

const expect = @import("std").testing.expect;

const Complex = qirby.math.Complex;
const Gate = qirby.quantum.Gate;
const State = qirby.quantum.State;
const Circuit = qirby.quantum.Circuit;

test "circuit create mapping [0 1 2 3 4 5] -> [3 5 1 ...]" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const mapping = [_]usize{ 3, 5, 1 };
    const swapOperators = try Circuit.createMapping(allocator, 6, mapping[0..]);

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

    util.print("circuit create mapping [0 1 2 3 4 5] -> [3 5 1 ...]\n");
}
