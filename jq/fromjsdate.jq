def fromjsdate:
  match("^(.*)\\.([0-9]+)Z$") | (
    ((.captures.[0].string + "Z") | fromdate) * 1000 +
    (.captures.[1].string | tonumber)
  );
