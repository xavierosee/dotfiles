#!/usr/bin/env bash
# Sourced by shells / systemd to expose the Tensorix API key.
# Reads from `pass`. Never writes the secret to disk.
# Exit silently if pass or the entry is unavailable; callers can detect.

set -u

if ! command -v pass >/dev/null 2>&1; then
  echo "tensorix-env: pass not installed" >&2
  return 1 2>/dev/null || exit 1
fi

if ! _tensorix_key="$(pass show api/tensorix 2>/dev/null)"; then
  echo "tensorix-env: 'api/tensorix' not found in password store" >&2
  return 1 2>/dev/null || exit 1
fi

export TENSORIX_API_KEY="$_tensorix_key"
unset _tensorix_key
