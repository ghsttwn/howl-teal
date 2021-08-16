tl = require "tl"

inspector = (buffer) ->
  inspections = {}
  file = buffer.file

  {
   :syntax_errors,
   :type_errors,
   :warnings
  } = tl.process_string buffer.text, false, nil, file

  if warnings and warnings[1]
    for warn in *warnings
      table.insert inspections, {
        line: warn.y
        type: 'warning',
        message: warn.msg,
        byte_start_col: warn.x
      }

  if syntax_errors and syntax_errors[1]
    for err in *syntax_errors
      table.insert inspections, {
        line: err.y
        type: 'error',
        message: err.msg,
        byte_start_col: err.x
      }

  if type_errors and type_errors[1]
    for err in *type_errors
      table.insert inspections, {
        line: err.y
        type: 'error',
        message: err.msg,
        byte_start_col: err.x
      }

  inspections

inspector
