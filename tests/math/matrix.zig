//! Matrix Unit Tests

const std = @import("std");
const qirby = @import("qirby");

test "matrix make" {
    const a = qirby.math.Matrix(f32, 4, 4);
    _ = a;
}
