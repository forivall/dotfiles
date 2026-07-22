((comment) @injection.content
  (#set! injection.language "comment"))

(script_element
  (raw_text) @injection.content
  (#set! injection.language "javascript"))

(style_element
  (raw_text) @injection.content
  (#set! injection.language "css"))

; CSS injection for mj-style elements
; (mj-style is parsed as a regular element, not style_element)
(element
  (start_tag
    (tag_name) @_tag_name
    (#eq? @_tag_name "mj-style"))
  (text) @injection.content
  (#set! injection.language "css"))

; Inline style attribute CSS injection
(attribute
  (attribute_name) @_attribute_name
  (#match? @_attribute_name "^style$")
  (quoted_attribute_value
    (attribute_value) @injection.content)
  (#set! injection.language "css"))

; Event handler attribute JavaScript injection
(attribute
  (attribute_name) @_attribute_name
  (#match? @_attribute_name "^on[a-z]+$")
  (quoted_attribute_value
    (attribute_value) @injection.content)
  (#set! injection.language "javascript"))
