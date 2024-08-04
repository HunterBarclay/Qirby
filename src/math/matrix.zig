//! Matrix for Qirby
pub fn Matrix(comptime T: type, R: usize, C: usize) type {
    return struct {
        elements: [R][C]T,
        numColumns: C,
        numRows: R,
    };
}
