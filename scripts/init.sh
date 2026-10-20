#!/usr/bin/env bash

# Install git hooks with lefthook
lefthook install

# Offer to set Pixi's pinning strategy, so that `pixi add` adds lower bounds only
if ! pixi config list pinning-strategy --json | grep -q '"latest-up"'; then
  PIN_CMD="pixi config set pinning-strategy latest-up --global"
  if [[ -t 0 ]]; then
    read -r -p "Set Pixi's pinning strategy to \"latest-up\" for all your projects? [Y/n] " answer
  else
    answer=n
  fi
  if [[ "${answer:-y}" =~ ^[Yy] ]]; then
    $PIN_CMD
  else
    echo "To set Pixi's pinning strategy later, run: $PIN_CMD"
  fi
  echo
fi

echo "Setup complete."
