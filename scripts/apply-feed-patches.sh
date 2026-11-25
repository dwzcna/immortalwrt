#!/bin/sh
# Apply local patches/feeds/<feed>/*.patch to the checked-out feed trees.
# Run after ./scripts/feeds update. Idempotent: already-applied patches are skipped.
set -e
cd "$(dirname "$0")/.."
for feeddir in patches/feeds/*/; do
	feed="${feeddir#patches/feeds/}"
	feed="${feed%/}"
	[ -d "feeds/$feed" ] || { echo "skip $feed: not checked out"; continue; }
	for p in "$feeddir"*.patch; do
		[ -e "$p" ] || continue
		if git -C "feeds/$feed" apply --check "$(pwd)/$p" 2>/dev/null; then
			git -C "feeds/$feed" apply "$(pwd)/$p" && echo "applied $p"
		elif git -C "feeds/$feed" apply --reverse --check "$(pwd)/$p" 2>/dev/null; then
			echo "already applied $p"
		else
			echo "FAILED $p" >&2
			exit 1
		fi
	done
done
