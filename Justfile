all: slint llint clean

v:
  nvim -u test/minit.lua

w:
  ./scripts/bin/word

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
  co -r ./scripts/bin/word


book:
  cd docs && mdbook build
