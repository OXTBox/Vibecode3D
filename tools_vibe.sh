#!/usr/bin/env bash
# tools_vibe.sh - talk to the VibeCode3D standalone (LIB_MCP on port 8769), starting it if needed.
#   ./tools_vibe.sh ping | run '<statements>' | eval '<expr>' | snap [C:/path.png]
HERE="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
LCMCP="$HERE/../LIB_MCP/tools/lcmcp"
TOKEN=/mnt/c/LIB_MCP/devtoken_8769.txt
EXE="$HERE/standalone/VibeCode3D/Windows x86-64/VibeCode3D.exe"
alive() { [[ -f "$TOKEN" ]] && "$LCMCP" --port 8769 ping >/dev/null 2>&1; }
if ! alive; then
  rm -f "$TOKEN"
  [[ -f "$EXE" ]] || { echo "no build at $EXE" >&2; exit 2; }
  taskkill.exe /IM VibeCode3D.exe /F >/dev/null 2>&1
  (cd /mnt/c && cmd.exe /c start "" "$(wslpath -w "$EXE")" >/dev/null 2>&1)
  for _ in $(seq 60); do [[ -f "$TOKEN" ]] && break; sleep 0.5; done
fi
exec "$LCMCP" --port 8769 "$@"
