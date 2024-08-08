const std = @import("std");
const qirby = @import("qirby");

const util = @import("../util.zig");

const expect = @import("std").testing.expect;

const Complex = qirby.math.Complex;
const Gate = qirby.quantum.Gate;
const State = qirby.quantum.State;
const Circuit = qirby.quantum.Circuit;

test "circuit init" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const c = try Circuit.init(allocator, 2);
    _ = c;

    util.print("circuit init\n");
}

test "circuit amp [11]" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var c = try Circuit.init(allocator, 2);

    try c.addGate(allocator, try Gate.hadamard(allocator), &[_]usize{0});
    try c.addGate(allocator, try Gate.hadamard(allocator), &[_]usize{1});

    try c.addGate(allocator, try Gate.cz(allocator), null);

    try c.addGate(allocator, try Gate.hadamard(allocator), &[_]usize{0});
    try c.addGate(allocator, try Gate.hadamard(allocator), &[_]usize{1});
    try c.addGate(allocator, try Gate.cz(allocator), null);
    try c.addGate(allocator, try Gate.pauliZ(allocator), &[_]usize{0});
    try c.addGate(allocator, try Gate.pauliZ(allocator), &[_]usize{1});
    try c.addGate(allocator, try Gate.hadamard(allocator), &[_]usize{0});
    try c.addGate(allocator, try Gate.hadamard(allocator), &[_]usize{1});

    try c.compile(allocator);

    var state = try State.init(allocator, 2);
    try c.run(allocator, &state);

    try util.expectF32(0.0, try state.sampleStatePossibility(0));
    try util.expectF32(0.0, try state.sampleStatePossibility(1));
    try util.expectF32(0.0, try state.sampleStatePossibility(2));
    try util.expectF32(1.0, try state.sampleStatePossibility(3));

    util.print("circuit init\n");
}
