pub const UsizeContext = struct {
    pub fn hash(self: UsizeContext, a: usize) u32 {
        _ = self;
        return @intCast(a);
    }

    pub fn eql(self: UsizeContext, a: usize, b: usize) bool {
        _ = self;
        return a == b;
    }
};
