(html_tag_name) @tag
(html_erroneous_end_tag_name) @error
(html_doctype) @constant
(html_attribute_name) @attribute
(html_entity) @string.special.symbol
(html_comment) @comment

((html_attribute
  (html_attribute_name) @attribute
  (html_quoted_attribute_value (attribute_value) @markup.link.url))
 (#any-of? @attribute "href" "src"))

((html_element
  (html_start_tag
    (html_tag_name) @tag)
  (text) @markup.link.label)
  (#eq? @tag "a"))

(html_attribute [(html_attribute_value) (html_quoted_attribute_value)] @string)

((html_element
  (html_start_tag
    (html_tag_name) @tag)
  (text) @markup.bold)
  (#any-of? @tag "strong" "b"))

((html_element
  (html_start_tag
    (html_tag_name) @tag)
  (text) @markup.italic)
  (#any-of? @tag "em" "i"))

((html_element
  (html_start_tag
    (html_tag_name) @tag)
  (text) @markup.strikethrough)
  (#any-of? @tag "s" "del"))

[
  "<"
  ">"
  "</"
  "/>"
  "<!"
] @punctuation.bracket

"=" @punctuation.delimiter

; Mustache
(mustache_tag_name) @variable
(mustache_identifier) @variable
(mustache_comment) @comment

[
  "{{"
  "}}"
  "{{{"
  "}}}"
  "{{>"
  "{{#"
  "{{/"
  "{{^"
] @keyword
