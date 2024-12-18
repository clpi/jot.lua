#!/usr/bin/env bash

#    +--------------------+ down-lsp +--------------------+    #
#    |                                                    |    #
#    |    down-lsp   v0.1.0-alpha                         |    #
#    |                                                    |    #
#    |    ABOUT                                           |    #
#    |      down-lsp is a dev-focused note-taking         |    #
#    |      environment for markdown, in development.     |    #
#    |                                                    |    #
#    |    USAGE                                           |    #
#    |       down-lsp  [options]  <args>  [file]          |    #
#    |                                                    |    #
#    |    OPTIONS                                         |    #
#    |      -h, --help         Show help and exit         |    #
#    |      -v, --version      Show version and exit      |    #
#    |      -i, --interactive  Run in interactive mode    |    #
#    |      -e, --execute      Run in execute mode        |    #
#    |      -c, --config       Specify a config file      |    #
#    |                                                    |    #
#    |    ARGS                                            |    #
#    |      serve             Run the server              |    #
#    |      init              Initialize the server       |    #
#    |      shell             Run the shell               |    #
#    |      update            Update the server           |    #
#    |      install           Install the server          |    #
#    |      uninstall         Uninstall the server        |    #
#    |      config            Configure the server        |    #
#    |      status            Show the server status      |    #
#    |      start             Start the server            |    #
#    |      stop              Stop the server             |    #
#    |      restart           Restart the server          |    #
#    |                                                    |    #
#    |    EXAMPLES                                        |    #
#    |      down-lsp serve                                |    #
#    |      down-lsp shell                                |    #
#    |                                                    |    #
#    +----------------------------------------------------+    #
#
#    +--------------------+  export  +--------------------+    #
#    |                                                    |    #
#    |  define exports.                                   |    #
#    |                                                    |    #
#    +----------------------------------------------------+    #

export DOWN_LSP_BIN="down-lsp"
export DOWN_LSP_COMPLETIONS=$(head </usr/share/dict/words -n 1000 | jq --raw-input --slurp 'split("\n")[:-1] | map({label: . })')
export DOWN_LSP_SERVERINFO='{
  "name": "down-lsp",
  "version": "0.0.1"
}'
export DOWN_LSP_CLIENTINFO='{
  "name": "down-lsp",
  "version": "0.0.1"
}'
export DOWN_LSP_CAPABILITIES='{
  "textDocumentSync": 1,
  "hoverProvider": true,
  "completionProvider": {
    "resolveProvider": true,
    "triggerCharacters": [".", "_", "*", "%", "<", "#", "[", "(",  "/", "-", "@", "#", ":", "|", "$", "&"]
  }
}'

#    +---------------------+  vars  +----------------------+    #
#    |                                                     |    #
#    |  define vars.                                       |    #
#    |                                                     |    #
#    +-----------------------------------------------------+    #

DOWN_LSP_DEBUG=false
DOWN_LSP_STDIO=false
DOWN_LSP_PORT=2088
DOWN_LSP_HOST=localhost

#    +---------------------+  func  +----------------------+    #
#    |                                                     |    #
#    |  define functions.                                  |    #
#    |                                                     |    #
#    +-----------------------------------------------------+    #

# param 1: id
# param 2: result
function lsp-reply() {
  reply '{
    "jsonrpc": "2.0",
    "id": '"$1"',
    "result": '"$2"'
  }'
}

