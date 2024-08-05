//! Matrix Unit Tests

const std = @import("std");
const qirby = @import("qirby");

const util = @import("../util.zig");

const expect = @import("std").testing.expect;

test "matrix init" {
    const a = qirby.math.Matrix(qirby.math.Complex, 4, 4).init();

    try expect(a.getNumRows() == 4);
    try expect(a.getNumCols() == 4);

    util.print("matrix init passed\n");
}

test "matrix identity" {
    const ident = qirby.math.Matrix(qirby.math.Complex, 4, 4).identity;

    try expect(ident.getNumRows() == 4);
    try expect(ident.getNumCols() == 4);

    const compIdent = qirby.math.Complex.identity();
    const compZero = qirby.math.Complex.zero();

    for (ident.elements, 0..) |row, r| {
        for (row, 0..) |element, c| {
            if (r == c) {
                try expect(compIdent.eq(element));
            } else {
                try expect(compZero.eq(element));
            }
        }
    }

    util.print("matrix identity passed");
}
