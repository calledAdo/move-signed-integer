module int::int16;

const OverFlowError: u64 = 1;
const OutofBoundError: u64 = 2;
const DivisionByZeroError: u64 = 3;
const NegativeMod: u64 = 4;

const BIT_SIZE: u8 = 16;
const MAX_MAGNITUDE: u16 = 1 << (BIT_SIZE - 1); // 2^17
const LIMIT: u16 = MAX_MAGNITUDE + (MAX_MAGNITUDE - 1);
const MAX_POSITIVE_INT18: u16 = MAX_MAGNITUDE - 1;
const MIN_NEGATIVE_INT18: u16 = MAX_MAGNITUDE;

public struct Int16 has copy, drop, store {
    rep: u16,
}

/// Create Int16 type functions
///
///
///
public fun from_raw_bits(bits: u16): Int16 {
    return Int16 { rep: bits }
}

public fun from_u16(magnitude: u16): Int16 {
    try_from_u16(magnitude).extract()
}

public fun try_from_u16(magnitude: u16): Option<Int16> {
    if (magnitude > MAX_POSITIVE_INT18) {
        option::none()
    } else {
        option::some(Int16 { rep: magnitude })
    }
}

public fun new(magnitude: u16, is_positive: bool): Int16 {
    try_new(magnitude, is_positive).extract()
}

public fun try_new(magnitude: u16, is_positive: bool): Option<Int16> {
    if (magnitude > MIN_NEGATIVE_INT18) {
        return option::none()
    };
    if (is_positive) {
        if (magnitude > MAX_POSITIVE_INT18) {
            return option::none()
        };
        option::some(Int16 { rep: magnitude })
    } else {
        let twos_comp_rep = to_2s_complement(magnitude);
        option::some(Int16 { rep: twos_comp_rep })
    }
}

/// Convert to different type functions
///
///
///
///
public fun to_u16(a: Int16): u16 {
    try_to_u16(a).extract()
}

public fun try_to_u16(a: Int16): Option<u16> {
    if (a.rep > MAX_POSITIVE_INT18) {
        option::none()
    } else {
        option::some(a.rep)
    }
}

public fun raw_bits(a: Int16): u16 {
    return a.rep
}

/// Comaprison function for Int16 type
///
///
///
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
    a == min(a, b)
}

public fun gteq(a: Int16, b: Int16): bool {
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

public fun is_nat(a: Int16): bool {
    return a.rep > 0 && a.rep < MIN_NEGATIVE_INT18
}

/// Bitwise operation functions for Int16 type
///
///
///
///

public fun shl(x: Int16, shift: u8): Int16 {
    let rep = x.rep << shift;
    return Int16 { rep }
}

public fun shr(x: Int16, shift: u8): Int16 {
    let rep = shr_int16(x.rep, shift);
    return Int16 { rep }
}

public fun abs(a: &Int16): Int16 {
    assert!(a.rep != MIN_NEGATIVE_INT18, OutofBoundError);
    if (is_positive_int16(a.rep)) {
        Int16 { rep: a.rep }
    } else {
        let rep = to_2s_complement(a.rep);
        Int16 { rep }
    }
}

public fun neg(a: Int16): Int16 {
    assert!(a.rep != MIN_NEGATIVE_INT18, OutofBoundError);
    let rep = to_2s_complement(a.rep);
    Int16 { rep }
}

/// Arithmetic Operations on Int8 type
public fun add(a: Int16, b: Int16): Int16 {
    let rep = add_int16(a.rep, b.rep);
    Int16 { rep }
}

public fun try_add(a: Int16, b: Int16): Option<Int16> {
    let mut rep = try_add_int16(a.rep, b.rep);

    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int16 { rep: (&mut rep).extract() })
}

public fun sub(a: Int16, b: Int16): Int16 {
    let rep = sub_int16(a.rep, b.rep);
    Int16 { rep }
}

public fun try_sub(a: Int16, b: Int16): Option<Int16> {
    let mut rep = try_sub_int16(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int16 { rep: (&mut rep).extract() })
}

public fun mul(a: Int16, b: Int16): Int16 {
    let rep = mul_int16(a.rep, b.rep);
    Int16 { rep }
}

public fun try_mul(a: Int16, b: Int16): Option<Int16> {
    let mut rep = try_mul_int16(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int16 { rep: (&mut rep).extract() })
}

