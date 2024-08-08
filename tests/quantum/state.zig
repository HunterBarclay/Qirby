//!  Quantum State testing

const std = @import("std");
const qirby = @import("qirby");

const util = @import("../util.zig");

const expect = @import("std").testing.expect;

const Complex = qirby.math.Complex;
const Gate = qirby.quantum.Gate;
const State = qirby.quantum.State;

test "state init" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const s = try State.init(allocator, 1);

    try expect(s.nLanes == 1);
    try expect(s.nPossibilities == 2);

    try util.expectF32(1.0, try s.sampleStatePossibility(0));
    try util.expectF32(0.0, try s.sampleStatePossibility(1));

    // s.matrix.debugPrint(allocator, "18");

    util.print("state init passed\n");
}

test "state X" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var s = try State.init(allocator, 1);
    try s.applyGate(allocator, try Gate.pauliX(allocator));

    try expect(s.nLanes == 1);
    try expect(s.nPossibilities == 2);

    try util.expectF32(0.0, try s.sampleStatePossibility(0));
    try util.expectF32(1.0, try s.sampleStatePossibility(1));

    // s.matrix.debugPrint(allocator, "18");

    util.print("state X passed\n");
}

test "state H" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var s = try State.init(allocator, 1);

    // s.matrix.debugPrint(allocator, "18");

    try s.applyGate(allocator, try Gate.hadamard(allocator));

    try expect(s.nLanes == 1);
    try expect(s.nPossibilities == 2);

    try util.expectF32(0.5, try s.sampleStatePossibility(0));
    try util.expectF32(0.5, try s.sampleStatePossibility(1));

    try expect(s.matrix.get(0, 0).eq(Complex.from(std.math.sqrt1_2, 0.0)));
    try expect(s.matrix.get(1, 0).eq(Complex.from(std.math.sqrt1_2, 0.0)));

    // s.matrix.debugPrint(allocator, "18");

    util.print("state H passed\n");
}

test "state X H" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var s = try State.init(allocator, 1);

    // s.matrix.debugPrint(allocator, "18");

    try s.applyGate(allocator, try Gate.pauliX(allocator));
    try s.applyGate(allocator, try Gate.hadamard(allocator));

    try expect(s.nLanes == 1);
    try expect(s.nPossibilities == 2);

    try util.expectF32(0.5, try s.sampleStatePossibility(0));
    try util.expectF32(0.5, try s.sampleStatePossibility(1));

    try expect(s.matrix.get(0, 0).eq(Complex.from(std.math.sqrt1_2, 0.0)));
    try expect(s.matrix.get(1, 0).eq(Complex.from(-std.math.sqrt1_2, 0.0)));

    // s.matrix.debugPrint(allocator, "18");

    util.print("state X H passed\n");
}
