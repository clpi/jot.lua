
set display=lastline directory='' noswapfile

let $jot = getcwd()
let $help = getcwd() .. '/help'
let $deps = getcwd() .. '/deps'

set rtp^=$jot,$help
set packpath=$deps

packloadall




