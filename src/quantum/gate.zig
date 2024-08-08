const std = @import("std");
const assert = std.debug.assert;

const qMath = @import("../math/mod.zig");
const Complex = qMath.Complex;
const Matrix = qMath.Matrix(Complex);

pub const SwapOperators = struct {
    to: Matrix,
    from: Matrix,
};

pub fn numHilbertDimensions(qubits: usize) usize {
    return std.math.pow(usize, 2, qubits);
}

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

    pub fn createMapping(allocator: std.mem.Allocator, nLanes: usize, inputMap: []const usize) !SwapOperators {
        // Create a list, mapping each qubit to where they actually are.
        // Perform swaps to match specified mappings.
        const stateSize = numHilbertDimensions(nLanes);
        var qubitLocations = try std.ArrayList(usize).initCapacity(allocator, nLanes);
        var checkList = std.AutoArrayHashMap(usize, bool).init(allocator);
        {
            var i: usize = 0;
            while (i < nLanes) : (i += 1) {
                try checkList.put(i, false);
                try qubitLocations.append(0);
            }

            i = 0;
            while (i < inputMap.len) : (i += 1) {
                // try qubitLocations.append(inputMap[i]);
                qubitLocations.items[inputMap[i]] = i;
                assert(checkList.orderedRemove(inputMap[i]));
            }
            while (checkList.count() > 0) : (i += 1) {
                const kv = checkList.pop();
                // try qubitLocations.append(kv.key);
                qubitLocations.items[kv.key] = i;
            }
        }

        var mat = try Matrix.identity(allocator, stateSize, stateSize);
        var swapMat = try Matrix.identity(allocator, stateSize, stateSize);

        var i: usize = 0;
        while (i < stateSize) : (i += 1) {
            var alteredIndex: usize = 0;
            var j: u6 = 0;
            while (j < nLanes) : (j += 1) {
                if (i & (@as(usize, 1) << @intCast(nLanes - j - 1)) > 0) {
                    alteredIndex |= @as(usize, 1) << @intCast(nLanes - qubitLocations.items[j] - 1);
                }
            }

            var c: usize = 0;
            while (c < stateSize) : (c += 1) {
                swapMat.set(alteredIndex, c, mat.get(i, c).*);
            }
        }

        return SwapOperators{ .to = swapMat, .from = try swapMat.transpose(allocator) };
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

    pub fn cz(allocator: std.mem.Allocator) !Gate {
        const values = [_]Complex{
            Complex.identity(), Complex.zero(),     Complex.zero(),     Complex.zero(),
            Complex.zero(),     Complex.identity(), Complex.zero(),     Complex.zero(),
            Complex.zero(),     Complex.zero(),     Complex.identity(), Complex.zero(),
            Complex.zero(),     Complex.zero(),     Complex.zero(),     Complex.from(-1.0, 0.0),
        };
        const g = try Gate.init(allocator, 2, values[0..]);
        return g;
    }
};
