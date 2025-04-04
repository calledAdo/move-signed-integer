/// Module: Int32
/// This module provides operations for 32-bit signed integers.

module int::Int32 ;

    /// Error code for overflow.
    const OverFlowError: u64 = 1;

    /// Error code for division by zero.
    const DivisionByZeroError: u64 = 2;

    /// Error code for negative modulus.
    const NegativeMod: u64 = 3;

    /// Maximum magnitude for a 32-bit signed integer
    const MAX_MAGNITUDE: u32 = 1 << 31; // 2^31

    /// Maximum unsigned number representable as 32-bit
    const LIMIT: u32 = MAX_MAGNITUDE + ((1 << 31) - 1);

    /// Maximum positive integer (2^31 - 1)
    const MAX_POSITIVE_INT32: u32 = MAX_MAGNITUDE - 1;

    /// Minimum negative integer (-2^31)
    const MIN_NEGATIVE_INT32: u32 = MAX_MAGNITUDE;

    public struct Int32 has copy, drop, store {
        rep: u32
    }

    public fun from_uint32(magnitude: u32): Int32 {
        try_from_uint32(magnitude).extract()
    }

    public fun to_uint32(a: Int32): u32 {
        try_to_uint32(a).extract()
    }

    public fun new(magnitude: u32, is_positive: bool): Int32 {
        try_new(magnitude, is_positive).extract()
    }

    public fun max(a: Int32, b: Int32): Int32 {
        let rep = max_int32(a.rep, b.rep);
        Int32 { rep }
    }

    public fun min(a: Int32, b: Int32): Int32 {
        let rep = min_int32(a.rep, b.rep);
        Int32 { rep }
    }

    public fun lt(a: Int32, b: Int32): bool {
        if (a == b) { return false };
        a == min(a, b)
    }

    public fun gt(a: Int32, b: Int32): bool {
        if (a == b) { return false };
        a == max(a, b)
    }

    public fun lteq(a: Int32, b: Int32): bool {
        if (a == b) { return true };
        a == min(a, b)
    }

    public fun gteq(a: Int32, b: Int32): bool {
        if (a == b) { return true };
        a == max(a, b)
    }

    public fun eq(a: Int32, b: Int32): bool {
        a.rep == b.rep
    }

    public fun is_zero(a: Int32): bool {
        a.rep == 0
    }

    public fun is_positive(a: Int32): bool {
        is_positive_int32(a.rep)
    }

    public fun is_negative(a: Int32): bool {
        is_negative_int32(a.rep)
    }

    public fun abs(a: &Int32): Int32 {
        assert!(a.rep != MIN_NEGATIVE_INT32, OverFlowError);
        if (is_positive_int32(a.rep)) {
            Int32 { rep: a.rep }
        } else {
            let rep = to_2s_complement(a.rep);
            Int32 { rep }
        }
    }

    public fun neg(a: Int32): Int32 {
        assert!(a.rep != MIN_NEGATIVE_INT32, OverFlowError);
        let rep = to_2s_complement(a.rep);
        Int32 { rep }
    }

    public fun add(a: Int32, b: Int32): Int32 {
        let rep = add_int32(a.rep, b.rep);
        Int32 { rep }
    }

    public fun sub(a: Int32, b: Int32): Int32 {
        let rep = sub_int32(a.rep, b.rep);
        Int32 { rep }
    }

    public fun mul(a: Int32, b: Int32): Int32 {
        let rep = mul_int32(a.rep, b.rep);
        Int32 { rep }
    }

    public fun div(a: Int32, b: Int32): Int32 {
        assert!(b.rep != 0, DivisionByZeroError);
        let rep = div_int32(a.rep, b.rep);
        Int32 { rep }
    }

    public fun mod(a: Int32, b: Int32): Int32 {
        let rep = mod_int32(a.rep, b.rep);
        Int32 { rep }
    }

    public fun try_from_uint32(magnitude: u32): Option<Int32> {
        if (magnitude > MAX_POSITIVE_INT32) {
            option::none()
        } else {
            option::some(Int32 { rep: magnitude })
        }
    }

    public fun try_to_uint32(a: Int32): Option<u32> {
        if (a.rep > MAX_POSITIVE_INT32) {
            option::none()
        } else {
            option::some(a.rep)
        }
    }

    public fun try_new(magnitude: u32, is_positive: bool): Option<Int32> {
        if (magnitude > MIN_NEGATIVE_INT32) {
            return option::none()
        };
        if (is_positive) {
            if (magnitude > MAX_POSITIVE_INT32) {
                return option::none()
            };
            option::some(Int32 { rep: magnitude })
        } else {
            let twos_comp_rep = to_2s_complement(magnitude);
            option::some(Int32 { rep: twos_comp_rep })
        }
    }

    fun max_int32(a: u32, b: u32): u32 {
        if (is_positive_int32(a) && is_positive_int32(b)) {
            max_value(a, b)
        } else if (is_negative_int32(a) && is_negative_int32(b)) {
            max_value(a, b)
        } else {
            min_value(a, b)
        }
    }

    fun min_int32(a: u32, b: u32): u32 {
        if (is_positive_int32(a) && is_positive_int32(b)) {
            min_value(a, b)
        } else if (is_negative_int32(a) && is_negative_int32(b)) {
            min_value(a, b)
        } else {
            max_value(a, b)
        }
    }

    fun mul_int32(a: u32, b: u32): u32 {
        if (is_positive_int32(a) && is_positive_int32(b)) {
            assert!((MAX_MAGNITUDE - 1) / a >= b, OverFlowError);
            a * b
        } else if (is_negative_int32(a) && is_negative_int32(b)) {
            mul_int32(to_2s_complement(a), to_2s_complement(b))
        } else if (is_negative_int32(b)) {
            let magnitude = mul_int32(a, to_2s_complement(b));
            to_2s_complement(magnitude)
        } else {
            let magnitude = mul_int32(b, to_2s_complement(a));
            to_2s_complement(magnitude)
        }
    }

    fun div_int32(a: u32, b: u32): u32 {
        if (is_positive_int32(a) && is_positive_int32(b)) {
            a / b
        } else if (is_negative_int32(a) && is_negative_int32(b)) {
            let result = to_2s_complement(a) / to_2s_complement(b);
            assert!(is_positive_int32(result), OverFlowError);
            result
        } else if (is_negative_int32(b)) {
            let magnitude = a / to_2s_complement(b);
            to_2s_complement(magnitude)
        } else {
            let magnitude = to_2s_complement(a) / b;
            to_2s_complement(magnitude)
        }
    }

    fun sub_int32(a: u32, b: u32): u32 {
        add_int32(a, to_2s_complement(b))
    }

    fun add_int32(a: u32, b: u32): u32 {
        if (is_positive_int32(a) && is_positive_int32(b)) {
            assert!(MAX_POSITIVE_INT32 - a >= b, OverFlowError);
            a + b
        } else if (is_negative_int32(a) && is_negative_int32(b)) {
            let magnitude = add_int32(to_2s_complement(a), to_2s_complement(b));
            to_2s_complement(magnitude)
        } else {
            if (LIMIT - a < b) {
                truncated_sum(a, b)
            } else {
                a + b
            }
        }
    }

    fun truncated_sum(a: u32, b: u32): u32 {
        if (a & MAX_MAGNITUDE != 0 && b & MAX_MAGNITUDE != 0) {
            ((a ^ MAX_MAGNITUDE) + (b ^ MAX_MAGNITUDE))
        } else if (a & MAX_MAGNITUDE == 0) {
            let reduced_factor = (b ^ MAX_MAGNITUDE) + a;
            reduced_factor ^ MAX_MAGNITUDE
        } else {
            let reduced_factor = (a ^ MAX_MAGNITUDE) + b;
            reduced_factor ^ MAX_MAGNITUDE
        }
    }

    fun mod_int32(a: u32, b: u32): u32 {
        assert!(is_positive_int32(b), NegativeMod);
        let mut increment = a;
        while (is_negative_int32(increment)) {
            increment = add_int32(increment, b)
        };
        increment % b
    }

    // Internal helper functions
    fun is_positive_int32(a: u32): bool {
        a <= MAX_POSITIVE_INT32
    }

    fun is_negative_int32(a: u32): bool {
        a >= MIN_NEGATIVE_INT32
    }

    fun to_2s_complement(value: u32): u32 {
        if (value == 0) { return 0 };
        (value ^ LIMIT) + 1
    }

    fun max_value(a: u32, b: u32): u32 {
        if (a >= b) { a } else { b }
    }

    fun min_value(a: u32, b: u32): u32 {
        if (a <= b) { a } else { b }
    }
