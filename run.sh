#!/usr/bin/env bash

set -eu

workingdir="$PWD"
soext="so"
config_file="languages_config.txt"

export workingdir soext

# Function to attempt checkout and fetch commit if necessary
attempt_checkout() {
    local dir=$1
    local ref=$2
    log "Attempting to checkout $ref..."
    if ! (cd "$dir" && git checkout "$ref" --quiet 2>/dev/null); then
        log "$ref not found in shallow clone, fetching branch..."
        # Fetch the branch explicitly and then attempt to checkout using FETCH_HEAD
        if ! (cd "$dir" && git fetch origin "$ref" && git checkout FETCH_HEAD --quiet); then
            log "Failed to fetch or checkout $ref. The reference may not exist or is not accessible."
            return 1
        else
            log "Successfully fetched and checked out $ref."
        fi
    else
        log "Successfully checked out $ref."
    fi
    return 0
}

process_language() {
    local lang=$1
    local url=$2
    local branch=$3
    local sourcedir=$4

    printf "\nProcessing $lang from $url\n"
    clone_dir="${workingdir}/${lang}_grammar"

    log() {
        echo "$1"
    }

    # Check and clean up the existing directory
    if [ -d "$clone_dir" ]; then
        log "Cleaning up existing directory for $lang..."
        rm -rf "$clone_dir"
    fi

    log "Cloning $lang grammar..."
    git clone --depth 1 "$url" "$clone_dir" --quiet
    if [ $? -ne 0 ]; then
        log "Failed to clone $lang, skipping build..."
        return
    fi

    # Check out the specified branch or commit hash if provided
    if [ -n "$branch" ]; then
        if ! attempt_checkout "$clone_dir" "$branch"; then
            log "Failed to checkout $branch for $lang, skipping build..."
            return
        fi
    fi

    # Navigate to the source directory if specified
    if [ -n "$sourcedir" ]; then
        cd "$clone_dir/$sourcedir"
    elif [ -n "$sourcedir/src" ]; then
        cd "$clone_dir/src"
    else
        cd "$clone_dir"
    fi

    # Ensure parser.c exists before attempting to compile
    if ! test -f parser.c; then
        log "parser.c not found, skipping build..."
        return
    fi

    log "Building..."
    cc -fPIC -c -I. parser.c
    # Compile scanner.c if it exists
    if test -f scanner.c; then
        cc -fPIC -c -I. scanner.c
    fi
    # Compile scanner.cc if it exists
    if test -f scanner.cc; then
        c++ -fPIC -I. -c scanner.cc
    fi
    # Link if object files were created
    if compgen -G "*.o" >/dev/null; then
        if test -f scanner.cc; then
            c++ -fPIC -shared *.o -o "libtree-sitter-${lang}.${soext}"
        else
            cc -fPIC -shared *.o -o "libtree-sitter-${lang}.${soext}"
        fi
        # Copy the built library
        mkdir -p "${workingdir}/dist"
        cp "libtree-sitter-${lang}.${soext}" "${workingdir}/dist"
    else
        log "Compilation failed, no object files to link..."
        return
    fi

    # Cleanup
    cd "${workingdir}"
    rm -rf "$clone_dir"

    log "Build complete."
}

export -f process_language
export -f attempt_checkout

# Use GNU parallel to read each line from the config and process it in parallel
parallel --colsep ',' process_language ::: $(cat "$config_file")
