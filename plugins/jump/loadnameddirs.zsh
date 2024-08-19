if [[ -v MARKPATH && ${MARK_CREATENAMEDDIRS:=true} ]]; then
	# load all marks into hash
    () {
        setopt localoptions nullglob
        for d in $MARKPATH/*(@); do hash -d "${d##*/}=${d:A}"; done
    }
fi
