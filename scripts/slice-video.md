```sh
youtube-dl --embed-subs -f 22 $url
youtube-dl --write-auto-sub -f 22 $url
```

Start and end in `HH:MM:SS` format.

```sh
ffmpeg -i $video_file -vf subtitles=$subtitle_file:force_style=Fontsize=24 -vcodec libx265 -crf 20 -preset veryslow -tag:v hvc1 -c:a copy -ss $start -to $end $output_file
```

```sh
ffmpeg -i $video_file -vf subtitles=$subtitle_file:force_style=Fontsize=24 -vcodec hevc_videotoolbox -b:v 4M -preset veryslow -tag:v hvc1 -c:a copy -ss $start -to $end $output_file
```

