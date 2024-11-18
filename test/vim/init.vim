
set display=lastline directory='' noswapfile

let $word = getcwd()
let $help = getcwd() .. '/help'
let $deps = getcwd() .. '/deps'

set rtp^=$word,$help
set packpath=$deps

packloadall




