# minit="./test/config/minit.lua"
#
# nvimf="--headless -u ./test/config/minit.lua --noplugin -c ''"

w:
	./scripts/bin/down
wl:
	./scripts/bin/downls

lnw:
  rm -rf ./down
  ln -s ./scripts/bin/down ./down
lnwl:
  rm -rf ./down-lsp
  ln -s ./scripts/bin/down-lsp ./down-lsp

iw: lnw
	cp -r ./scripts/bin/down ${HOME}/.local/bin/
iwl: lnwl
	cp -r ./scripts/bin/down-lsp ${HOME}/.local/bin/

i: iw iwl

clean:
	fd --no-ignore --glob "*-E" -x "rm" ./

v:
	nvim -u ./test/config/minit.lua # -c 'Lazy install'


# books:
#   cd book && mdbook serve

# default: clean