function reply() {
  local b="$1"
  local len=${#b}
  local r="Content-Length: $len\r\n\r\n$b"
  echo -e "$r" >>/tmp/out.log
  echo -e "$r"
}

# param 1: id
# param 2: method
function lsp-handle() {
  ID="$1"
  METHOD="$2"
  case $2 in
  'initialize') lsp-reply $ID '{
    "clientInfo": '"$DOWN_LSP_CLIENTINFO"',
    "capabilities": '"$DOWN_LSP_CAPABILITIES"'
  }' ;;
  'textDocument/moniker') lsp-reply "$ID" '[]' ;;
  'textDocument/codeLens') lsp-reply "$ID" '[]' ;;
  'textDocument/definition') lsp-reply "$ID" '[]' ;;
  'textDocument/documentHighlight') lsp-reply "$ID" '[]' ;;
  'textDocument/documentLink') lsp-reply "$ID" '[]' ;;
  'textDocument/publishDiagnostics') lsp-reply $ID '[]' ;;
  'textDocument/signatureHelp') lsp-reply $ID '{
    "signatures": [],
    "activeSignature": 0,
    "activeParameter": 0
  }' ;;
  'textDocument/completion') lsp-reply "$ID" '{
    "isIncomplete": false,
    "items": '"$DOWN_LSP_COMPLETIONS"'
  }' ;;
  'textDocument/rename') lsp-reply "$ID" 'null' ;;
  'textDocument/formatting') lsp-reply "$ID" '[]' ;;
  'textDocument/rangeFormatting') lsp-reply "$ID" '[]' ;;
  'textDocument/onTypeFormatting') lsp-reply "$ID" '[]' ;;
  'textDocument/prepareRename') lsp-reply "$ID" 'null' ;;
  'textDocument/hover') lsp-reply "$ID" '{
    "contents": {
      "kind": "markdown",
      "value": "```python\nhello world\n```"
    }
  }' ;;
  esac

}
function lsp-format() {
  echo -e ""
}
lsp-test() {
  echo -e "test..."
}

function lsp-serve() {
  echo -e "Serving at " $DOWN_LSP_PORT
  while IFS= read -r LN; do
    [[ "$LN" =~ ^Content-Length:\ ([0-9]+) ]]
    LEN="${BASH_REMATCH[1]}"
    LEN=$((len + 2))
    PAYLOAD=$(head -c "$LEN")
    ID=$(echo -E "$PAYLOAD" | jq --raw-output '.id')
    METHOD=$(echo -E "$PAYLOAD" | jq --raw-output '.method')
    log $ID $METHOD
    lsp-handle $ID $METHOD
  done

}

#    +--------------------+  style  +----------------------+    #
#    |                                                     |    #
#    |  define style utilities.                            |    #
#    |                                                     |    #
#    +-----------------------------------------------------+    #

X="\x1b[0m" # RESET
B="\x1b[1m" # BOLD
D="\x1b[2m" # DIM
I="\x1b[3m" # ITALIC
U="\x1b[4m" # UNDERLINE
L="\x1b[5m" # BLINK
R="\x1b[7m" # REVERSE
H="\x1b[8m" # HIDDEN
F="\x1b[9m" # STRIKE

FL="\x1b[30m" # FG BLACK
FR="\x1b[31m" # FG RED
FG="\x1b[32m" # FG GREEN
FY="\x1b[33m" # FG YELLOW
FB="\x1b[34m" # FG BLUE
FM="\x1b[35m" # FG MAGENTA
FC="\x1b[36m" # FG CYAN
FW="\x1b[37m" # FG WHITE

BL="\x1b[40m" # BG BLACK
BR="\x1b[41m" # BG RED
BG="\x1b[42m" # BG GREEN
BY="\x1b[43m" # BG YELLOW
BB="\x1b[44m" # BG BLUE
BM="\x1b[45m" # BG MAGENTA
BC="\x1b[46m" # BG CYAN
BW="\x1b[47m" # BG WHITE

#    +---------------------+  util  +----------------------+    #
#    |                                                     |    #
#    |  define utility functions.                          |    #
#    |                                                     |    #
#    +-----------------------------------------------------+    #

