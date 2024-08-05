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
    pub fn init() Complex {
        return Complex{
            .real = 1,
            .imag = 0,
        };
    }

    pub fn identity() Complex {
        return Complex.from(1, 0);
    }

    pub fn zero() Complex {
        return Complex.from(0, 0);
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

    pub fn clone(self: Complex) Complex {
        return Complex{ .real = self.real, .imag = self.imag };
    }

    pub fn mult(self: Complex, b: Complex) Complex {
        var a = self.clone();
        _ = a.mutMult(b);
        return a;
    }

    /// Store-in-place multiplication between complex numbers. Stored in self.
    pub fn mutMult(self: *Complex, b: Complex) *Complex {
        const real = (self.real * b.real) - (self.imag * b.imag);
        const imag = (self.real * b.imag) + (self.imag * b.real);
        self.real = real;
        self.imag = imag;

        return self;
    }

    pub fn add(self: Complex, b: Complex) Complex {
        var a = self.clone();
        a.mutAdd(b);
        return a;
    }

    pub fn mutAdd(self: *Complex, b: Complex) *Complex {
        self.real += b.real;
        self.imag += b.imag;

        return self;
    }

    pub fn eq(self: Complex, b: Complex) bool {
        return std.math.approxEqAbs(f32, self.real, b.real, 0.0001) and std.math.approxEqAbs(f32, self.imag, b.imag, 0.0001);
    }

    // Util

    /// Default toString method for Complex. See Cartesian and Euler toString methods.
    /// Default will be Euler.
    pub fn toString(self: Complex, allocator: std.mem.Allocator) []const u8 {
        return self.toStringEuler(allocator);
    }

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
