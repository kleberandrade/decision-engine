#!/usr/bin/env bash
# Local headless rendering with pipes/files only; no server or VM service.
set -euo pipefail
[[ $# -eq 1 || ( $# -eq 2 && "$2" == --test-fonts ) ]] || { printf '%s\n' 'Usage: render_smoke.sh /path/to/flutter-sdk [--test-fonts]' >&2; exit 1; }
lab_flutter_sdk=$1
lab_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
case "$(uname -s)" in
  Darwin) lab_engine=darwin-$(uname -m); [[ $(uname -m) == x86_64 ]] && lab_engine=darwin-x64
    [[ -x "$lab_flutter_sdk/bin/cache/artifacts/engine/$lab_engine/flutter_tester" ]] || lab_engine=darwin-x64 ;;
  Linux) lab_engine=linux-x64 ;;
  *) printf '%s\n' 'Native renderer requires macOS or Linux.' >&2; exit 1 ;;
esac
lab_tester="$lab_flutter_sdk/bin/cache/artifacts/engine/$lab_engine/flutter_tester"
[[ -x "$lab_tester" ]] || { printf '%s\n' 'Flutter tester binary missing.' >&2; exit 1; }
[[ -d "$lab_root/build/web/assets" ]] || { printf '%s\n' 'Run flutter build web first.' >&2; exit 1; }
lab_smoke_tmp=$(mktemp -d "${TMPDIR:-/tmp}/decision-lab-smoke.XXXXXX")
trap 'rm -rf "$lab_smoke_tmp"' EXIT
cd "$lab_root"
if ! "$lab_flutter_sdk/bin/cache/dart-sdk/bin/dartaotruntime" \
  "$lab_flutter_sdk/bin/cache/dart-sdk/bin/snapshots/frontend_server_aot.dart.snapshot" \
  --sdk-root "$lab_flutter_sdk/bin/cache/artifacts/engine/common/flutter_patched_sdk/" \
  --target=flutter --enable-asserts --packages .dart_tool/package_config.json \
  --output-dill "$lab_smoke_tmp/preview.dill" tool/render_smoke.dart >"$lab_smoke_tmp/compile.log" 2>&1; then
  tail -30 "$lab_smoke_tmp/compile.log"
  exit 1
fi
lab_tester_args=(--run-forever --disable-vm-service --enable-software-rendering
  --flutter-assets-dir="$lab_root/build/web/assets" "$lab_smoke_tmp/preview.dill")
if [[ ${2:-} == --test-fonts ]]; then
  lab_tester_args=(--use-test-fonts "${lab_tester_args[@]}")
fi
"$lab_tester" "${lab_tester_args[@]}"
