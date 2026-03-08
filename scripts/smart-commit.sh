#!/usr/bin/env bash
# Detect project type and run the appropriate commit tool

has_npm_script() {
  [[ -f "package.json" ]] && grep -q '"commit"' package.json
}

if has_npm_script; then
  if [[ -f "pnpm-lock.yaml" ]]; then
    pnpm commit
  elif [[ -f "bun.lock" || -f "bun.lockb" ]]; then
    bun commit
  elif [[ -f "yarn.lock" ]]; then
    yarn commit
  else
    npm run commit
  fi
else
  git cz c
fi
