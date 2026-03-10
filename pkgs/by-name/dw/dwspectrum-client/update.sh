#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <deb-url> [--build]"
  exit 1
fi

url="$1"
run_build="false"
if [[ "${2:-}" == "--build" ]]; then
  run_build="true"
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"
pkg_file="$script_dir/package.nix"
repo_root="$(git -C "$script_dir" rev-parse --show-toplevel 2>/dev/null || cd "$script_dir/../../../../.." && pwd)"

if [[ ! -f "$pkg_file" ]]; then
  echo "Could not find package file: $pkg_file"
  exit 1
fi

version="$(printf '%s' "$url" | sed -nE 's#.*dwspectrum-client-([0-9][0-9A-Za-z.\-]*)-linux_x64\.deb$#\1#p')"
if [[ -z "$version" ]]; then
  echo "Could not parse version from URL"
  exit 1
fi

hash_json="$(nix store prefetch-file "$url" --json)"
hash="$(printf '%s' "$hash_json" | tr -d '\n' | sed -nE 's#.*"hash"[[:space:]]*:[[:space:]]*"([^"]+)".*#\1#p')"
if [[ -z "$hash" ]]; then
  echo "Could not parse hash from nix prefetch output"
  exit 1
fi

escape_sed_repl() {
  printf '%s' "$1" | sed -e 's/[&|]/\\&/g'
}

version_escaped="$(escape_sed_repl "$version")"
url_escaped="$(escape_sed_repl "$url")"
hash_escaped="$(escape_sed_repl "$hash")"

sed -E -i "0,/version = \"[^\"]+\";/s|version = \"[^\"]+\";|version = \"$version_escaped\";|" "$pkg_file"
sed -E -i "0,/url = \"[^\"]+\";/s|url = \"[^\"]+\";|url = \"$url_escaped\";|" "$pkg_file"
sed -E -i "0,/hash = \"[^\"]+\";/s|hash = \"[^\"]+\";|hash = \"$hash_escaped\";|" "$pkg_file"

grep -q "version = \"$version\";" "$pkg_file" || { echo "Failed to update version"; exit 1; }
grep -q "url = \"$url\";" "$pkg_file" || { echo "Failed to update URL"; exit 1; }
grep -q "hash = \"$hash\";" "$pkg_file" || { echo "Failed to update hash"; exit 1; }

echo "Updated $pkg_file"
echo "version: $version"
echo "hash:    $hash"

if [[ "$run_build" == "true" ]]; then
  (cd "$repo_root" && nix build path:.#dwspectrum-client --impure)
  echo "Build completed: $repo_root/result"
fi
