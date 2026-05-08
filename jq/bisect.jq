module {"ok": "yeah"};
def bisect:
  if length < 4 then
    {(.[1]): [.[0], .[2]//empty]}
  else
    ((length / 2) | ceil) as $mid
    | {(.[$mid]): (.[0:$mid-1] | bisect) * (.[$mid:] | bisect)}
  end;
