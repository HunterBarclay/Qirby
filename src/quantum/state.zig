const std = @import("std");
const assert = std.debug.assert;

const qMath = @import("../math/mod.zig");

const Complex = qMath.Complex;
const Matrix = qMath.Matrix(Complex);

const Gate = @import("gate.zig").Gate;

pub const State = struct {
    nLanes: usize,
    nPossibilities: usize,
    matrix: Matrix,

    pub fn init(allocator: std.mem.Allocator, nLanes: usize) !State {
        const size = std.math.pow(usize, 2, nLanes);

        var mat = try Matrix.init(allocator, size, 1);
        mat.set(0, 0, Complex.identity());

        return State{
            .nLanes = nLanes,
            .matrix = mat,
            .nPossibilities = size,
        };
    }

    pub fn deinit(self: State) void {
        self.matrix.deinit();
    }

    pub fn applyGate(self: *State, allocator: std.mem.Allocator, gate: Gate) !void {
        self.matrix = try gate.matrix.mult(allocator, self.matrix);

        assert(self.matrix.nRows == self.nPossibilities);
        assert(self.matrix.nCols == 1);
    }

    /// By structuring the qubits in bit format, the first qubit being the most significant, specify a state in this bit format
    /// Example:
    ///     To get the possibility of a 00, specify state = 0
    ///     To get the possibility of a 11, specify state = 3
    ///     To get the possibility of 1011, specify state = 11
    pub fn sampleStatePossibility(self: State, state: usize) !f32 {
        assert(state < self.nPossibilities);

        const val = self.matrix.get(state, 0);
        return std.math.pow(f32, val.getMagnitude(), 2.0);
    }
};
