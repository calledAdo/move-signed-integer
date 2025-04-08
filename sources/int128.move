/// Module: Int128
/// This module provides operations for 128-bit signed integers.

module int::int128;



/// Error code for overflow.
const OverFlowError: u64 = 1;

/// Error code for division by zero.
const DivisionByZeroError: u64 = 2;

/// Error code for negative modulus.
const NegativeMod: u64 = 3;

const BIT_SIZE: u64 = 128;

/// Maximum magnitude for a 128-bit signed integer
/// magnitude of a => |a| eg |-2| = 2
const MAX_MAGNITUDE: u128 = 1 << (BIT_SIZE - 1  as u8); // 2^127

/// Maximum unsigned number representable as 128-bit
const LIMIT: u128 = MAX_MAGNITUDE + (MAX_MAGNITUDE - 1);

/// Maximum positive integer (2^127 - 1)
const MAX_POSITIVE_INT128: u128 = MAX_MAGNITUDE - 1;

/// Minimum negative integer (-2^127)
const MIN_NEGATIVE_INT128: u128 = MAX_MAGNITUDE;

public struct Int128 has copy, drop, store {
    rep: u128,
}

/// Create Int256 type functions
///
///
///
///
///
public fun from_raw_bits(bits: u128): Int128 {
    return Int128 { rep: bits }
}

public fun from_u128(magnitude: u128): Int128 {
    try_from_uint128(magnitude).extract()
}

public fun try_from_uint128(magnitude: u128): Option<Int128> {
    if (magnitude > MAX_POSITIVE_INT128) {
        option::none()
    } else {
        option::some(Int128 { rep: magnitude })
    }
}

public fun new(magnitude: u128, is_positive: bool): Int128 {
    try_new(magnitude, is_positive).extract()
}

public fun try_new(magnitude: u128, is_positive: bool): Option<Int128> {
    if (magnitude > MIN_NEGATIVE_INT128) {
        return option::none()
    };
    if (is_positive) {
        if (magnitude > MAX_POSITIVE_INT128) {
            return option::none()
        };
        option::some(Int128 { rep: magnitude })
    } else {
        let twos_comp_rep = to_2s_complement(magnitude);
        option::some(Int128 { rep: twos_comp_rep })
    }
}

/// Convert from type functions
///
///
///
///
public fun to_u128(a: Int128): u128 {
    try_to_uint128(a).extract()
}

public fun try_to_uint128(a: Int128): Option<u128> {
    if (a.rep > MAX_POSITIVE_INT128) {
        option::none()
    } else {
        option::some(a.rep)
    }
}

public fun raw_bit(a: Int128): u128 {
    return a.rep
}

/// Comparison Operations
///
///
///
public fun max(a: Int128, b: Int128): Int128 {
    let rep = max_int128(a.rep, b.rep);
    Int128 { rep }
}

public fun min(a: Int128, b: Int128): Int128 {
    let rep = min_int128(a.rep, b.rep);
    Int128 { rep }
}

//checks that a is less than b
public fun lt(a: Int128, b: Int128): bool {
    if (a == b) { return false };
    a == min(a, b)
}

/// checks that a is greater than b
public fun gt(a: Int128, b: Int128): bool {
    if (a == b) { return false };
    a == max(a, b)
}

/// checks that a is less than or equal to be
public fun lteq(a: Int128, b: Int128): bool {
    if (a == b) { return true };
    a == min(a, b)
}

/// checks that a is greater than or equal to b
public fun gteq(a: Int128, b: Int128): bool {
    if (a == b) { return true };
    a == max(a, b)
}

public fun eq(a: Int128, b: Int128): bool {
    a.rep == b.rep
}

public fun is_zero(a: Int128): bool {
    a.rep == 0
}

public fun is_positive(a: Int128): bool {
    is_positive_int128(a.rep)
}

public fun is_negative(a: Int128): bool {
    is_negative_int128(a.rep)
}

public fun is_nat(a: Int128): bool {
    return a.rep > 0 && a.rep < MIN_NEGATIVE_INT128
}

/// Operations  on Int128 type
///
///
///
public fun shl(x: Int128, shift: u8): Int128 {
    let rep = x.rep << shift;
    return Int128 { rep }
}

public fun shr(x: Int128, shift: u8): Int128 {
    let rep = shr_int128(x.rep, shift);
    return Int128 { rep }
}

public fun abs(a: &Int128): Int128 {
    assert!(a.rep != MIN_NEGATIVE_INT128, OverFlowError);
    if (is_positive_int128(a.rep)) {
        Int128 { rep: a.rep }
    } else {
        let rep = to_2s_complement(a.rep);
        Int128 { rep }
    }
}

public fun neg(a: Int128): Int128 {
    assert!(a.rep != MIN_NEGATIVE_INT128, OverFlowError);
    let rep = to_2s_complement(a.rep);
    Int128 { rep }
}

/// Arithmetic Operations
///
///
///
public fun add(a: Int128, b: Int128): Int128 {
    let rep = add_int128(a.rep, b.rep);
    Int128 { rep }
}

public fun try_add(a: Int128, b: Int128): Option<Int128> {
    let mut rep = try_add_int128(a.rep, b.rep);

    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int128 { rep: (&mut rep).extract() })
}

public fun sub(a: Int128, b: Int128): Int128 {
    let rep = sub_int128(a.rep, b.rep);
    Int128 { rep }
}

public fun try_sub(a: Int128, b: Int128): Option<Int128> {
    let mut rep = try_sub_int128(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int128 { rep: (&mut rep).extract() })
}

public fun mul(a: Int128, b: Int128): Int128 {
    let rep = mul_int128(a.rep, b.rep);
    Int128 { rep }
}

