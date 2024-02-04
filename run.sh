#!/usr/bin/env bash

set -eu

workingdir="$PWD"
soext="so"
config_file="languages_config.txt"

export workingdir soext

process_language() {
    local lang=$1
    local url=$2
    local branch=$3
    local sourcedir=$4

    printf "\nProcessing $lang from $url\n"
    clone_dir="${workingdir}/${lang}_grammar"

    # Check and clean up the existing directory
    if [ -d "$clone_dir" ]; then
        echo "Cleaning up existing directory for $lang..."
        rm -rf "$clone_dir"
    fi

    echo "Cloning $lang grammar..."
    if [ -z "$branch" ]; then
        git clone --depth 1 "$url" "$clone_dir" --quiet
    else
        git clone --single-branch --branch "$branch" "$url" "$clone_dir" --quiet
    fi

    if [ $? -ne 0 ]; then
        echo "Failed to clone $lang, skipping build..."
        return
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
        echo "parser.c not found for $lang, skipping build..."
        return
    fi

    echo "Building $lang..."
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
        echo "Compilation failed for $lang, no object files to link..."
        return
    fi

    # Cleanup
    cd "${workingdir}"
    rm -rf "$clone_dir"

    echo "$lang build complete."
}

export -f process_language

# Use GNU parallel to read each line from the config and process it in parallel
parallel --colsep ',' process_language ::: $(cat "$config_file")
