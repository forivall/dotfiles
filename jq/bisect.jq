module {"ok": "yeah"};
def bisect:
  if length < 3 then
    {(.[0]): .[1]}
  elif length < 4 then
    {(.[1]): [.[0], .[2]]}
  else
    ((length / 2) | floor) as $mid
    | {(.[$mid]): (.[0:$mid] | bisect) * (.[$mid+1:] | bisect)}
  end;
