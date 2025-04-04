/// Module: int8
/// This module provides operations for 8-bit signed integers.

module int::int8;

/// Error code for overflow.
const OverFlowError:u64 = 1;

/// Error code for division by zero.
const DivisionByZeroError :u64 = 2;

/// Error code for negative modulus.
const NegativeMod :u64 = 3;

/// Maximum magnitude for an 8-bit signed integer corresponds to the lowest possible signed integer for 8 bits.
const MAX_MAGNITUDE :u8 = 128; // 1000_0000;

/// maxiumum unsigned number representable as 8-bit .
const LIMIT:u8 = 255; // 1111_1111
// maximum positive integer ,for 8 bis integer this value is +127
const MAX_POSITIVE_INT8:u8 = MAX_MAGNITUDE - 1u8; 
// minimum negative integer ,for 8 bits integer this value is -128
const MIN_NEGATIVE_INT8:u8 = MAX_MAGNITUDE;

/// Structure for 8-bit signed integer.
public struct Int8 has copy,drop,store{
     /// Representation in two's complement.
     rep:u8
}

/// Function to create an Int8 from an unsigned 8-bit integer.
/// Note: only valid for numbers within the range of positive integers for an 8 bit number 
public fun from_uint8(magnitude:u8):Int8{
    return try_from_uint8(magnitude).extract()
}

/// Function to convert an Int8 to an unsigned 8-bit integer.
/// Only converts positive value to value of equal magnitude.
public fun to_uint8(a:Int8):u8{
     return try_to_uint8(a).extract()
}

/// Function to create a new Int8.
/// Note for positive numbers, ensure that number is within the positive range 0...MAX_POSITIVE_INT8  
public fun new(magnitude:u8,is_positive:bool):Int8{
     return try_new(magnitude, is_positive).extract()
}

/// Function to find the maximum of two Int8.
public fun max(a:Int8,b:Int8):Int8{
     let rep = max_int8(a.rep, b.rep);
     return Int8 { rep }
}

/// Function to find the minimum of two Int8.
public fun min(a:Int8,b:Int8):Int8{
     let rep = min_int8(a.rep, b.rep);
     return Int8 { rep }
}

/// Function to check if one Int8 is less than another.
/// checks if a is less than b
public fun lt(a:Int8,b:Int8):bool{
      if (a==b){
          return false
      };
     return a == min(a,b)
}

/// Function to check if one Int8 is greater than another.
/// checks if a is greater than b 
public fun gt(a:Int8,b:Int8):bool{
     if (a==b){
          return false
     };
     return a == max(a,b)
}

/// Function to check if one Int8 is less than or equal to another.
/// checks if a is less than or equal to b
public fun lteq(a:Int8,b:Int8):bool{
     if (a==b){
          return true
     };
     return a == max(a,b)
}

/// Function to check if one Int8 is greater than or equal to another.
/// checks if a is greater than or equal to b
public fun gteq(a:Int8,b:Int8):bool{
     if (a==b){
          return true
     };
     return a == min(a,b)
}

/// Function to check if two Int8 are equal.
public fun eq(a:Int8,b:Int8):bool{
     return a.rep == b.rep
}

/// Function to check if two Int8 are not equal.
public fun ne(a:Int8,b:Int8):bool{
     return a.rep != b.rep
}

/// Function to check if an Int8 is zero.
public fun is_zero(a:Int8):bool{
     return a.rep == 0
}

/// Function to check if an Int8 is positive.
public fun is_positive(a:Int8):bool{
     return is_positive_int8(a.rep)
}

/// Function to check if an Int8 is negative.
public fun is_negative(a:Int8):bool{
     return is_negative_int8(a.rep)
}

/// Function to find the absolute value of an Int8.
public fun abs(a:&Int8):Int8 { 
     assert!(a.rep != MIN_NEGATIVE_INT8);
     if (is_positive_int8(a.rep)){
          return  Int8{rep:a.rep}
     }else{
          let rep = to_2s_complement(a.rep);
          return Int8 {rep}
     }
 }

