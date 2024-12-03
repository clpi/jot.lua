# Copilot prompts

`not checked by github`

## Parsing

### Datetimes

- Write a lua module in the format of other modules in this repository that parses markdown list task items which contain patterns similar to the following...
  - `[...] by <date|time|datetime> [...]`
  - `[...] at <date|time|datetime> [...]`
  - `[...] tomorrow <'morning'|'evening'|'afternoon'|...> [...]`
  - `[...] next <'sunday'|'monday'|'tuesday'|'wednesday'|'thursday'|'friday'|'saturday'> [...]`
  - `[...] in <duration> <'hours'|'seconds|'minutes'|'days'|'weeks'|'months'|'years'> [...]`
  - `etc.`
    ...into structured data, and be liberal with regards to extrapolating other possible patterns to match for.

1. Write a lua function
