# minit="./test/config/minit.lua"
#
# nvimf="--headless -u ./test/config/minit.lua --noplugin -c ''"

export PATH=$PATH:$HOME/word/scripts/bin

w:
	./scripts/bin/word
wl:
	./scripts/bin/wordls

iw:
	cp -r ./scripts/bin/word ${HOME}/.local/bin/
iwl:
	cp -r ./scripts/bin/word-lsp ${HOME}/.local/bin/

i: iw iwl

clean:
	fd --no-ignore --glob "*-E" -x "rm" ./

v:
	nvim -u ./test/config/minit.lua # -c 'Lazy install'


# books:
#   cd book && mdbook serve

# default: clean
