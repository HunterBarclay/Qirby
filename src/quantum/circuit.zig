//! Circuit for connecting gates and compiling them down.

const std = @import("std");
const assert = std.debug.assert;

const qMath = @import("../math/mod.zig");
const Complex = qMath.Complex;
const Matrix = qMath.Matrix(Complex);
const Gate = @import("gate.zig").Gate;
const State = @import("state.zig").State;
const numHilbertDimensions = @import("gate.zig").numHilbertDimensions;

const UsizeContext = @import("../util/util.zig").UsizeContext;

pub const Circuit = struct {
    nLanes: usize,
    stateSize: usize,
    allocator: std.mem.Allocator,
    operations: std.ArrayList(Gate),
    compiled: ?Gate,

    pub fn init(allocator: std.mem.Allocator, nLanes: usize) !Circuit {
        return Circuit{
            .nLanes = nLanes,
            .stateSize = numHilbertDimensions(nLanes),
            .allocator = allocator,
            .operations = std.ArrayList(Gate).init(allocator),
            .compiled = null,
        };
    }

    pub fn addGate(self: *Circuit, allocator: std.mem.Allocator, gate: Gate, inputMap: ?[]const usize) !void {
        var modifiedMat = gate.matrix;
        modifiedMat = try modifiedMat.tensor(allocator, try Matrix.identity(
            allocator,
            numHilbertDimensions(self.nLanes - gate.nLanes),
            numHilbertDimensions(self.nLanes - gate.nLanes),
        ));

        if (inputMap) |map| {
            const swapOps = try Gate.createMapping(allocator, self.nLanes, map);
            modifiedMat = try modifiedMat.mult(allocator, swapOps.to);
            modifiedMat = try swapOps.from.mult(allocator, modifiedMat);
        }

        try self.operations.append(try Gate.from(self.nLanes, modifiedMat));
    }

    pub fn isCompiled(self: Circuit) bool {
        return self.compiled != null;
    }

    pub fn compile(self: *Circuit, allocator: std.mem.Allocator) !void {
        var m = try Matrix.identity(allocator, self.stateSize, self.stateSize);

        var i: usize = 0;
        while (i < self.operations.items.len) : (i += 1) {
            const next = self.operations.items[i];
            const latestMatrix = try next.matrix.mult(allocator, m);
            next.deinit();
            m.deinit();
            m = latestMatrix;
        }

        self.operations.deinit();

        self.compiled = try Gate.from(self.nLanes, m);
    }

    pub fn run(self: Circuit, allocator: std.mem.Allocator, state: *State) !void {
        assert(self.compiled != null);

        try state.applyGate(allocator, self.compiled.?);
    }

    pub fn deinit(self: Circuit) void {
        for (self.operations.items) |operation| {
            self.allocator.destroy(operation);
        }
        self.operations.deinit();
    }
};
