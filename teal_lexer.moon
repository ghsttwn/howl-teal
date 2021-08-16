--- Teal Lpeg lexer, based on the lexer from the Lua bundle

howl.util.lpeg_lexer ->
  c = capture

  keyword = c 'keyword', word {
     'and', 'break', 'do', 'elseif', 'else', 'end',
     'false', 'for', 'function',  'goto', 'if', 'in',
     'local', 'nil', 'not', 'or', 'repeat', 'return',
     'then', 'true', 'until', 'while', 'record',
     'enum', 'global', 'type'
  }

  bracket_quote_lvl_start = P'[' * Cg(P('=')^0, 'lvl') * '['
  bracket_quote_lvl_end = ']' * match_back('lvl') * ']'
  bracket_quote =  bracket_quote_lvl_start * scan_to(bracket_quote_lvl_end)^-1

  comment = c 'comment', '--' * any {
    bracket_quote,
    scan_until eol,
  }

  sq_string = span("'", "'", '\\')
  dq_string = span('"', '"', P'\\')

  string = c 'string', any {
    sq_string,
    dq_string,
    bracket_quote
  }

  operator = c 'operator', S'+-*!/%^#~=<>;:,.(){}[]'

  hexadecimal_number = P'0' *
                       S'xX' * xdigit^1 * (P'.' * xdigit^1)^0 * (S'pP' * S'-+'^0 * xdigit^1)^0
  float = digit^0 * P'.' * digit^1
  number = c 'number', any({
    hexadecimal_number * any('LL', 'll', 'ULL', 'ull')^-1,
    digit^1 * any { 'LL', 'll', 'ULL', 'ull' },
    (float + digit^1) * (S'eE' * P('-')^0 * digit^1)^0
  })

  ident = (alpha + '_')^1 * (alpha + digit + '_')^0
  identifier = c 'identifier', ident
  constant = c 'constant', upper^1 * any(upper, '_', digit)^0 * any(eol, -#lower)
  type_def = sequence {
    c 'keyword', word { 'record', 'enum', 'type' },
    c 'whitespace', blank^1,
    c 'type_def', upper^1 * (alpha + digit + '_')^0
  }
  type_name = c 'type', upper^1 * (alpha + digit + '_')^0
  builtin_type = c 'type', word {
    'any', 'boolean', 'integer', 'number', 'string',
    'thread', 'userdata'
  }

  special = c 'special', any {
    'true',
    'false',
    'nil',
    '_' * upper^1 -- variables conventionally reserved for Lua
  }

  ws = c 'whitespace', blank^0

  fdecl = any {
    sequence {
      c('keyword', 'function'),
      c 'whitespace', blank^1,
      c('fdecl', ident * (S':.' * ident)^-1)
    },
    sequence {
      c('fdecl', ident),
      ws,
      c('operator', '='),
      ws,
      c('keyword', 'function'),
      -#any(digit, alpha)
    }
  }

  cdef = sequence {
    any {
      sequence {
        c('identifier', 'ffi'),
        c('operator', '.'),
      },
      line_start
    },
    c('identifier', 'cdef'),
    c('operator', '(')^-1,
    ws,
    any {
      sequence {
        c('string', bracket_quote_lvl_start),
        sub_lex('c', bracket_quote_lvl_end),
        c('string', bracket_quote_lvl_end)^-1,
      },
      sequence {
        c('string', '"'),
        sub_lex('c', '"'),
        c('string', '"')^-1,
      },
      sequence {
        c('string', "'"),
        sub_lex('c', "'"),
        c('string', "'")^-1,
      }
    }
  }

  any {
    number,
    string,
    comment,
    operator,
    special,
    type_def,
    builtin_type,
    fdecl,
    keyword,
    cdef,
    constant,
    type_name,
    identifier,
  }
