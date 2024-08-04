//! Complex number struct for Qirby

const std = @import("std");

pub const Complex = struct {
    real: f32,
    imag: f32,

    pub fn getPhase(self: Complex) f32 {
        return if (self.imag >= 0) std.math.atan2(self.imag, self.real) else std.math.pi - std.math.atan2(self.imag, self.real);
    }

    pub fn getMagnitude(self: Complex) f32 {
        return std.math.sqrt(std.math.pow(f32, self.real, 2.0) + std.math.pow(f32, self.imag, 2.0));
    }

    /// Create default complex number. 1 + 0i
    pub fn make() Complex {
        return Complex{
            .real = 1,
            .imag = 0,
        };
    }

    /// Create complex number. [real] + [imag]i
    pub fn from(real: f32, imag: f32) Complex {
        return Complex{
            .real = real,
            .imag = imag,
        };
    }

    /// Create complex number with only real component specified. [real] + 0i
    pub fn fromReal(real: f32) Complex {
        return Complex{
            .real = real,
            .imag = 0,
        };
    }

    // Operations

    pub fn clone(self: *const Complex) Complex {
        return Complex{ .real = self.real, .imag = self.imag };
    }

    pub fn mul(self: *const Complex, b: *const Complex) Complex {
        var a = self.clone();
        a.mul2(b);
        return a;
    }

    /// Store-in-place multiplication between complex numbers. Stored in self.
    pub fn mul2(self: *Complex, b: *const Complex) void {
        const real = (self.real * b.real) - (self.imag * b.imag);
        const imag = (self.real * b.imag) + (self.imag * b.real);
        self.real = real;
        self.imag = imag;
    }

    // Util

    pub fn toStringCartesian(self: Complex, allocator: std.mem.Allocator) []const u8 {
        return std.fmt.allocPrint(allocator, "{d:.3} + {d:.3}i", .{ self.real, self.imag }) catch "ERR";
    }

    pub fn toStringEuler(self: Complex, allocator: std.mem.Allocator) []const u8 {
        return std.fmt.allocPrint(allocator, "{d:.1}e^(i{d:.4}pi)", .{ self.getMagnitude(), self.getPhase() }) catch "ERR";
    }

    pub fn printCartesian(self: Complex, label: []const u8) void {
        std.debug.print("{s} => {s}\n", .{ label, self.toStringCartesian(std.heap.page_allocator) });
    }

    pub fn printEuler(self: Complex, label: []const u8) void {
        std.debug.print("{s} => {s}\n", .{ label, self.toStringEuler(std.heap.page_allocator) });
    }
};

// test "complex phase [ 1 ]" {
//     const a = Complex.from(1, 0);

//     try expect()
// }
