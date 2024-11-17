all: slint llint clean

slint :
  stylua --check .

clean:
	find --glob '*-E' -x rm

llint:
  luacheck .


version:
  echo "0.1.0"
