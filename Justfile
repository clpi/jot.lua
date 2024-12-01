all: slint llint clean

test:
  nvim --headless -u test/minit.lua -c "PlenaryBustedDirectory tests/plenary/ {options}"

nv:
  nvim -u test/config/minit.lua

w:
  ./scripts/bin/jot

wl:
  ./scripts/bin/jotls

t:
  nvim --headless --noplugin -u test/minit.lua

slint :
  stylua --check .

clean:
	fd --glob '*-E' -x rm

llint:
  luacheck .


version:
  echo "0.1.0"

install:
  co -r ./scripts/bin/jot


book:
  cd book && mdbook build

books:
  cd book && mdbook serve
