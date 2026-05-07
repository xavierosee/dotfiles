#!/usr/bin/env bash
# Emits TENSORIX_API_KEY=value on stdout for systemd EnvironmentFile=
# usage in a unit's ExecStartPre or via a generated drop-in.
# This script is safe to commit; the secret is fetched at runtime from `pass`.
set -eu
key="$(pass show api/tensorix)"
printf 'TENSORIX_API_KEY=%s\n' "$key"
