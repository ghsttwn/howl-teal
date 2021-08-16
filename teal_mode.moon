--- Teal mode internals

import style from howl.ui

style.define 'longstring', 'string'

class TealMode
  new: =>
    @lexer = bundle_load 'teal_lexer'
    @completers = { 'in_buffer' }

  default_config:
    inspectors_on_idle: { 'tl' }

  comment_syntax: '--'

  auto_pairs: {
    '<': '>'
    '(': ')'
    '[': ']'
    '{': '}'
    '"': '"'
    "'": "'"
  }

  indentation: {
    more_after: {
      r'[({=]\\s*(--.*|)$' -- hanging operators
      r'function\\b\\s*[^(]*\\([^)]*\\)\\s*(--.*|)$' -- function starter
      r'\\b(then|do)\\b\\s*(--.*|)$', -- block starters
      { '^%s*if%s+', '%s+end$' }
      r'^\\s*else\\b',
    }

    less_for: {
      r'^\\s*end\\b'
      '^%s*}'
      r'^\\s*else\\b'
      r'^\\s*elseif\\b'
      r'^\\s*\\}\\b'
    }
  }

  code_blocks:
    multiline: {
      { r'\\s+then\\s*$', '^%s*end', 'end' },
      { r'(^\\s*|\\s+)function\\s*\\([^)]*\\)\\s*$', '^%s*end', 'end' },
      { r'^\\s*function\\s+\\w+[_:.\\w]+\\s*\\([^)]*\\)\\s*$', '^%s*end', 'end' },
      { r'\\s+record\\s*$', '^%s*end', 'end' },
      { r'\\s+enum\\s*$', '^%s*end', 'end' },
      { r'(^\\s*|\\s+)do\\s*$', '^%s*end', 'end' },
      { r'^\\s*repeat\\s*$', '^%s*until', 'until' },
    }

TealMode
