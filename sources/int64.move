/// Module: Int64
/// This module provides operations for 64-bit signed integers.

module int::Int64;

    /// Error code for overflow.
    const OverFlowError: u64 = 1;

    /// Error code for division by zero.
    const DivisionByZeroError: u64 = 2;

    /// Error code for negative modulus.
    const NegativeMod: u64 = 3;

    /// Maximum magnitude for a 64-bit signed integer
    const MAX_MAGNITUDE: u64 = 1 << 63; // 2^63

    /// Maximum unsigned number representable as 64-bit
    const LIMIT: u64 = MAX_MAGNITUDE + ((1 << 63) - 1);

    /// Maximum positive integer (2^63 - 1)
    const MAX_POSITIVE_INT64: u64 = MAX_MAGNITUDE - 1;

    /// Minimum negative integer (-2^63)
    const MIN_NEGATIVE_INT64: u64 = MAX_MAGNITUDE;

    public struct Int64 has copy, drop, store {
        rep: u64
    }

    public fun from_uint64(magnitude: u64): Int64 {
        try_from_uint64(magnitude).extract()
    }

    public fun to_uint64(a: Int64): u64 {
        try_to_uint64(a).extract()
    }

    public fun new(magnitude: u64, is_positive: bool): Int64 {
        try_new(magnitude, is_positive).extract()
    }

    public fun max(a: Int64, b: Int64): Int64 {
        let rep = max_int64(a.rep, b.rep);
        Int64 { rep }
    }

    public fun min(a: Int64, b: Int64): Int64 {
        let rep = min_int64(a.rep, b.rep);
        Int64 { rep }
    }

    public fun lt(a: Int64, b: Int64): bool {
        if (a == b) { return false };
        a == min(a, b)
    }

    public fun gt(a: Int64, b: Int64): bool {
        if (a == b) { return false };
        a == max(a, b)
    }

    public fun lteq(a: Int64, b: Int64): bool {
        if (a == b) { return true };
        a == min(a, b)
    }

    public fun gteq(a: Int64, b: Int64): bool {
        if (a == b) { return true };
        a == max(a, b)
    }

    public fun eq(a: Int64, b: Int64): bool {
        a.rep == b.rep
    }

    public fun is_zero(a: Int64): bool {
        a.rep == 0
    }

    public fun is_positive(a: Int64): bool {
        is_positive_int64(a.rep)
    }

    public fun is_negative(a: Int64): bool {
        is_negative_int64(a.rep)
    }

    public fun abs(a: &Int64): Int64 {
        assert!(a.rep != MIN_NEGATIVE_INT64, OverFlowError);
        if (is_positive_int64(a.rep)) {
            Int64 { rep: a.rep }
        } else {
            let rep = to_2s_complement(a.rep);
            Int64 { rep }
        }
    }

    public fun neg(a: Int64): Int64 {
        assert!(a.rep != MIN_NEGATIVE_INT64, OverFlowError);
        let rep = to_2s_complement(a.rep);
        Int64 { rep }
    }

    public fun add(a: Int64, b: Int64): Int64 {
        let rep = add_int64(a.rep, b.rep);
        Int64 { rep }
    }

    public fun sub(a: Int64, b: Int64): Int64 {
        let rep = sub_int64(a.rep, b.rep);
        Int64 { rep }
    }

    public fun mul(a: Int64, b: Int64): Int64 {
        let rep = mul_int64(a.rep, b.rep);
        Int64 { rep }
    }

    public fun div(a: Int64, b: Int64): Int64 {
        assert!(b.rep != 0, DivisionByZeroError);
        let rep = div_int64(a.rep, b.rep);
        Int64 { rep }
    }

    public fun mod(a: Int64, b: Int64): Int64 {
        let rep = mod_int64(a.rep, b.rep);
        Int64 { rep }
    }

    public fun try_from_uint64(magnitude: u64): Option<Int64> {
        if (magnitude > MAX_POSITIVE_INT64) {
            option::none()
        } else {
            option::some(Int64 { rep: magnitude })
        }
    }

    public fun try_to_uint64(a: Int64): Option<u64> {
        if (a.rep > MAX_POSITIVE_INT64) {
            option::none()
        } else {
            option::some(a.rep)
        }
    }

    public fun try_new(magnitude: u64, is_positive: bool): Option<Int64> {
        if (magnitude > MIN_NEGATIVE_INT64) {
            return option::none()
        };
        if (is_positive) {
            if (magnitude > MAX_POSITIVE_INT64) {
                return option::none()
            };
            option::some(Int64 { rep: magnitude })
        } else {
            let twos_comp_rep = to_2s_complement(magnitude);
            option::some(Int64 { rep: twos_comp_rep })
        }
    }

    fun max_int64(a: u64, b: u64): u64 {
        if (is_positive_int64(a) && is_positive_int64(b)) {
            max_value(a, b)
        } else if (is_negative_int64(a) && is_negative_int64(b)) {
            max_value(a, b)
        } else {
            min_value(a, b)
        }
    }

    fun min_int64(a: u64, b: u64): u64 {
        if (is_positive_int64(a) && is_positive_int64(b)) {
            min_value(a, b)
        } else if (is_negative_int64(a) && is_negative_int64(b)) {
            min_value(a, b)
        } else {
            max_value(a, b)
        }
    }

    fun mul_int64(a: u64, b: u64): u64 {
        if (is_positive_int64(a) && is_positive_int64(b)) {
            assert!((MAX_MAGNITUDE - 1) / a >= b, OverFlowError);
            a * b
        } else if (is_negative_int64(a) && is_negative_int64(b)) {
            mul_int64(to_2s_complement(a), to_2s_complement(b))
        } else if (is_negative_int64(b)) {
            let magnitude = mul_int64(a, to_2s_complement(b));
            to_2s_complement(magnitude)
        } else {
            let magnitude = mul_int64(b, to_2s_complement(a));
            to_2s_complement(magnitude)
        }
    }

    fun div_int64(a: u64, b: u64): u64 {
        if (is_positive_int64(a) && is_positive_int64(b)) {
            a / b
        } else if (is_negative_int64(a) && is_negative_int64(b)) {
            let result = to_2s_complement(a) / to_2s_complement(b);
            assert!(is_positive_int64(result), OverFlowError);
            result
        } else if (is_negative_int64(b)) {
            let magnitude = a / to_2s_complement(b);
            to_2s_complement(magnitude)
        } else {
            let magnitude = to_2s_complement(a) / b;
            to_2s_complement(magnitude)
        }
    }

    fun sub_int64(a: u64, b: u64): u64 {
        add_int64(a, to_2s_complement(b))
    }

    fun add_int64(a: u64, b: u64): u64 {
        if (is_positive_int64(a) && is_positive_int64(b)) {
            assert!(MAX_POSITIVE_INT64 - a >= b, OverFlowError);
            a + b
        } else if (is_negative_int64(a) && is_negative_int64(b)) {
            let magnitude = add_int64(to_2s_complement(a), to_2s_complement(b));
            to_2s_complement(magnitude)
        } else {
            if (LIMIT - a < b) {
                truncated_sum(a, b)
            } else {
                a + b
            }
        }
    }

    fun truncated_sum(a: u64, b: u64): u64 {
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

    fun mod_int64(a: u64, b: u64): u64 {
        assert!(is_positive_int64(b), NegativeMod);
        let mut increment = a;
        while (is_negative_int64(increment)) {
            increment = add_int64(increment, b)
        };
        increment % b
    }

    // Internal helper functions
    fun is_positive_int64(a: u64): bool {
        a <= MAX_POSITIVE_INT64
    }

    fun is_negative_int64(a: u64): bool {
        a >= MIN_NEGATIVE_INT64
    }

    fun to_2s_complement(value: u64): u64 {
        if (value == 0) { return 0 };
        (value ^ LIMIT) + 1
    }

    fun max_value(a: u64, b: u64): u64 {
        if (a >= b) { a } else { b }
    }

    fun min_value(a: u64, b: u64): u64 {
        if (a <= b) { a } else { b }
    }
