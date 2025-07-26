Notes on Lua
- Array indexes start at 1.
- 0 is a truthy value.
- In lua files get treated as functions, so when including a file foo.lua with local foo = require('foo'),
  whatever is returned at the end of that file will be assigned to the foo variable.
- With function calls, you can drop the parentheses if you are calling it with a single string literal or table,
  e.g. print "Hello there!", or setup { default = 12, other = false }.
- .. is the concat operator for strings, e.g. "Hello " .. "there!"
- When defining a function on a table, you can use : instead of . as shorthand for inserting a self arg as first param:
  ```lua
  local myTable = {}

  function myTable.something(self, ...) end
  -- is the same as
  function myTable:something(...) end
- setmetatable can be used to overwrite how default functionality of a table is handled, 
  e.g. __add for adding two tables together.
  ```
- Multiline text literals can be represented with square brackets: 
  [[ 
    Some
    text
    that continues
    over lines.
  ]]
  Can also be used for keymappings where the " character can't be used, as it is being used to specify
  a register.

