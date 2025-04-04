/// Module: Int16
/// This module provides operations for 16-bit signed integers.

module int::Int16 ;

    /// Error code for overflow.
    const OverFlowError: u64 = 1;

    /// Error code for division by zero.
    const DivisionByZeroError: u64 = 2;

    /// Error code for negative modulus.
    const NegativeMod: u64 = 3;

    /// Maximum magnitude for a 16-bit signed integer
    const MAX_MAGNITUDE: u16 = 1 << 15; // 2^15

    /// Maximum unsigned number representable as 16-bit
    const LIMIT: u16 = MAX_MAGNITUDE + ((1 << 15) - 1);

    /// Maximum positive integer (2^15 - 1)
    const MAX_POSITIVE_INT16: u16 = MAX_MAGNITUDE - 1;

    /// Minimum negative integer (-2^15)
    const MIN_NEGATIVE_INT16: u16 = MAX_MAGNITUDE;

    public struct Int16 has copy, drop, store {
        rep: u16
    }

    public fun from_uint16(magnitude: u16): Int16 {
        try_from_uint16(magnitude).extract()
    }

    public fun to_uint16(a: Int16): u16 {
        try_to_uint16(a).extract()
    }

    public fun new(magnitude: u16, is_positive: bool): Int16 {
        try_new(magnitude, is_positive).extract()
    }

    public fun max(a: Int16, b: Int16): Int16 {
        let rep = max_int16(a.rep, b.rep);
        Int16 { rep }
    }

    public fun min(a: Int16, b: Int16): Int16 {
        let rep = min_int16(a.rep, b.rep);
        Int16 { rep }
    }

    public fun lt(a: Int16, b: Int16): bool {
        if (a == b) { return false };
        a == min(a, b)
    }

    public fun gt(a: Int16, b: Int16): bool {
        if (a == b) { return false };
        a == max(a, b)
    }

    public fun lteq(a: Int16, b: Int16): bool {
        if (a == b) { return true };
        a == min(a, b)
    }

    public fun gteq(a: Int16, b: Int16): bool {
        if (a == b) { return true };
        a == max(a, b)
    }

    public fun eq(a: Int16, b: Int16): bool {
        a.rep == b.rep
    }

    public fun is_zero(a: Int16): bool {
        a.rep == 0
    }

    public fun is_positive(a: Int16): bool {
        is_positive_int16(a.rep)
    }

    public fun is_negative(a: Int16): bool {
        is_negative_int16(a.rep)
    }

    public fun abs(a: &Int16): Int16 {
        assert!(a.rep != MIN_NEGATIVE_INT16, OverFlowError);
        if (is_positive_int16(a.rep)) {
            Int16 { rep: a.rep }
        } else {
            let rep = to_2s_complement(a.rep);
            Int16 { rep }
        }
    }

    public fun neg(a: Int16): Int16 {
        assert!(a.rep != MIN_NEGATIVE_INT16, OverFlowError);
        let rep = to_2s_complement(a.rep);
        Int16 { rep }
    }

    public fun add(a: Int16, b: Int16): Int16 {
        let rep = add_int16(a.rep, b.rep);
        Int16 { rep }
    }

    public fun sub(a: Int16, b: Int16): Int16 {
        let rep = sub_int16(a.rep, b.rep);
        Int16 { rep }
    }

    public fun mul(a: Int16, b: Int16): Int16 {
        let rep = mul_int16(a.rep, b.rep);
        Int16 { rep }
    }

    public fun div(a: Int16, b: Int16): Int16 {
        assert!(b.rep != 0, DivisionByZeroError);
        let rep = div_int16(a.rep, b.rep);
        Int16 { rep }
    }

    public fun mod(a: Int16, b: Int16): Int16 {
        let rep = mod_int16(a.rep, b.rep);
        Int16 { rep }
    }

    public fun try_from_uint16(magnitude: u16): Option<Int16> {
        if (magnitude > MAX_POSITIVE_INT16) {
            option::none()
        } else {
            option::some(Int16 { rep: magnitude })
        }
    }

    public fun try_to_uint16(a: Int16): Option<u16> {
        if (a.rep > MAX_POSITIVE_INT16) {
            option::none()
        } else {
            option::some(a.rep)
        }
    }

    public fun try_new(magnitude: u16, is_positive: bool): Option<Int16> {
        if (magnitude > MIN_NEGATIVE_INT16) {
            return option::none()
        };
        if (is_positive) {
            if (magnitude > MAX_POSITIVE_INT16) {
                return option::none()
            };
            option::some(Int16 { rep: magnitude })
        } else {
            let twos_comp_rep = to_2s_complement(magnitude);
            option::some(Int16 { rep: twos_comp_rep })
        }
    }



    fun max_int16(a: u16, b: u16): u16 {
        if (is_positive_int16(a) && is_positive_int16(b)) {
            max_value(a, b)
        } else if (is_negative_int16(a) && is_negative_int16(b)) {
            max_value(a, b)
        } else {
            min_value(a, b)
        }
    }

    fun min_int16(a: u16, b: u16): u16 {
        if (is_positive_int16(a) && is_positive_int16(b)) {
            min_value(a, b)
        } else if (is_negative_int16(a) && is_negative_int16(b)) {
            min_value(a, b)
        } else {
            max_value(a, b)
        }
    }



    fun mul_int16(a: u16, b: u16): u16 {
        if (is_positive_int16(a) && is_positive_int16(b)) {
            assert!((MAX_MAGNITUDE - 1) / a >= b, OverFlowError);
            a * b
        } else if (is_negative_int16(a) && is_negative_int16(b)) {
            mul_int16(to_2s_complement(a), to_2s_complement(b))
        } else if (is_negative_int16(b)) {
            let magnitude = mul_int16(a, to_2s_complement(b));
            to_2s_complement(magnitude)
        } else {
            let magnitude = mul_int16(b, to_2s_complement(a));
            to_2s_complement(magnitude)
        }
    }

    fun div_int16(a: u16, b: u16): u16 {
        if (is_positive_int16(a) && is_positive_int16(b)) {
            a / b
        } else if (is_negative_int16(a) && is_negative_int16(b)) {
            let result = to_2s_complement(a) / to_2s_complement(b);
            assert!(is_positive_int16(result), OverFlowError);
            result
        } else if (is_negative_int16(b)) {
            let magnitude = a / to_2s_complement(b);
            to_2s_complement(magnitude)
        } else {
            let magnitude = to_2s_complement(a) / b;
            to_2s_complement(magnitude)
        }
    }

    fun sub_int16(a: u16, b: u16): u16 {
        add_int16(a, to_2s_complement(b))
    }


        fun add_int16(a: u16, b: u16): u16 {
        if (is_positive_int16(a) && is_positive_int16(b)) {
            assert!(MAX_POSITIVE_INT16 - a >= b, OverFlowError);
            a + b
        } else if (is_negative_int16(a) && is_negative_int16(b)) {
            let magnitude = add_int16(to_2s_complement(a), to_2s_complement(b));
            to_2s_complement(magnitude)
        } else {
            if (LIMIT - a < b) {
                truncated_sum(a, b)
            } else {
                a + b
            }
        }
    }

 


    fun truncated_sum(a: u16, b: u16): u16 {
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
        fun mod_int16(a: u16, b: u16): u16 {
        assert!(is_positive_int16(b), NegativeMod);
        let mut increment = a;
        while (is_negative_int16(increment)) {
            increment = add_int16(increment, b)
        };
        increment % b
    }

        // Internal helper functions
    fun is_positive_int16(a: u16): bool {
        a <= MAX_POSITIVE_INT16
    }

    fun is_negative_int16(a: u16): bool {
        a >= MIN_NEGATIVE_INT16
    }

    fun to_2s_complement(value: u16): u16 {
        if (value == 0) { return 0 };
        (value ^ LIMIT) + 1
    }

    fun max_value(a: u16, b: u16): u16 {
        if (a >= b) { a } else { b }
    }

    fun min_value(a: u16, b: u16): u16 {
        if (a <= b) { a } else { b }
    }
 