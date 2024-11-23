all: slint llint clean


v:
	nvim --no-plugins -u test/minit.lua
tv:
  nvim -u test/config/init.lua

slint :
  stylua --check .

clean:
	fd --glob '*-E' -x rm

llint:
  luacheck .


version:
  echo "0.1.0"
