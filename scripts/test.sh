#!/usr/bin/env bash

set -euo pipefall

declare -r module="word"
declare -r packdir="./tests/site/pack/deps/start"
declare test_scope="${module}"
declare test_logs=""

while [[ $# -gt 0 ]]; do

  case "${1}" in
  --clean | -c)
    shift
    echo "[test] cleaning up env..."
    rm -rf "${packdir}"
    echo "[test] done."
    ;;
  *)
    if [[ "${test_scope}" == "${module}" ]] && [[ "${1}" == "${module}/"* ]]; then
      test_scope="${1}"
    fi
    shift
    ;;
  esac
done

function setup_env() {
  echo
  echo "[test] setting up env..."
  echo
  if [[ ! -d "${packdir}" ]]; then
    mkdir -p "${packdir}"
  fi
  if [[ ! -d "${packdir}/plenary.nvim" ]]; then
    echo "[plug] installing plenary.nvim..."
    git clone https://github.com/nvim-lua/plenary.nvim "${packdir}/plenary.nvim"
    local -r plenary_353_patch="$(pwd)/scripts/plenary_353.patch"
    git -C "${packdir}/plenary.nvim" apply "${plenary_353_patch}"
    echo "[plug] done"
    echo
  fi
  echo "[test] env ready"
  echo
}

luacov_init() {
  luacov_dir="$(dirname "$(luarocks which luacov 2>/dev/null | head -1)")"
  if [[ "${luacov_dir}" == "." ]]; then
    luacov_dir=""
  fi

  if test -n "${luacov_dir}"; then
    rm -f luacov.*.out
    export LUA_PATH=";;${luacov_dir}/?.lua"
  fi
}
luacov_end() {
  if test -n "${luacov_dir}"; then
    if test -f "luacov.stats.out"; then
      luacov

      echo
      tail -n +$(($(grep -n "^Summary$" luacov.report.out | cut -d":" -f1) - 1)) luacov.report.out
    fi
  fi
}

setup_env

luacov_init

if [[ -d "./tests/${test_scope}/" ]]; then
  test_logs=$(nvim --headless --noplugin -u tests/init.lua -c "lua require('plenary.test_harness').test_directory('./tests/${test_scope}/', { minimal_init = 'tests/init.lua', sequential = true })")
elif [[ -f "./tests/${test_scope}_spec.lua" ]]; then
  test_logs=$(nvim --headless --noplugin -u tests/init.lua -c "lua require('plenary.busted').run('./tests/${test_scope}_spec.lua')")
fi

echo "${test_logs}"

luacov_end