public fun div(a: Int16, b: Int16): Int16 {
    assert!(b.rep != 0, DivisionByZeroError);
    let rep = div_int16(a.rep, b.rep);
    Int16 { rep }
}

public fun try_div(a: Int16, b: Int16): Option<Int16> {
    assert!(b.rep != 0, DivisionByZeroError);
    let mut rep = try_div_int16(a.rep, b.rep);
    if (option::is_none(&rep)) {
        return option::none()
    };
    option::some(Int16 { rep: (&mut rep).extract() })
}

public fun mod(a: Int16, b: Int16): Int16 {
    let rep = mod_int16(a.rep, b.rep);
    Int16 { rep }
}

/// Private helper functions for Int16 type
///
///
///

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
    let mut result = try_mul_int16(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_mul_int16(a: u16, b: u16): Option<u16> {
    if (is_positive_int16(a) && is_positive_int16(b)) {
        if (safe_multiply(a, b)) {
            return option::some(a * b)
        };
    } else if (is_negative_int16(a) && is_negative_int16(b)) {
        let a_neg = to_2s_complement(a);
        let b_neg = to_2s_complement(b);
        if (safe_multiply(a_neg, b_neg)) {
            let result = a_neg * b_neg;
            return option::some(result)
        }
    } else if (is_negative_int16(b)) {
        let b_neg = to_2s_complement(b);
        if (safe_multiply_polar(a, b_neg)) {
            return option::some(to_2s_complement(a * b_neg))
        }
    } else {
        let a_neg = to_2s_complement(a);
        if (safe_multiply_polar(b, a_neg)) {
            return option::some(to_2s_complement(b * a_neg))
        }
    };
    return option::none()
}

fun safe_multiply(a: u16, b: u16): bool {
    return MAX_POSITIVE_INT18 / a >= b
}

fun safe_multiply_polar(a: u16, b: u16): bool {
    return MIN_NEGATIVE_INT18 / a >= b
}

fun div_int16(a: u16, b: u16): u16 {
    let mut result = try_div_int16(a, b);
    if (option::is_none(&result)) {
        abort OutofBoundError
    };
    result.extract()
}

fun try_div_int16(a: u16, b: u16): Option<u16> {
    if (is_positive_int16(a) && is_positive_int16(b)) {
        return option::some(a / b)
    } else if (is_negative_int16(a) && is_negative_int16(b)) {
        let result = to_2s_complement(a) / to_2s_complement(b);
        if (is_negative_int16(result)) {
            return option::none()
        };
        option::some(result)
    } else if (is_negative_int16(b)) {
        let magnitude = a / to_2s_complement(b);
        option::some(to_2s_complement(magnitude))
    } else {
        let magnitude = to_2s_complement(a) / b;
        option::some(to_2s_complement(magnitude))
    }
}

fun sub_int16(a: u16, b: u16): u16 {
    let mut result = try_sub_int16(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_sub_int16(a: u16, b: u16): Option<u16> {
    if (b==0) {
        return option::some(a)
    };
    try_add_int16(a, to_2s_complement(b))
}

fun add_int16(a: u16, b: u16): u16 {
    let mut result = try_add_int16(a, b);
    if (option::is_none(&result)) {
        abort OverFlowError
    };
    result.extract()
}

fun try_add_int16(a: u16, b: u16): Option<u16> {
    if (is_positive_int16(a) && is_positive_int16(b)) {
        if (safe_add(a, b)) {
            return option::some(a + b)
        };
    } else if (is_negative_int16(a) && is_negative_int16(b)) {
        let a_neg = to_2s_complement(a);
        let b_neg = to_2s_complement(b);
        if (safe_add_neg(a_neg, b_neg)) {
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

fun safe_add(a: u16, b: u16): bool {
    return MIN_NEGATIVE_INT18 - a >= b
}

fun safe_add_neg(a: u16, b: u16): bool {
    return MIN_NEGATIVE_INT18 - a >= b
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

fun shr_int16(x: u16, shift: u8): u16 {
    let mut rep = x >> shift;
    if (x & MAX_MAGNITUDE != 0) {
        let bits = (1 << (shift) ) - 1;

        let factor = bits << (BIT_SIZE  - shift);

        rep = rep + factor;
    };

    return rep
}

fun is_positive_int16(a: u16): bool {
    a <= MAX_POSITIVE_INT18
}

fun is_negative_int16(a: u16): bool {
    a >= MIN_NEGATIVE_INT18
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
