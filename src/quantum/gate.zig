const std = @import("std");
const assert = std.debug.assert;

const qMath = @import("../math/mod.zig");
const Complex = qMath.Complex;
const Matrix = qMath.Matrix(Complex);

pub const Gate = struct {
    matrix: Matrix,
    nLanes: usize,

    /// nLanes: Number of qubits this gate is for.
    /// all: Elements of the gate. Should have 2^(2 * nLanes) elements in it.
    pub fn init(allocator: std.mem.Allocator, nLanes: usize, all: []const Complex) !Gate {
        const stateSize = std.math.pow(usize, 2, nLanes);
        assert(all.len == stateSize *| stateSize);

        var mat = try Matrix.init(allocator, stateSize, stateSize);
        try mat.setAll(all);

        return Gate{
            .matrix = mat,
            .nLanes = nLanes,
        };
    }

    pub fn from(nLanes: usize, mat: Matrix) !Gate {
        const stateSize = std.math.pow(usize, 2, nLanes);
        assert(mat.nRows == stateSize);
        assert(mat.nCols == stateSize);

        return Gate{
            .matrix = mat,
            .nLanes = nLanes,
        };
    }

    pub fn deinit(self: Gate) void {
        self.matrix.deinit();
    }

    // Operations

    pub fn tensor(self: Gate, allocator: std.mem.Allocator, b: Gate) !Gate {
        return Gate{ .matrix = try self.matrix.tensor(allocator, b.matrix), .nLanes = self.nLanes + b.nLanes };
    }

    // Standard Gates
    pub fn identity(allocator: std.mem.Allocator) !Gate {
        const values = [_]Complex{
            Complex.identity(), Complex.zero(),
            Complex.zero(),     Complex.identity(),
        };
        const g = try Gate.init(allocator, 1, values[0..]);
        return g;
    }

    pub fn identityN(allocator: std.mem.Allocator, nLanes: usize) !Gate {
        var gate = try Gate.identity(allocator);
        var i: usize = 1;
        while (i < nLanes) : (i += 1) {
            gate = try gate.tensor(allocator, try Gate.identity(allocator));
        }

        return gate;
    }

    pub fn hadamard(allocator: std.mem.Allocator) !Gate {
        const hadamardValues = [_]Complex{
            Complex.from(std.math.sqrt1_2, 0.0), Complex.from(std.math.sqrt1_2, 0.0),
            Complex.from(std.math.sqrt1_2, 0.0), Complex.from(-std.math.sqrt1_2, 0.0),
        };
        const g = try Gate.init(allocator, 1, hadamardValues[0..]);
        return g;
    }

    pub fn pauliX(allocator: std.mem.Allocator) !Gate {
        const values = [_]Complex{
            Complex.zero(),     Complex.identity(),
            Complex.identity(), Complex.zero(),
        };
        const g = try Gate.init(allocator, 1, values[0..]);
        return g;
    }

    pub fn pauliZ(allocator: std.mem.Allocator) !Gate {
        const values = [_]Complex{
            Complex.identity(), Complex.zero(),
            Complex.zero(),     Complex.from(-1.0, 0.0),
        };
        const g = try Gate.init(allocator, 1, values[0..]);
        return g;
    }

    pub fn cx(allocator: std.mem.Allocator) !Gate {
        const values = [_]Complex{
            Complex.identity(), Complex.zero(),     Complex.zero(),     Complex.zero(),
            Complex.zero(),     Complex.identity(), Complex.zero(),     Complex.zero(),
            Complex.zero(),     Complex.zero(),     Complex.zero(),     Complex.identity(),
            Complex.zero(),     Complex.zero(),     Complex.identity(), Complex.zero(),
        };
        const g = try Gate.init(allocator, 2, values[0..]);
        return g;
    }
};
