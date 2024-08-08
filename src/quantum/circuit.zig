//! Circuit for connecting gates and compiling them down.

const std = @import("std");
const assert = std.debug.assert;

const qMath = @import("../math/mod.zig");
const Complex = qMath.Complex;
const Matrix = qMath.Matrix(Complex);

const UsizeContext = @import("../util/util.zig").UsizeContext;

fn numHilbertDimensions(qubits: usize) usize {
    return std.math.pow(usize, 2, qubits);
}

pub const SwapOperators = struct {
    to: Matrix,
    from: Matrix,
};

pub const Circuit = struct {
    nLanes: usize,
    stateSize: usize,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, nLanes: usize) !Circuit {
        return Circuit{
            .nLanes = nLanes,
            .stateSize = numHilbertDimensions(nLanes),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: Circuit) void {
        _ = self;
    }

    pub fn createMapping(allocator: std.mem.Allocator, nLanes: usize, inputMap: []const usize) !SwapOperators {
        // Create a list, mapping each qubit to where they actually are.
        // Perform swaps to match specified mappings.
        const stateSize = std.math.pow(usize, 2, nLanes);
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
};
