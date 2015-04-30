# Bash completion for Yeoman generators - tested in Ubuntu, OS X and Windows (using Git bash)
__yo_generators_all=

function _yo_generator_complete_() {
	# # local node_modules if present
	# local local_modules=$(if [ -d node_modules ]; then echo "node_modules:"; fi)
	# # node_modules in /usr/local/lib if present
	# local usr_local_modules=$(if [ -d /usr/local/lib/node_modules ]; then echo "/usr/local/lib/node_modules:"; fi)
	# # node_modules in user's Roaming/npm (Windows) if present
	# local win_roam_modules=$(if [ -d $(which yo)/../node_modules ]; then echo "$(which yo)/../node_modules:"; fi)
	# # concat and also add $NODE_PATH
	# local node_dirs="${local_modules}${usr_local_modules}${win_roam_modules}${NODE_PATH}"
	# # split $node_dirs and return anything starting with 'generator-', minus that prefix
	# local generators_all=$(for dir in $(echo $node_dirs | tr ":" "\n"); do command ls -1 $dir 2>/dev/null | grep ^generator- | cut -c11-; done)
	# # get the word fragment
	# local word=${COMP_WORDS[COMP_CWORD]}
	# # don't attempt to filter w/`grep` if `$word` is empty
	# local generators_filtered=$(if [ -z "$word" ]; then echo "$generators_all"; else echo "$generators_all" | grep $word; fi)

	# COMPREPLY=($generators_filtered)


	# local cur words cword prev
 #    _get_comp_words_by_ref -n =: cur words cword prev;
	if [[ -z "${__yo_generators_all}" ]] ; then
		__yo_generators_all="$(yo --help --no-color 2>&1 |
			# grep -v "other contributors" |
			egrep '^\s+[a-z\-]+(, [a-z\-]+|)(\s{2,}|:[a-z]+)' | sed -e 's/^\s*//' -e 's/,//' | cut -d ' ' -f 1)"
    fi

	local generators_all="${__yo_generators_all}"

    local word=${COMP_WORDS[COMP_CWORD]}
	# don't attempt to filter w/`grep` if `$word` is empty
	local generators_filtered=$(if [ -z "$word" ]; then echo "$generators_all"; else echo "$generators_all" | grep "$word"; fi)
	COMPREPLY=($generators_filtered)
	__ltrim_colon_completions "$generators_filtered"
}
complete -F _yo_generator_complete_ yo
