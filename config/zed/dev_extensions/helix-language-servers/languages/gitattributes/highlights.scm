; git-config: upstream query, used verbatim.
; https://github.com/the-mikedavis/tree-sitter-git-config
; rev 0fbc9f99d5a28865f9de8427fb0672d66f9d83a5
; Re-sync this file when bumping [grammars.git_config] in extension.toml.

(section_name) @tag

((section_name) @function.builtin
 (#eq? @function.builtin "include"))

((section_header
   (section_name) @function.builtin
   (subsection_name))
 (#eq? @function.builtin "includeIf"))

(variable (name) @property)
[(true) (false)] @constant.builtin
(integer) @number

[(string) (subsection_name)] @string

((string) @string.special.path
 (#match? @string.special.path "^(~|./|/)"))

[
  "["
  "]"
  "\""
] @punctuation.bracket

"=" @punctuation.delimiter

(comment) @comment

(attribute) @variable
(value) @string

(quoted_pattern ["\""] @string)

(attribute_unset) @operator
(attribute_set_to) @operator

; Highlight builtin diff configuration
; The list of languages is taken from here https://git-scm.com/docs/gitattributes#_defining_a_custom_hunk_header
(attribute_set_to
  (attribute) @operator (#eq? @operator "diff")
  (value) @variable.builtin (#any-of? @variable.builtin
    "ada"
    "bash"
    "bibtex"
    "cpp"
    "csharp"
    "css"
    "dts"
    "elixir"
    "fortran"
    "fountain"
    "golang"
    "html"
    "java"
    "kotlin"
    "markdown"
    "matlab"
    "objc"
    "pascal"
    "perl"
    "php"
    "python"
    "ruby"
    "rust"
    "scheme"
    "tex"
  ))

