apm-install-all () {
  comm -13 --nocheck-order \
    <(apm list --bare --installed | cut -f1 -d@) \
    <(< "$1" cut -f1 -d@) | xargs apm install
}
