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
