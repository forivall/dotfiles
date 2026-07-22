; MJML root/structure tags — highlighted as keywords
((tag_name) @keyword
  (#match? @keyword "^(mjml|mj-head|mj-body|mj-include)$"))

; MJML head configuration tags — highlighted as types
((tag_name) @type
  (#match? @type
    "^(mj-attributes|mj-all|mj-class|mj-breakpoint|mj-font|mj-html-attributes|mj-preview|mj-style|mj-title)$"))

; Fallback: all other tag names (layout, content, interactive MJML tags and standard HTML)
(tag_name) @tag

(doctype) @tag.doctype

(attribute_name) @attribute

[
  "\""
  "'"
  (attribute_value)
] @string

(comment) @comment

(entity) @string.special

"=" @punctuation.delimiter

[
  "<"
  ">"
  "<!"
  "</"
  "/>"
] @punctuation.bracket
