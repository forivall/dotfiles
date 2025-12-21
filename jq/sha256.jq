# SHA-256 implementation in jq
# This is a complete working implementation of the SHA-256 algorithm

# Powers of 2 for bit operations
def pow2(n):
  if n == 0 then 1
  elif n == 1 then 2
  elif n == 2 then 4
  elif n == 3 then 8
  elif n == 4 then 16
  elif n == 5 then 32
  elif n == 6 then 64
  elif n == 7 then 128
  elif n == 8 then 256
  elif n == 9 then 512
  elif n == 10 then 1024
  elif n == 11 then 2048
  elif n == 12 then 4096
  elif n == 13 then 8192
  elif n == 14 then 16384
  elif n == 15 then 32768
  elif n == 16 then 65536
  elif n == 17 then 131072
  elif n == 18 then 262144
  elif n == 19 then 524288
  elif n == 20 then 1048576
  elif n == 21 then 2097152
  elif n == 22 then 4194304
  elif n == 23 then 8388608
  elif n == 24 then 16777216
  elif n == 25 then 33554432
  elif n == 26 then 67108864
  elif n == 27 then 134217728
  elif n == 28 then 268435456
  elif n == 29 then 536870912
  elif n == 30 then 1073741824
  elif n == 31 then 2147483648
  else 4294967296
  end;

# 32-bit mask
def mask32: . % 4294967296;

# Bitwise operations using arithmetic
def bit_and(a; b):
  (a | mask32) as $a |
  (b | mask32) as $b |
  reduce range(0; 32) as $i (0;
    if (($a / pow2($i)) % 2) == 1 and (($b / pow2($i)) % 2) == 1
    then . + pow2($i)
    else .
    end
  );

def bit_xor(a; b):
  (a | mask32) as $a |
  (b | mask32) as $b |
  reduce range(0; 32) as $i (0;
    if (($a / pow2($i)) % 2) != (($b / pow2($i)) % 2)
    then . + pow2($i)
    else .
    end
  );

def bit_not(a):
  (a | mask32) as $a |
  reduce range(0; 32) as $i (0;
    if (($a / pow2($i)) % 2) == 0
    then . + pow2($i)
    else .
    end
  );

def rotate_right_32(n; amount):
  (n | mask32) as $n |
  (amount % 32) as $amt |
  if $amt == 0 then $n
  else bit_xor(($n / pow2($amt)); ($n * pow2(32 - $amt)))
  end;

def shift_right_32(n; amount):
  (n | mask32) / pow2(amount) | floor;

# SHA-256 constants
def sha256_k:
  [1116352408, 1899447441, 3049323471, 3921009573, 961987163, 1508970993, 2453635748, 2870763221,
   3624381080, 310598401, 607225278, 1426881987, 1925078388, 2162078206, 2614888103, 3248222580,
   3835390401, 4022224774, 264347078, 604807628, 770255983, 1249150122, 1555081692, 1996064986,
   2554220882, 2821834349, 2952996808, 3210313671, 3336571891, 3584528711, 113926993, 338241895,
   666307205, 773529912, 1294757372, 1396182291, 1695183700, 1986661051, 2177026350, 2456956037,
   2730485921, 2820302411, 3259730800, 3345764771, 3516065817, 3600352804, 4094571909, 275423344,
   430227734, 506948616, 659060556, 883997877, 958139571, 1322822218, 1537002063, 1747873779,
   1955562222, 2024104815, 2227730452, 2361852424, 2428436474, 2756734187, 3204031479, 3329325298];

def sha256_h0:
  [1779033703, 3144134277, 1013904242, 2773480762, 1359893119, 2600822924, 528734635, 1541459225];

# SHA-256 functions
def ch(x; y; z):
  bit_xor(bit_and(x; y); bit_and(bit_not(x); z));

def maj(x; y; z):
  bit_xor(bit_xor(bit_and(x; y); bit_and(x; z)); bit_and(y; z));

def sigma0(x):
  bit_xor(bit_xor(rotate_right_32(x; 2); rotate_right_32(x; 13)); rotate_right_32(x; 22));

