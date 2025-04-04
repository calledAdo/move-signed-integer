/// Module: Int256
/// This module provides operations for 256-bit signed integers.

module int::Int256;

    /// Error code for overflow.
    const OverFlowError: u64 = 1;

    /// Error code for division by zero.
    const DivisionByZeroError: u64 = 2;

    /// Error code for negative modulus.
    const NegativeMod: u64 = 3;

    /// Maximum magnitude for a 256-bit signed integer
    const MAX_MAGNITUDE: u256 = 1 << 255; // 2^255

    /// Maximum unsigned number representable as 256-bit
    const LIMIT: u256 = MAX_MAGNITUDE + ((1 << 255) - 1);

    /// Maximum positive integer (2^255 - 1)
    const MAX_POSITIVE_INT256: u256 = MAX_MAGNITUDE - 1;

    /// Minimum negative integer (-2^255)
    const MIN_NEGATIVE_INT256: u256 = MAX_MAGNITUDE;

    /// Structure for 256-bit signed integer.
    public struct Int256 has copy, drop, store {
        /// Representation in two's complement.
        rep: u256
    }

    /// Function to create an Int256 from an unsigned 256-bit integer.
    public fun from_uint256(magnitude: u256): Int256 {
        return try_from_uint256(magnitude).extract()
    }

    /// Function to convert an Int256 to an unsigned 256-bit integer.
    public fun to_uint256(a: Int256): u256 {
        return try_to_uint256(a).extract()
    }

    /// Function to create a new Int256.
    public fun new(magnitude: u256, is_positive: bool): Int256 {
        return try_new(magnitude, is_positive).extract()
    }

    /// Function to find the maximum of two Int256.
    public fun max(a: Int256, b: Int256): Int256 {
        let rep = max_int256(a.rep, b.rep);
        Int256 { rep }
    }

    /// Function to find the minimum of two Int256.
    public fun min(a: Int256, b: Int256): Int256 {
        let rep = min_int256(a.rep, b.rep);
        Int256 { rep }
    }

    /// Function to check if one Int256 is less than another.
    public fun lt(a: Int256, b: Int256): bool {
        if (a == b) {
            return false
        };
        a == min(a, b)
    }

    /// Function to check if one Int256 is greater than another.
    public fun gt(a: Int256, b: Int256): bool {
        if (a == b) {
            return false
        };
        a == max(a, b)
    }

    /// Function to check if one Int256 is less than or equal to another.
    public fun lteq(a: Int256, b: Int256): bool {
        if (a == b) {
            return true
        };
        a == min(a, b)
    }

    /// Function to check if one Int256 is greater than or equal to another.
    public fun gteq(a: Int256, b: Int256): bool {
        if (a == b) {
            return true
        };
        a == max(a, b)
    }

    /// Function to check if two Int256 are equal.
    public fun eq(a: Int256, b: Int256): bool {
        a.rep == b.rep
    }

    /// Function to check if an Int256 is zero.
    public fun is_zero(a: Int256): bool {
        a.rep == 0
    }

    /// Function to check if an Int256 is positive.
    public fun is_positive(a: Int256): bool {
        is_positive_int256(a.rep)
    }

    /// Function to check if an Int256 is negative.
    public fun is_negative(a: Int256): bool {
        is_negative_int256(a.rep)
    }

    /// Function to find the absolute value of an Int256.
    public fun abs(a: &Int256): Int256 {
        assert!(a.rep != MIN_NEGATIVE_INT256, OverFlowError);
        if (is_positive_int256(a.rep)) {
            Int256 { rep: a.rep }
        } else {
            let rep = to_2s_complement(a.rep);
            Int256 { rep }
        }
    }

    /// Function to find the negation of an Int256.
    public fun neg(a: Int256): Int256 {
        assert!(a.rep != MIN_NEGATIVE_INT256, OverFlowError);
        let rep = to_2s_complement(a.rep);
        Int256 { rep }
    }



    // Public arithmetic operations

    /// Function to add two Int256.
    public fun add(a: Int256, b: Int256): Int256 {
        let rep = add_int256(a.rep, b.rep);
        Int256 { rep }
    }

    /// Function to subtract two Int256.
    public fun sub(a: Int256, b: Int256): Int256 {
        let rep = sub_int256(a.rep, b.rep);
        Int256 { rep }
    }

    /// Function to multiply two Int256.
    public fun mul(a: Int256, b: Int256): Int256 {
        let rep = mul_int256(a.rep, b.rep);
        Int256 { rep }
    }

    /// Function to divide two Int256.
    public fun div(a: Int256, b: Int256): Int256 {
        assert!(b.rep != 0, DivisionByZeroError);
        let rep = div_int256(a.rep, b.rep);
        Int256 { rep }
    }

    /// Function to find the modulus of two Int256.
    public fun mod(a: Int256, b: Int256): Int256 {
        let rep = mod_int256(a.rep, b.rep);
        Int256 { rep }
    }

        // Try functions that return Option

    public fun try_from_uint256(magnitude: u256): Option<Int256> {
        if (magnitude > MAX_POSITIVE_INT256) {
            option::none()
        } else {
            option::some(Int256 { rep: magnitude })
        }
    }

    public fun try_to_uint256(a: Int256): Option<u256> {
        if (a.rep > MAX_POSITIVE_INT256) {
            option::none()
        } else {
            option::some(a.rep)
        }
    }

    public fun try_new(magnitude: u256, is_positive: bool): Option<Int256> {
        if (magnitude > MIN_NEGATIVE_INT256) {
            return option::none()
        };
        if (is_positive) {
            if (magnitude > MAX_POSITIVE_INT256) {
                return option::none()
            };
            option::some(Int256 { rep: magnitude })
        } else {
            let twos_comp_rep = to_2s_complement(magnitude);
            option::some(Int256 { rep: twos_comp_rep })
        }
    }

    // Internal arithmetic implementations

    fun add_int256(a: u256, b: u256): u256 {
        if (is_positive_int256(a) && is_positive_int256(b)) {
            assert!(MAX_POSITIVE_INT256 - a >= b, OverFlowError);
            a + b
        } else if (is_negative_int256(a) && is_negative_int256(b)) {
            let magnitude = add_int256(to_2s_complement(a), to_2s_complement(b));
            to_2s_complement(magnitude)
        } else {
            if (LIMIT - a < b) {
                truncated_sum(a, b)
            } else {
                a + b
            }
        }
    }

    fun sub_int256(a: u256, b: u256): u256 {
        add_int256(a, to_2s_complement(b))
    }

    fun mul_int256(a: u256, b: u256): u256 {
        if (is_positive_int256(a) && is_positive_int256(b)) {
            assert!((MAX_MAGNITUDE - 1) / a >= b, OverFlowError);
            a * b
        } else if (is_negative_int256(a) && is_negative_int256(b)) {
            mul_int256(to_2s_complement(a), to_2s_complement(b))
        } else if (is_negative_int256(b)) {
            let magnitude = mul_int256(a, to_2s_complement(b));
            to_2s_complement(magnitude)
        } else {
            let magnitude = mul_int256(b, to_2s_complement(a));
            to_2s_complement(magnitude)
        }
    }

    fun div_int256(a: u256, b: u256): u256 {
        if (is_positive_int256(a) && is_positive_int256(b)) {
            a / b
        } else if (is_negative_int256(a) && is_negative_int256(b)) {
            let result = to_2s_complement(a) / to_2s_complement(b);
            assert!(is_positive_int256(result), OverFlowError);
            result
        } else if (is_negative_int256(b)) {
            let magnitude = a / to_2s_complement(b);
            to_2s_complement(magnitude)
        } else {
            let magnitude = to_2s_complement(a) / b;
            to_2s_complement(magnitude)
        }
    }

  

    fun truncated_sum(a: u256, b: u256): u256 {
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

    /// Function to find the maximum of two unsigned 8-bit integers.
    fun max_int256(a:u256,b:u256):u256 {  
        if (is_positive_int256(a) && is_positive_int256(b)){
            return max_value(a, b)
        }else if (is_negative_int256(a) && is_negative_int256(b)) {
            return max_value(a, b)
        };
        return min_value(a, b)
    }

    /// Function to find the minimum of two unsigned 8-bit integers.
    fun min_int256(a:u256,b:u256):u256{
        if (is_positive_int256(a) && is_positive_int256(b)){
            return min_value(a, b)
        }else if (is_negative_int256(a) && is_negative_int256(b)) {
            return min_value(a, b)
        };
        return max_value(a, b)
    }

    fun mod_int256(a: u256, b: u256): u256 {
        assert!(is_positive_int256(b), NegativeMod);
        let mut increment = a;
        while (is_negative_int256(increment)) {
            increment = add_int256(increment, b)
        };
        increment % b
    }



        // Internal helper functions

    fun is_positive_int256(a: u256): bool {
        a <= MAX_POSITIVE_INT256
    }

    fun is_negative_int256(a: u256): bool {
        a >= MIN_NEGATIVE_INT256
    }

    fun to_2s_complement(value: u256): u256 {
        if (value == 0) {
            return 0
        };
        (value ^ LIMIT) + 1
    }
    fun max_value(a:u256,b:u256):u256{
        if (a>=b){
            return a
        }else {
            return b
        }
    }


    fun min_value(a:u256,b:u256):u256{
        if (a <= b){
            return a
        }else {
            return b
        }
    }