bold() {
  echo -e "$B$1$X"
}
italic() {
  echo -e "$I$1$X"
}
underline() {
  echo -e "$U$1$X"
}
strike() {
  echo -e "$F$1$X"
}
reverse() {
  echo -e "$R$1$X"
}
blink() {
  echo -e "$L$1$X"
}
dim() {
  echo -e "$D$1$X"
}
color() {
  echo -e "$2$1$X"
}
# 1: log
# 2: message
# 3: context
# 4: location
# 5: color
logs() {
  DIV="$FW$R$D$L $X"
  LOC=""
  CTX=""
  MSG=""
  LOG=""
  [[ -n "$1" ]] && LOG="$B$5$R $1 $X" || LOG=""
  [[ -n "$2" ]] && MSG="$FW$D$2$X" || MSG=""
  [[ -n "$3" ]] && CTX="$5$B$3$X" || CTX=""
  [[ -n "$4" ]] && LOC="$FL$B($4)$X" || LOC=""
  echo -e "$LOG $CTX $MSG $LOC"
}
LOC=""

# 1: context
# 2: message
# 3: location
# 󰙅 󰍔 󱡠 󰆼  󰘧󰷐
info() {
  logs "󰍡  INF" $2 $1 "" "$FB"
}
log() {
  logs "󰗚  LOG" $2 $1 "" $FW
}
dbg() {
  logs "󰯂  DBG" $2 $1 "" $FM
}
hint() {
  logs "  HNT" $2 $1 "" $FG
}
warn() {
  logs "  WRN" $2 $1 "" $FY
}
err() {
  logs "󰟢  ERR" $2 $1 "" $FR
}
lsp() {
  logs "󰘧  LSP" $2 $1 "" $FM
}
down() {
  logs "����������������������������������������  down" $2 $1 "" $FB
}
trace() {
  logs "󰆧  TRC" $2 $1 "" $FM
}

#    +---------------------+  cmds  +- --------------------+    #
#    |                                                     |    #
#    |  define command functions.                          |    #
#    |                                                     |    #
#    +-----------------------------------------------------+    #

function down-help() {
  echo -e "\x1b[1m\x1b[33m\x1b[7m 󰘧 down   \x1b[0m"
  echo -e "\x1b[1m\x1b[33m\x1b[7m \x1b[0m  v0.1.0-alpha.2\n"
  echo -e "\x1b[1m\x1b[32m\x1b[7m 󰯂 INFO   \x1b[0m                                     "
  echo -e "\x1b[1m\x1b[32m\x1b[7m \x1b[0m  down\x1b[0m is a dev-focused, familiar note-taking"
  echo -e "\x1b[1m\x1b[32m\x1b[7m \x1b[0m  environment for\x1b[32m 󰍔\x1b[0m\x1b[32m Markdown\x1b[0m, in development.\n"
  echo -e "\x1b[1m\x1b[36m\x1b[7m 󰒓 USAGE  \x1b[0m                                     "
  echo -e "\x1b[1m\x1b[36m\x1b[7m \x1b[0m  down [options]\x1b[0m <args> [file]\x1b[0m\n"
  echo -e "\x1b[1m\x1b[34m\x1b[7m 󰆧 OPTS   \x1b[0m                                     "
  echo -e "\x1b[1m\x1b[34m\x1b[7m \x1b[0m  -h\x1b[0m, --help\x1b[0m         Show help and exit"
  echo -e "\x1b[1m\x1b[34m\x1b[7m \x1b[0m  -v\x1b[0m, --version\x1b[0m      Show version and exit      "
  echo -e "\x1b[1m\x1b[34m\x1b[7m \x1b[0m  -d\x1b[0m, --debug  \x1b[0m      Run in debug mode        "
  echo -e "\x1b[1m\x1b[34m\x1b[7m \x1b[0m  -c\x1b[0m, --config\x1b[0m       Specify a config file\n"
  echo -e "\x1b[1m\x1b[35m\x1b[7m 󰷐 CMDS   \x1b[0m                                     "
  echo -e "\x1b[1m\x1b[35m\x1b[7m \x1b[0m  serve  | s         Run the server              "
  echo -e "\x1b[1m\x1b[35m\x1b[7m \x1b[0m  update | u         Update the server           "
  echo -e "\x1b[1m\x1b[35m\x1b[7m \x1b[0m  config | c         Configure the server        "
  echo -e "\x1b[1m\x1b[35m\x1b[7m \x1b[0m  help   | h         Show this help              \n"
  echo -e "\x1b[1m\x1b[31m\x1b[7m  ARGS   \x1b[0m                                     "
  echo -e "\x1b[1m\x1b[31m\x1b[7m \x1b[0m  [file]             The file to open            \n"
}
function show-help() {
  echo -e "                                                 "
  echo -e " $B$FY$R$D$L 󰘧 down-lsp $X v0.1.0-alpha.2 $X           "
  echo -e "                                                 "
  echo -e " $B$FG$R$D$L 󰯂 ABOUT $X                                     "
  echo -e "   down-lsp$X is a dev-focused note-taking         "
  echo -e "   environment for$FG 󰍔$X$FG Markdown$X, in development.     "
  echo -e "                                                 "
  echo -e " $B$FC$R$D$L 󰒓 USAGE $X                                     "
  echo -e "    down-lsp$X [options]$X <args> [file]$X          "
  echo -e "                                                 "
  echo -e " $B$FB$R$D$L 󰆧 FLAGS $X                                     "
  echo -e "   -h$X, $D--help$X         Show help and exit         "
  echo -e "   -v$X, $D--version$X      Show version and exit      "
  echo -e "   -i$X, $D--interactive$X  Run in interactive mode    "
  echo -e "   -e$X, $D--execute$X      Run in execute mode        "
  echo -e "   -c$X, $D--config$X       Specify a config file      "
  echo -e "                                                 "
  echo -e " $B$FM$R$D$L 󰷐 COMMAND $X                                     "
  echo -e "   serve  | s        Run the server              "
  echo -e "   update | u        Update the server           "
  echo -e "   config | c        Configure the server        "
  echo -e "   help   | h        Show this help              "
  echo -e "                                                 "
  echo -e " $B$FR$R$D$L  ARG $X                                     "
  echo -e "   [file]            The file to open            "
  echo -e "                                                 "
}
function show-version() {
  down "version" "0.0.1-alpha.1"
}
function shell() {
  lsp "shell" "sh"
}

