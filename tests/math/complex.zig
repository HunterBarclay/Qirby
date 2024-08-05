//! Complex number Unit Tests

const std = @import("std");
const qirby = @import("qirby");

const util = @import("../util.zig");

const expect = @import("std").testing.expect;
const expectApprox = @import("std").testing.expectApproxEqAbs;

test "complex init" {
    const a = qirby.math.Complex.init();

    try expect(a.imag == 0);
    try expect(a.real == 1);

    util.print("complex init passed\n");
}

test "complex identity" {
    const a = qirby.math.Complex.identity();

    try util.expectF32(1.0, a.real);
    try util.expectF32(0.0, a.imag);

    const b = qirby.math.Complex.identity();
    const c = a.mult(b);

    try util.expectF32(a.real, c.real);
    try util.expectF32(a.imag, c.imag);

    util.print("complex identity passed\n");
}

test "complex zero" {
    const a = qirby.math.Complex.zero();

    try util.expectF32(0.0, a.real);
    try util.expectF32(0.0, a.imag);

    const b = qirby.math.Complex.identity();
    const c = a.mult(b);

    try util.expectF32(a.real, c.real);
    try util.expectF32(a.imag, c.imag);

    util.print("complex zero passed\n");
}

test "complex from" {
    const a = qirby.math.Complex.from(2, 3);

    try expect(a.imag == 3);
    try expect(a.real == 2);

    util.print("complex from passed\n");
}

test "complex fromReal" {
    const a = qirby.math.Complex.fromReal(2);

    try expect(a.imag == 0);
    try expect(a.real == 2);

    util.print("complex fromReal passed\n");
}

test "complex clone" {
    const a = qirby.math.Complex.from(7, 12);

    const b = a.clone();

    try expect(b.real == 7);
    try expect(b.imag == 12);

    util.print("complex clone passed\n");
}

test "complex mult [ (1) * (i) ]" {
    const a = qirby.math.Complex.from(1, 0);
    const b = qirby.math.Complex.from(0, 1);

    const c = a.mult(b);

    try expect(c.imag == 1);
    try expect(c.real == 0);

    util.print("complex mul [ (1) * (i) ] passed\n");
}

test "complex mutMult [ (1) * (i) ]" {
    var a = qirby.math.Complex.from(1, 0);
    const b = qirby.math.Complex.from(0, 1);

    a.mutMult(b);

    try expect(a.imag == 1);
    try expect(a.real == 0);

    util.print("complex mul2 [ (1) * (i) ] passed\n");
}

test "complex euler [ 1 ]" {
    const a = qirby.math.Complex.from(1, 0);

    try util.expectF32(0.0, a.getPhase());
    try util.expectF32(1.0, a.getMagnitude());

    util.print("complex euler [ 1 ] passed\n");
}

test "complex euler [ i ]" {
    const a = qirby.math.Complex.from(0, 1);

    try util.expectF32(std.math.pi / 2.0, a.getPhase());
    try util.expectF32(1.0, a.getMagnitude());

    util.print("complex euler [ i ] passed\n");
}

test "complex euler [ -1 ]" {
    const a = qirby.math.Complex.from(-1, 0);

    try util.expectF32(std.math.pi, a.getPhase());
    try util.expectF32(1.0, a.getMagnitude());

    util.print("complex euler [ -1 ] passed\n");
}

test "complex euler [ -i ]" {
    const a = qirby.math.Complex.from(0, -1);

    try util.expectF32((3.0 / 2.0) * std.math.pi, a.getPhase());
    try util.expectF32(1.0, a.getMagnitude());

    util.print("complex euler [ -i ] passed\n");
}

// TODO: complex eq
