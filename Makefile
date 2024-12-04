# minit="./test/config/minit.lua"
#
# nvimf="--headless -u ./test/config/minit.lua --noplugin -c ''"

wf:
	./scripts/bin/wordf
w:
	./scripts/bin/word
wls:
	./scripts/bin/wordls


clean:
	fd --no-ignore --glob "*-E" -x "rm" ./

v:
	nvim -u ./test/config/minit.lua


# books:
#   cd book && mdbook serve

# default: clean
