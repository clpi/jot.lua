all: slint llint clean

minit := "./test/config/minit.lua"

nvimf := "--headless -u ./test/config/minit.lua --noplugin -c ''"

test:
  nvim --headless -u test/minit.lua -c "PlenaryBustedDirectory tests/plenary/ {options}"

doc:
  nvim --headless --noplugin -u test/config/minit.lua -c "luafile scripts/gendoc.lua" -c "qa"

nv:
  nvim -u test/config/minit.lua

w:
  ./scripts/bin/word

wl:
  ./scripts/bin/wordls

t:
  nvim --headless --noplugin -u test/minit.lua

slint :
  stylua --check .

clean:
	fd --no-ignore --glob '*-E' -x 'rm' ./

llint:
  luacheck .


version:
  echo "0.1.0"

install:
  co -r ./scripts/bin/word


book:
  cd book && mdbook build

books:
  cd book && mdbook serve