/// Function to find the negation of an Int8.
public fun neg(a:Int8):Int8{
     assert!(a.rep != MIN_NEGATIVE_INT8);
     let rep = to_2s_complement(a.rep);
     return Int8 {rep}
  
}

/// Function to multiply two Int8.
public fun mul(a:Int8,b:Int8):Int8 { 
     if (a.rep == MIN_NEGATIVE_INT8  || b.rep == MIN_NEGATIVE_INT8){
           assert!(b.rep == 1 || a.rep == 1,OverFlowError);
           return Int8 { rep:MIN_NEGATIVE_INT8 }
     };
     let rep =  mul_int8(a.rep, b.rep);
     return Int8{ rep}
 }

/// Function to divide two Int8.
public fun div(a:Int8,b:Int8):Int8{
     assert!(b.rep != 0,DivisionByZeroError);
     let rep = div_int8(a.rep, b.rep);
     return Int8 { rep }
 }

/// Function to add two Int8.
public fun add(a:Int8,b:Int8):Int8{
     let rep = add_int8(a.rep, b.rep);
     return Int8 { rep }
 }

/// Function to subtract two Int8.
public fun sub(a:Int8,b:Int8):Int8{
     let rep = sub_int8(a.rep, b.rep);
     return Int8 { rep }
}

/// Function to find the modulus of two Int8.
public fun mod(a:Int8,b:Int8):Int8{
    let rep = mod_int8(a.rep,b.rep);
   return Int8 { rep}
}

/// Function to try to convert an unsigned 8-bit integer to an Int8.
/// Note : magnitude must lie within the range of positive int8 numbers
public fun try_from_uint8(magnitude:u8):Option<Int8>{
     if (magnitude > MAX_POSITIVE_INT8){
     return option::none()
     };
     return option::some(Int8 { rep:magnitude})
}

/// Function to try to convert an Int8 to an unsigned 8-bit integer.
/// Only converts positive values.
public fun try_to_uint8(a:Int8):Option<u8>{
     if (a.rep > MAX_POSITIVE_INT8){
          return option::none()
     };
     return option::some(a.rep)
}

/// Function to try to create a new Int8.
public fun try_new(magnitude:u8,is_positive:bool):Option<Int8>{
     if(magnitude > MIN_NEGATIVE_INT8){
               return option::none()
           };
     if (is_positive){
           if(magnitude > MAX_POSITIVE_INT8){
               return option::none()
           };
          return  option::some(   Int8 { rep:magnitude })
     }else{
       
          let twos_comp_rep = to_2s_complement(magnitude);

          return option::some(Int8 { rep:twos_comp_rep })
     }
}

/// Function to find the maximum of two unsigned 8-bit integers.
fun max_int8(a:u8,b:u8):u8 {  
     if (is_positive_int8(a) && is_positive_int8(b)){
          return max_value(a, b)
     }else if (is_negative_int8(a) && is_negative_int8(b)) {
          return max_value(a, b)
     };
     return min_value(a, b)
}

/// Function to find the minimum of two unsigned 8-bit integers.
fun min_int8(a:u8,b:u8):u8{
     if (is_positive_int8(a) && is_positive_int8(b)){
          return min_value(a, b)
     }else if (is_negative_int8(a) && is_negative_int8(b)) {
          return min_value(a, b)
     };
     return max_value(a, b)
}

/// Function to find the modulus of two unsigned 8-bit integers.
fun mod_int8(a:u8,b:u8):u8{
    assert!(is_positive_int8(b),NegativeMod);
   let mut increment = a;
   while (is_negative_int8( increment) ) {
       increment = add_int8(increment, b)
   };
   return increment % b
}

