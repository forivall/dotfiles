((html_comment) @injection.content
 (#set! injection.language "comment"))
((mustache_comment) @injection.content
 (#set! injection.language "comment"))

((html_script_element
  (raw_text) @injection.content)
 (#set! injection.language "javascript"))

((html_style_element
  (raw_text) @injection.content)
 (#set! injection.language "css"))

; e.g. `<input pattern="[Bb]anana|[Cc]herry" />
(html_attribute
  (html_attribute_name) @_attr (#eq? @_attr "pattern")
  (html_quoted_attribute_value
    (html_attribute_value) @injection.content)
  (#set! injection.language "regex"))
