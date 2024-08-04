//! Complex number Unit Tests

const std = @import("std");
const qirby = @import("qirby");

const print = @import("../util.zig").print;
const printf = @import("../util.zig").printf;

const expect = @import("std").testing.expect;

test "complex make" {
    const a = qirby.math.Complex.make();

    try expect(a.imag == 0);
    try expect(a.real == 1);

    print("complex make passed\n");
}

test "complex from" {
    const a = qirby.math.Complex.from(2, 3);

    try expect(a.imag == 3);
    try expect(a.real == 2);

    print("complex from passed\n");
}

test "complex fromReal" {
    const a = qirby.math.Complex.fromReal(2);

    try expect(a.imag == 0);
    try expect(a.real == 2);

    print("complex fromReal passed\n");
}

test "complex clone" {
    const a = qirby.math.Complex.from(7, 12);

    const b = a.clone();

    try expect(b.real == 7);
    try expect(b.imag == 12);

    print("complex clone passed\n");
}

test "complex mul [ (1) * (i) ]" {
    const a = qirby.math.Complex.from(1, 0);
    const b = qirby.math.Complex.from(0, 1);

    const c = a.mul(&b);

    try expect(c.imag == 1);
    try expect(c.real == 0);

    print("complex mul [ (1) * (i) ] passed\n");
}

test "complex mul2 [ (1) * (i) ]" {
    var a = qirby.math.Complex.from(1, 0);
    const b = qirby.math.Complex.from(0, 1);

    a.mul2(&b);

    try expect(a.imag == 1);
    try expect(a.real == 0);

    print("complex mul2 [ (1) * (i) ] passed\n");
}

test "complex euler [ 1 ]" {
    const a = qirby.math.Complex.from(1, 0);

    try expect(a.getPhase() == 0);
    try expect(a.getMagnitude() == 1);

    print("complex euler [ 1 ] passed\n");
}

test "complex euler [ i ]" {
    const a = qirby.math.Complex.from(0, 1);

    try expect(std.math.approxEqAbs(f32, a.getPhase(), std.math.pi / 2.0, 0.0001));
    try expect(a.getMagnitude() == 1);

    print("complex euler [ i ] passed\n");
}

test "complex euler [ -1 ]" {
    const a = qirby.math.Complex.from(-1, 0);

    try expect(std.math.approxEqAbs(f32, a.getPhase(), std.math.pi, 0.0001));
    try expect(a.getMagnitude() == 1);

    print("complex euler [ -1 ] passed\n");
}

test "complex euler [ -i ]" {
    const a = qirby.math.Complex.from(0, -1);

    try expect(std.math.approxEqAbs(f32, a.getPhase(), std.math.pi * (3.0 / 2.0), 0.0001));
    try expect(a.getMagnitude() == 1);

    print("complex euler [ -i ] passed\n");
}