/// Function to multiply two unsigned 8-bit integers.
fun mul_int8(a:u8,b:u8):u8{
     // if both are positive 
     if (is_positive_int8(a) && is_positive_int8(b)){
            assert!((MAX_MAGNITUDE -1)/ a >= b,OverFlowError);

            return a * b
     }else if (is_negative_int8(a) && is_negative_int8(b)){
          // both negative 
            return mul_int8(to_2s_complement(a), to_2s_complement(b))
     }else if (is_negative_int8(b)){
          // a only is positive
           let magnitude= mul_int8(a, to_2s_complement(b));
           return to_2s_complement(magnitude)
     }else {
          // b is positive
           let magnitude= mul_int8(b, to_2s_complement(a));
           return to_2s_complement(magnitude)
     }
}

/// Function to divide two unsigned 8-bit integers.
fun div_int8(a:u8,b:u8):u8{

     if (is_positive_int8(a)  && is_positive_int8(b)){
          //rounds down
           return a/b
     }else if (is_negative_int8(a)  && is_negative_int8(b)){
           // rounds down
            let result =  to_2s_complement(a)/to_2s_complement(b);
            assert!(is_positive_int8(result),OverFlowError);
            return result
     }else if (is_negative_int8(b)){
          //a  only is positive
          // rounds up
          let magnitude =  a/(to_2s_complement(b));
          return to_2s_complement(magnitude)
     }else{
          // b only is positive
          //rounds up
           let magnitude =  (to_2s_complement(a))/b;
          return to_2s_complement(magnitude)
     }
}

/// Function to subtract two unsigned 8-bit integers.
fun sub_int8(min:u8,sub:u8):u8{
     return add_int8(min, to_2s_complement(sub))
}

/// Function to add two unsigned 8-bit integers.
fun add_int8(a:u8,b:u8):u8{
     if (is_positive_int8(a) &&  is_positive_int8(b)){
          // both positive
            assert!((MAX_POSITIVE_INT8) - a >= b,OverFlowError);
            return a + b
     }else if (is_negative_int8(a) &&  is_negative_int8(b)){
            // both a and b are negative
            let magnitude = add_int8(to_2s_complement(a) , to_2s_complement(b));

            return to_2s_complement(magnitude)      
     }else{
             if (LIMIT - a < b){ // exceeds the amount of bit
          
                   return truncated_sum(a, b)
             } else{
                   return a + b 
             } 
     }
}

/// Function to truncate a sum when it exceeds the maximum.
fun truncated_sum(a:u8,b:u8):u8{
     // case 1:the msb  of both  numbers is one 
     if (a & MAX_MAGNITUDE != 0 && b & MAX_MAGNITUDE != 0){
          return ((a ^ MAX_MAGNITUDE) + (b ^ MAX_MAGNITUDE)) 
     }else if (a & MAX_MAGNITUDE == 0){ // case 2: msb of a is 0 
         // if the significant bit of a is 0 => there is a carry from the second msbs addition 
        let reduced_factor = (b ^ MAX_MAGNITUDE) + a; // flip the msb of b to 0 add both terms together
        return reduced_factor ^ MAX_MAGNITUDE // flip the msb of reduced factor 
     }else{ // case 3:msb of b is 0
            let reduced_factor = (a ^ MAX_MAGNITUDE) + b;
        return reduced_factor ^ MAX_MAGNITUDE
     }
}

/// Function to convert an unsigned 8-bit integer to two's complement.
fun to_2s_complement(value:u8):u8{
     if (value == 0){
     return 0
     };
     return (value ^ LIMIT) + 1
}

/// Function to check if an unsigned 8-bit integer is positive.
fun is_positive_int8(a:u8):bool{
  return a  <= MAX_POSITIVE_INT8
}

fun is_negative_int8(a:u8):bool{
     return a >= MIN_NEGATIVE_INT8
}

/// Function to find the maximum of two unsigned 8-bit integers.
fun max_value(a:u8,b:u8):u8{
     if (a>=b){
          return a
     }else {
          return b
     }
}

/// Function to find the minimum of two unsigned 8-bit integers.
fun min_value(a:u8,b:u8):u8{
         if (a <= b){
          return a
     }else {
          return b
     }
}
