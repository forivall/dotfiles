	() {
		for p in $(
		  gh api "repos/$1/git/trees/$2?recursive=1" \
		    --jq '"'"$3"'" as $prefix | .tree[] | select(.path | startswith($prefix)) | select(.type == "blob") | .path[($prefix | length):]'
		)
		do
			if [[ $p = */* ]] then mkdir -p "${p:h}"; fi &&
		  curl -sLo "$p" "https://raw.githubusercontent.com/$1/$2/$3$p"
		done
	} pataruco/zed-mjml main languages/mjml/