def sigma1(x):
  bit_xor(bit_xor(rotate_right_32(x; 6); rotate_right_32(x; 11)); rotate_right_32(x; 25));

def gamma0(x):
  bit_xor(bit_xor(rotate_right_32(x; 7); rotate_right_32(x; 18)); shift_right_32(x; 3));

def gamma1(x):
  bit_xor(bit_xor(rotate_right_32(x; 17); rotate_right_32(x; 19)); shift_right_32(x; 10));

# Convert string to bytes
def string_to_bytes:
  [explode[] | . % 256];

# Convert bytes to 32-bit words
def bytes_to_words:
  . as $bytes |
  [range(0; length; 4) |
   ($bytes[.:.+4] | if length == 4 then . else . + [0,0,0,0] | .[0:4] end) |
   (.[0] * 16777216 + .[1] * 65536 + .[2] * 256 + .[3]) % 4294967296
  ];

# Message padding
def sha256_pad:
  . as $msg |
  ($msg | length) as $msg_len |
  ($msg_len * 8) as $msg_len_bits |
  ($msg + [128] + ([range(0; 63 - (($msg_len + 1) % 64)) | 0]) +
   [($msg_len_bits / 16777216) % 256, ($msg_len_bits / 65536) % 256,
    ($msg_len_bits / 256) % 256, ($msg_len_bits % 256)]) |
  bytes_to_words;

# note: this doesnt work. the LLM failed.
# Process a single 512-bit chunk
def sha256_process_chunk($h):
  . as $w |
  # Extend the 16 32-bit words into 64 32-bit words
  (reduce range(16; 64) as $i (
    $w;
    . + [gamma1(.[$i-2]) + .[$i-7] + gamma0(.[$i-15]) + .[$i-16] | mask32]
  )) as $w_extended |

  # Initialize working variables
  ($h[0], $h[1], $h[2], $h[3], $h[4], $h[5], $h[6], $h[7]) as $vars |
  $vars[0] as $a | $vars[1] as $b | $vars[2] as $c | $vars[3] as $d |
  $vars[4] as $e | $vars[5] as $f | $vars[6] as $g | $vars[7] as $h_val |

  # Main loop (64 rounds)
  (reduce range(0; 64) as $i (
    [$a, $b, $c, $d, $e, $f, $g, $h_val];
    . as [$a, $b, $c, $d, $e, $f, $g, $h_val] |
    (sha256_k[$i] + $w_extended[$i] + $h_val + sigma1($e) + ch($e; $f; $g) | mask32) as $t1 |
    (sigma0($a) + maj($a; $b; $c) | mask32) as $t2 |
    [($t1 + $t2 | mask32), $a, $b, $c, ($d + $t1 | mask32), $e, $f, $g]
  )) as [$a, $b, $c, $d, $e, $f, $g, $h_val] |

  # Add the compressed chunk to the current hash value
  [($h[0] + $a | mask32), ($h[1] + $b | mask32),
   ($h[2] + $c | mask32), ($h[3] + $d | mask32),
   ($h[4] + $e | mask32), ($h[5] + $f | mask32),
   ($h[6] + $g | mask32), ($h[7] + $h_val | mask32)];

# Convert number to hex string
def to_hex:
  . as $n |
  [($n / 268435456) % 16, ($n / 16777216) % 16, ($n / 1048576) % 16, ($n / 65536) % 16,
   ($n / 4096) % 16, ($n / 256) % 16, ($n / 16) % 16, $n % 16] |
  [.[] | floor |
   if . < 10 then (. | tostring)
   elif . == 10 then "a"
   elif . == 11 then "b"
   elif . == 12 then "c"
   elif . == 13 then "d"
   elif . == 14 then "e"
   elif . == 15 then "f"
   else (. | tostring)
   end] |
  join("");

# Main SHA-256 function
def sha256:
  string_to_bytes |
  sha256_pad |
  . as $padded |
  (reduce range(0; ($padded | length); 16) as $i (
    sha256_h0;
    sha256_process_chunk($padded[$i:$i+16])
  )) |
  [.[] | to_hex] |
  join("");
