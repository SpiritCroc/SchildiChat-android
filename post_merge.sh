#!/bin/sh

set -e

mydir="$(dirname "$(realpath "$0")")"
source "$mydir/merge_helpers.sh"

# Require clean git state
require_clean_git

# Oposite of restore_upstream in post_merge.sh
restore_sc() {
    local f="$(basename "$1")"
    local path="$(dirname "$1")"
    local sc_f="tmp_sc_$f"
    local upstream_f="upstream_$f"
    if [ -e "$path/$f" ]; then
        mv "$path/$f" "$path/$upstream_f"
    fi
    if [ -e "$path/$sc_f" ]; then
        mv "$path/$sc_f" "$path/$f"
    fi
}

# Color corrections | TODO more?
sed -i 's|@color/riotx_accent|?colorAccent|g' vector/src/main/res/layout/*
uncommitted=`git status --porcelain`
if [ -z "$uncommitted" ]; then
    echo "Seems like colors are still fine :)"
else
    git add -A
    git commit -m 'Automatic color correction'
fi

# Keep in sync with pre_merge.sh!
restore_sc README.md
restore_sc fastlane
restore_sc .github

git add -A
git commit -m "Automatic upstream merge postprocessing"

revert_last 'Automatic revert to unchanged upstream strings, pt.1' || \
    read -p "Please resolve conflicts and commit, then press enter"

"$mydir"/correct_strings.sh


while grep -q "wolpertinger\|schlumpfwesen" "$mydir/vector/src/main/res/values-de/strings.xml"; do
    read -p "Please resolve remaining language, then press enter!"
done

uncommitted=`git status --porcelain`
if [ -z "$uncommitted" ]; then
    echo "Seems like no new language conflicts appeared :)"
else
    git add -A
    git commit -m 'Resolve required manual intervention in german strings'
fi
