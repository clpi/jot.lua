# minit="./test/config/minit.lua"
#
# nvimf="--headless -u ./test/config/minit.lua --noplugin -c ''"

lint:
  @printf "\nLuacheck\n"
  luacheck --config .luacheckrc ./lua ./test
  @printf "\nSelene\n"
  selene --display-style=quiet lua/* test/*
  @printf "\nStylua\n"
  stylua --check .

w:
	./scripts/bin/down

wl:
  ./scripts/bin/down-lsp

wsl:
  ./scripts/bin/down-lsp.sh

lnw:
  rm -rf ./down
  ln -s ./scripts/bin/down ./down
lnwl:
  rm -rf ./down-lsp
  ln -s ./scripts/bin/down-lsp ./down-lsp
lnwls:
  rm -rf ./down-lsp.sh
  ln -s ./scripts/bin/down-lsp.sh ./down-lsp.sh

iw: lnw
	cp -r ./scripts/bin/down ${HOME}/.local/bin/
iwl: lnwl
	cp -r ./scripts/bin/down-lsp ${HOME}/.local/bin/
iwls: lnwls
	cp -r ./scripts/bin/down-lsp.sh ${HOME}/.local/bin/

i: iw iwl iwls

clean:
	fd --no-ignore --glob "*-E" -x "rm" ./

v:
	nvim -u ./test/config/init.lua --noplugin # -c 'Lazy install'



# books:
#   cd book && mdbook serve

# default: clean
