module int::int64;

const OverFlowError: u64 = 1;
const DivisionByZeroError: u64 = 2;
const NegativeMod: u64 = 3;

const BIT_SIZE: u8 = 64;
const MAX_MAGNITUDE: u64 = 1 << (BIT_SIZE - 1); // 2^63
const LIMIT: u64 = MAX_MAGNITUDE + (MAX_MAGNITUDE - 1);
const MAX_POSITIVE_INT64: u64 = MAX_MAGNITUDE - 1;
const MIN_NEGATIVE_INT64: u64 = MAX_MAGNITUDE;

public struct Int64 has copy, drop, store {
     rep: u64,
}

public fun from_raw_bits(bits: u64): Int64 {
     return Int64 { rep: bits }
}

public fun from_u64(magnitude: u64): Int64 {
     try_from_uint64(magnitude).extract()
}

public fun try_from_uint64(magnitude: u64): Option<Int64> {
     if (magnitude > MAX_POSITIVE_INT64) {
          option::none()
     } else {
          option::some(Int64 { rep: magnitude })
     }
}

public fun new(magnitude: u64, is_positive: bool): Int64 {
     try_new(magnitude, is_positive).extract()
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

public fun to_u64(a: Int64): u64 {
     try_to_uint64(a).extract()
}

public fun try_to_uint64(a: Int64): Option<u64> {
     if (a.rep > MAX_POSITIVE_INT64) {
          option::none()
     } else {
          option::some(a.rep)
     }
}

public fun raw_bit(a: Int64): u64 {
     return a.rep
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

public fun is_nat(a: Int64): bool {
     return a.rep > 0 && a.rep < MIN_NEGATIVE_INT64
}

public fun shl(x: Int64, shift: u8): Int64 {
     let rep = x.rep << shift;
     return Int64 { rep }
}

public fun shr(x: Int64, shift: u8): Int64 {
     let rep = shr_int64(x.rep, shift);
     return Int64 { rep }
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

public fun try_add(a: Int64, b: Int64): Option<Int64> {
     let mut rep = try_add_int64(a.rep, b.rep);

     if (option::is_none(&rep)) {
          return option::none()
     };
     option::some(Int64 { rep: (&mut rep).extract() })
}

public fun sub(a: Int64, b: Int64): Int64 {
     let rep = sub_int64(a.rep, b.rep);
     Int64 { rep }
}

public fun try_sub(a: Int64, b: Int64): Option<Int64> {
     let mut rep = try_sub_int64(a.rep, b.rep);
     if (option::is_none(&rep)) {
          return option::none()
     };
     option::some(Int64 { rep: (&mut rep).extract() })
}

public fun mul(a: Int64, b: Int64): Int64 {
     let rep = mul_int64(a.rep, b.rep);
     Int64 { rep }
}

public fun try_mul(a: Int64, b: Int64): Option<Int64> {
     let mut rep = try_mul_int64(a.rep, b.rep);
     if (option::is_none(&rep)) {
          return option::none()
     };
     option::some(Int64 { rep: (&mut rep).extract() })
}

public fun div(a: Int64, b: Int64): Int64 {
     assert!(b.rep != 0, DivisionByZeroError);
     let rep = div_int64(a.rep, b.rep);
     Int64 { rep }
}

public fun try_div(a: Int64, b: Int64): Option<Int64> {
     assert!(b.rep != 0, DivisionByZeroError);
     let mut rep = try_div_int64(a.rep, b.rep);
     if (option::is_none(&rep)) {
          return option::none()
     };
     option::some(Int64 { rep: (&mut rep).extract() })
}

public fun mod(a: Int64, b: Int64): Int64 {
     let rep = mod_int64(a.rep, b.rep);
     Int64 { rep }
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
     let mut result = try_mul_int64(a, b);
     if (option::is_none(&result)) {
          abort OverFlowError
     };
     result.extract()
}

fun try_mul_int64(a: u64, b: u64): Option<u64> {
     if (is_positive_int64(a) && is_positive_int64(b)) {
          if (safe_multiply(a, b)) {
               return option::some(a * b)
          };
     } else if (is_negative_int64(a) && is_negative_int64(b)) {
          let a_neg = to_2s_complement(a);
          let b_neg = to_2s_complement(b);
          if (safe_multiply(a_neg, b_neg)) {
               let result = a_neg * b_neg;
               return option::some(result)
          }
     } else if (is_negative_int64(b)) {
          let b_neg = to_2s_complement(b);
          if (safe_multiply(a, b_neg)) {
               return option::some(to_2s_complement(a* b_neg))
          }
     } else {
          let a_neg = to_2s_complement(a);
          if (safe_multiply(b, a_neg)) {
               return option::some(to_2s_complement(a_neg * b))
          }
     };
     return option::none()
}

fun safe_multiply(a: u64, b: u64): bool {
     return MAX_POSITIVE_INT64 / a >= b
}

fun div_int64(a: u64, b: u64): u64 {
     let mut result = try_div_int64(a, b);
     if (option::is_none(&result)) {
          abort OverFlowError
     };
     result.extract()
}

fun try_div_int64(a: u64, b: u64): Option<u64> {
     if (is_positive_int64(a) && is_positive_int64(b)) {
          return option::some(a / b)
     } else if (is_negative_int64(a) && is_negative_int64(b)) {
          let result = to_2s_complement(a) / to_2s_complement(b);
          if (is_negative_int64(result)) {
               return option::none()
          };
          option::some(result)
     } else if (is_negative_int64(b)) {
          let magnitude = a / to_2s_complement(b);
          option::some(to_2s_complement(magnitude))
     } else {
          let magnitude = to_2s_complement(a) / b;
          option::some(to_2s_complement(magnitude))
     }
}

fun sub_int64(a: u64, b: u64): u64 {
     let mut result = try_sub_int64(a, b);
     if (option::is_none(&result)) {
          abort OverFlowError
     };
     result.extract()
}

fun try_sub_int64(a: u64, b: u64): Option<u64> {
     try_add_int64(a, to_2s_complement(b))
}

fun add_int64(a: u64, b: u64): u64 {
     let mut result = try_add_int64(a, b);
     if (option::is_none(&result)) {
          abort OverFlowError
     };
     result.extract()
}

fun try_add_int64(a: u64, b: u64): Option<u64> {
     if (is_positive_int64(a) && is_positive_int64(b)) {
          if (safe_add(a, b)) {
               return option::some(a + b)
          };
     } else if (is_negative_int64(a) && is_negative_int64(b)) {
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

fun safe_add(a: u64, b: u64): bool {
     return MAX_POSITIVE_INT64 - a >= b
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

fun shr_int64(x: u64, shift: u8): u64 {
     let mut rep = x >> shift;
     if (x & MAX_MAGNITUDE != 0) {
          let bits = (1 << (shift) ) - 1;

          let factor = bits << (BIT_SIZE - shift);

          rep = rep + factor;
     };

     return rep
}

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