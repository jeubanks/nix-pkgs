#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: discover-latest.sh [--include-rc] [--apply] [--build]

Options:
  --include-rc  Include rc/beta releases (default: release only)
  --apply       Run update.sh with discovered URL
  --build       When used with --apply, also build after update
EOF
}

include_rc="false"
apply_update="false"
run_build="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --include-rc) include_rc="true" ;;
    --apply) apply_update="true" ;;
    --build) run_build="true" ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

if [[ "$run_build" == "true" && "$apply_update" != "true" ]]; then
  echo "--build requires --apply"
  exit 1
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"
update_script="$script_dir/update.sh"

if [[ ! -x "$update_script" ]]; then
  echo "Missing executable updater script: $update_script"
  exit 1
fi

releases_url="https://updates.digital-watchdog.com/digitalwatchdog/releases.json"
json="$(curl -fsSL "$releases_url")"

mapfile -t versions < <(
  printf '%s' "$json" \
    | jq -r --arg include_rc "$include_rc" '
        .releases[]
        | select(.product == "vms")
        | select(($include_rc == "true") or (.publication_type == "release"))
        | .version
      ' \
    | sort -t. -k1,1nr -k2,2nr -k3,3nr -k4,4nr
)

if [[ ${#versions[@]} -eq 0 ]]; then
  echo "No candidate versions found in releases feed"
  exit 1
fi

mapfile -t package_bases < <(
  {
    echo "https://updates.digital-watchdog.com/digitalwatchdog"
    printf '%s' "$json" | jq -r '.packages_urls[]?'
  } | awk 'NF' | awk '!seen[$0]++'
)

found_url=""
found_version=""
found_base=""

for version in "${versions[@]}"; do
  build="${version##*.}"
  for base in "${package_bases[@]}"; do
    candidate="$base/$build/linux/dwspectrum-client-$version-linux_x64.deb"
    if curl -fsIL "$candidate" >/dev/null 2>&1; then
      found_url="$candidate"
      found_version="$version"
      found_base="$base"
      break 2
    fi
  done
done

if [[ -z "$found_url" ]]; then
  echo "Could not find a downloadable deb for candidate versions"
  exit 1
fi

echo "Found latest available package"
echo "version: $found_version"
echo "base:    $found_base"
echo "url:     $found_url"

if [[ "$apply_update" == "true" ]]; then
  if [[ "$run_build" == "true" ]]; then
    "$update_script" "$found_url" --build
  else
    "$update_script" "$found_url"
  fi
fi
