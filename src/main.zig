//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");

const qirby = @import("qirby");

const Circuit = qirby.quantum.Circuit;
const Gate = qirby.quantum.Gate;
const State = qirby.quantum.State;

const util = qirby.util;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    var c = try Circuit.init(allocator, 12);

    util.print("Gate:  0 / 10\n");
    try c.addGate(allocator, try Gate.hadamard(allocator), &[_]usize{0});
    util.print("Gate:  1 / 10\n");
    try c.addGate(allocator, try Gate.hadamard(allocator), &[_]usize{1});
    util.print("Gate:  2 / 10\n");

    try c.addGate(allocator, try Gate.cz(allocator), null);
    util.print("Gate:  3 / 10\n");

    try c.addGate(allocator, try Gate.hadamard(allocator), &[_]usize{0});
    util.print("Gate:  4 / 10\n");
    try c.addGate(allocator, try Gate.hadamard(allocator), &[_]usize{1});
    util.print("Gate:  5 / 10\n");
    try c.addGate(allocator, try Gate.cz(allocator), null);
    util.print("Gate:  6 / 10\n");
    try c.addGate(allocator, try Gate.pauliZ(allocator), &[_]usize{0});
    util.print("Gate:  7 / 10\n");
    try c.addGate(allocator, try Gate.pauliZ(allocator), &[_]usize{1});
    util.print("Gate:  8 / 10\n");
    try c.addGate(allocator, try Gate.hadamard(allocator), &[_]usize{0});
    util.print("Gate:  9 / 10\n");
    try c.addGate(allocator, try Gate.hadamard(allocator), &[_]usize{1});
    util.print("Gate: 10 / 10\n");

    util.print("Compiling...\n");
    try c.compile(allocator);
    util.print("Compilation complete.\n");

    var state = try State.init(allocator, 12);
    try c.run(allocator, &state);

    try util.expectF32(0.0, try state.sampleStatePossibility(0b000000000000));
    try util.expectF32(0.0, try state.sampleStatePossibility(0b010000000000));
    try util.expectF32(0.0, try state.sampleStatePossibility(0b100000000000));
    try util.expectF32(1.0, try state.sampleStatePossibility(0b110000000000));

    util.print("Results nominal.");
    state.matrix.debugPrint(allocator, "18");
}