function update() {
  down "update" "..."
}

#    +---------------------+  main  +----------------------+    #
#    |                                                     |    #
#    |  define and call main function.                     |    #
#    |                                                     |    #
#    +-----------------------------------------------------+    #

function main() {
  # if no subcommand, serve

  [[ $# -eq 0 ]] && lsp-serve

  case "$1" in
  --markdown | -M | --md) DOWN_LSP_MARKDOWN=true ;;
  --down | -D | --dn | --dwn) DOWN_LSP_DOWN=true ;;
  --stdin | -i) DOWN_LSP_STDIN=true ;;
  --config | -c) DOWN_LSP_CONFIG=$2 ;;
  --stdio | -s) DOWN_LSP_STDIO=true ;;
  --debug | -d) DOWN_LSP_DEBUG=true ;;
  --port | -p) DOWN_LSP_PORT=$2 ;;
  --host | -H) DOWN_LSP_HOST=$2 ;;
  --console | -C) DOWN_LSP_CONSOLE=1 ;;
  --style | -S) DOWN_LSP_STYLE=1 ;;

  serve | s | run | r) lsp-serve ;;
  shell | sh) shell ;;
  halp | --halp) show-help ;;
  help | h | -h | --help) down-help ;;
  test | t) lsp-test ;;
  format | f) lsp-format ;;
  version | v | --version | -v) show-version ;;
  update | up | u) update ;;
  esac
}

main "$@"

#    +------------------+  down-lsp  +---------------------+    #
#    |                                                     |    #
#    |  down-lsp v0.1.0-alpha.2                            |    #
#    |                                                     |    #
#    |  Chris Pecunies <clp@clp.is>                        |    #
#    |                                                     |    #
#    +-----------------------------------------------------+    #

#vim:ft=bash,ts=2,sw=2,sts=2,et
