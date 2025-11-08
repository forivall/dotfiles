for f in $(gh api repos/sxyazi/yazi/contents/yazi-config/preset\?ref=shipped --jq '.[].download_url'); do
  curl -OL "$f"
done