public fun try_mul(a: Int128, b: Int128): Option<Int128> {
    let mut rep = try_mul_int128(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int128 { rep: (&mut rep).extract() })
}

public fun div(a: Int128, b: Int128): Int128 {
    assert!(b.rep != 0, DivisionByZeroError);
    let rep = div_int128(a.rep, b.rep);
    Int128 { rep }
}

public fun try_div(a: Int128, b: Int128): Option<Int128> {
    assert!(b.rep != 0, DivisionByZeroError);
    let mut rep = try_div_int128(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int128 { rep: (&mut rep).extract() })
}

// returns a modulo b
public fun mod(a: Int128, b: Int128): Int128 {
    let rep = mod_int128(a.rep, b.rep);
    Int128 { rep }
}

fun max_int128(a: u128, b: u128): u128 {
    if (is_positive_int128(a) && is_positive_int128(b)) {
        max_value(a, b)
    } else if (is_negative_int128(a) && is_negative_int128(b)) {
        max_value(a, b)
    } else {
        min_value(a, b)
    }
}

fun min_int128(a: u128, b: u128): u128 {
    if (is_positive_int128(a) && is_positive_int128(b)) {
        min_value(a, b)
    } else if (is_negative_int128(a) && is_negative_int128(b)) {
        min_value(a, b)
    } else {
        max_value(a, b)
    }
}

fun mul_int128(a: u128, b: u128): u128 {
    let mut result = try_mul_int128(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_mul_int128(a: u128, b: u128): Option<u128> {
    if (is_positive_int128(a) && is_positive_int128(b)) {
        if (safe_multiply(a, b)) {
            return option::some(a * b)
        };
    } else if (is_negative_int128(a) && is_negative_int128(b)) {
        let a_neg = to_2s_complement(a);
        let b_neg = to_2s_complement(b);
        if (safe_multiply(a_neg, b_neg)) {
            let result = a_neg * b_neg;
            // if (is_negative_int128(result)) {
            //     // if negative a there was a truncation error eg -max_negative number * 1
            //     return option::none()
            // };
            return option::some(result)
        }
    } else if (is_negative_int128(b)) {
        let b_neg = to_2s_complement(b);
        if (safe_multiply(a, b_neg)) {
            return option::some(to_2s_complement(a * b_neg))
        }
    } else {
        let a_neg = to_2s_complement(a);
        if (safe_multiply(b, a_neg)) {
            return option::some(to_2s_complement(b * a_neg))
        }
    };
    return option::none()
}

fun safe_multiply(a: u128, b: u128): bool {
    return MAX_POSITIVE_INT128 / a >= b
}

fun div_int128(a: u128, b: u128): u128 {
    let mut result = try_div_int128(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_div_int128(a: u128, b: u128): Option<u128> {
    if (is_positive_int128(a) && is_positive_int128(b)) {
        return option::some(a / b)
    } else if (is_negative_int128(a) && is_negative_int128(b)) {
        let result = to_2s_complement(a) / to_2s_complement(b);
        if (!is_negative_int128(result)) {
            return option::none()
        };
        option::some(result)
    } else if (is_negative_int128(b)) {
        let magnitude = a / to_2s_complement(b);
        option::some(to_2s_complement(magnitude))
    } else {
        let magnitude = to_2s_complement(a) / b;
        option::some(to_2s_complement(magnitude))
    }
}

fun sub_int128(a: u128, b: u128): u128 {
    let mut result = try_sub_int128(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_sub_int128(a: u128, b: u128): Option<u128> {
    try_add_int128(a, to_2s_complement(b))
}

fun add_int128(a: u128, b: u128): u128 {
    let mut result = try_add_int128(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_add_int128(a: u128, b: u128): Option<u128> {
    if (is_positive_int128(a) && is_positive_int128(b)) {
        if (safe_add(a, b)) {
            return option::some(a + b)
        };
    } else if (is_negative_int128(a) && is_negative_int128(b)) {
        let a_neg = to_2s_complement(a);
        let b_neg = to_2s_complement(b);
        if (safe_add(a_neg, b_neg)) {
            let magnitude = a_neg + b_neg;
            return option::some(to_2s_complement(magnitude))
        }
    } else {
        if (LIMIT - a < b) {
            return option::some(truncated_sum(a, b))
        } else {
            return option::some(a + b)
        }
    };

    return option::none()
}

fun safe_add(a: u128, b: u128): bool {
    return MAX_POSITIVE_INT128 - a >= b
}

fun truncated_sum(a: u128, b: u128): u128 {
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

fun mod_int128(a: u128, b: u128): u128 {
    assert!(is_positive_int128(b), NegativeMod);
    let mut increment = a;
    while (is_negative_int128(increment)) {
        increment = add_int128(increment, b)
    };
    increment % b
}

fun shr_int128(x: u128, shift: u8): u128 {
    let mut rep = x >> shift;
    if (x & MAX_MAGNITUDE != 0) {
        let bits = (1 << (shift) ) - 1;

        let factor = bits << (BIT_SIZE as u8 - shift);

        rep = rep + factor;
    };

    return rep
}

// Internal helper functions
fun is_positive_int128(a: u128): bool {
    a <= MAX_POSITIVE_INT128
}

fun is_negative_int128(a: u128): bool {
    a >= MIN_NEGATIVE_INT128
}

fun to_2s_complement(value: u128): u128 {
    if (value == 0) { return 0 };
    (value ^ LIMIT) + 1
}

fun max_value(a: u128, b: u128): u128 {
    if (a >= b) { a } else { b }
}

fun min_value(a: u128, b: u128): u128 {
    if (a <= b) { a } else { b }
}
