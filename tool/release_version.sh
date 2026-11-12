#!/usr/bin/env bash
# Release versions live in git tags on origin, one counter per store listing,
# so every release is exactly one step after the last one on its own track:
#
#   android       v1.0.59+53             GitHub APK + Play (CI creates the tag)
#   ios           ios-v1.0.61+55         App Store, org.nanosolve.hive
#
# pubspec.yaml's version is not a release version; release builds pass
# --build-name/--build-number from here.
#
#   tool/release_version.sh next <track>              last + 1 patch, + 1 build
#   tool/release_version.sh current <track>           the last released version
#   tool/release_version.sh record <track> <version>  tag HEAD and push the tag
set -euo pipefail

die() { echo "release_version: $*" >&2; exit 1; }

prefix_for() {
  case "$1" in
    android) echo "v" ;;
    ios) echo "ios-v" ;;
    *) die "unknown track '$1' (android | ios)" ;;
  esac
}

is_version() { [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$ ]]; }

# Highest build number wins: build numbers only ever grow on every track.
current() {
  local prefix version
  prefix=$(prefix_for "$1")
  version=$(git ls-remote --tags --refs origin "refs/tags/${prefix}*" \
    | sed -n "s#.*refs/tags/${prefix}##p" \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+$' \
    | sort -t+ -k2,2n | tail -1 || true)
  [ -n "$version" ] || die "no ${prefix}<x.y.z+n> tag on origin for track '$1'"
  echo "$version"
}

next() {
  local last name build major minor patch
  last=$(current "$1")
  name=${last%+*}
  build=${last#*+}
  IFS=. read -r major minor patch <<<"$name"
  echo "${major}.${minor}.$((patch + 1))+$((build + 1))"
}

record() {
  local track=$1 version=$2 expected tag
  is_version "$version" || die "'$version' is not x.y.z+n"
  expected=$(next "$track")
  [ "$version" = "$expected" ] || die "$track would jump: next is $expected, not $version"
  tag="$(prefix_for "$track")${version}"
  git tag -a "$tag" -m "$track $version" HEAD
  git push -q origin "refs/tags/$tag"
  echo "recorded $tag"
}

# Checked here because bash does not carry set -e into $(...).
[ $# -ge 2 ] && prefix_for "$2" >/dev/null

case "${1:-}" in
  current) [ $# -eq 2 ] || die "usage: current <track>"; current "$2" ;;
  next) [ $# -eq 2 ] || die "usage: next <track>"; next "$2" ;;
  record) [ $# -eq 3 ] || die "usage: record <track> <version>"; record "$2" "$3" ;;
  *) die "usage: $0 current|next <track> | record <track> <version>" ;;
esac
