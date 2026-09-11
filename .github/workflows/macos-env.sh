#!/bin/sh

# References
# 1. https://github.com/actions/runner-images


echo "===== Architecture ====="
uname -a

echo "===== PATH ====="
echo "$PATH"

echo
echo "===== CC ====="
if [ -n "$CC" ]; then
    echo "$CC"
    command -v "$CC"
    "$CC" --version
else
    echo 'Environment variable CC is not set.'
fi

echo
echo "===== CXX ====="
if [ -n "$CXX" ]; then
    echo "$CXX"
    command -v "$CXX"
    "$CXX" --version
else
    echo 'Environment variable CXX is not set.'
fi

tools="cmake ninja clang-format clang-tidy"
for tool in $tools; do
    echo
    echo "===== $tool ====="
    if command -v "$tool"; then
        "$tool" --version
    else
        echo "$tool not found."
    fi
done
