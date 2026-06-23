# Source - https://stackoverflow.com/a/77608539
# Posted by Jeff Mercado, modified by community. See post 'Timeline' for change history
# Retrieved 2026-05-09, License - CC BY-SA 4.0

def _parse_semver($with_op):
    if type == "string" then
        capture(if $with_op then "(?<op>[~])?" else "" end
        + "(?<major>\\d+)\\.(?<minor>\\d+)(?:\\.(?<patch>\\d+))?"
        + "(?:-(?<prerelease>[A-Z0-9]+(?:\\.[A-Z0-9]+)*))?"
        + "(?:\\+(?<build>[A-Z0-9]+(?:\\.[A-Z0-9]+)*))?"; "i")
        | (.major, .minor, .patch) |= (tonumber? // 0)
    elif type == "object" and ([has(("major,minor,patch,prerelease,build"/",")[])]|all) then .
    else empty end;
def parse_semver: _parse_semver(false);
def cmp_semver($other): parse_semver as $a | ($other|_parse_semver(true)) as $b |
    def _cmp($other): if . == $other then 0 elif . > $other then 1 else -1 end;
    def _cmp_dotted($other):
        if . == null then 1
        elif $other == null then -1
        else
            reduce ([split("."), ($other|split("."))] | transpose[]) as [$a, $b] (0;
                if . != 0 then .
                elif $a == null then -1
                elif $b == null then 1
                else
                    ($a|test("^\\d+$")) as $anum | ($b|test("^\\d+$")) as $bnum |
                    if [$anum,$bnum] == [true,true] then $a | tonumber | _cmp($b | tonumber)
                    elif $anum then -1
                    elif $bnum then 1
                    else $a | _cmp($b) end
                end
            )
        end;
    # slightly modified version of https://semver.org/#spec-item-11
    if $a.major != $b.major then
        if $a.major > $b.major then 1 else -1 end
    elif $a.minor != $b.minor then
        if $a.minor > $b.minor then 1 else -1 end
    elif $a.patch != $b.patch then
        if $a.patch > $b.patch then 1 else -1 end
    elif $b.op == "~" then
        0
    elif $a.prerelease != $b.prerelease then
        ($a.prerelease | _cmp_dotted($b.prerelease))
    elif $a.build != $b.build then
        ($a.build | _cmp_dotted($b.build))
    else
        0
    end;
def cmp_semver($first; $second): $first | cmp_semver($second);

