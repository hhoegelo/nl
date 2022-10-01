#!/bin/bash

sourceDir=/root/src
binaryDir=/generated

cd "$sourceDir" || exit 6

# 1/5 - compile typescript via tsc
echo "1/5 - starting typescript compilation";
if ! tsc "$sourceDir"/lib/build.ts; then
    echo "1/5 - typescript compilation failed";
    exit 1
fi

# 2/5 - execute compiled javascript via node
echo "2/5 - starting node";
if ! node "$sourceDir"/lib/build.js /tmp/generated; then
    echo "2/5 - node failed";
    exit 2
fi

# 3/5 - compile generated headers
echo "3/5 - starting g++ build of tests";
mkdir -p /tmp/generated/build
if ! g++ /tmp/generated/src/main.cpp -o /tmp/generated/build/tests; then
    echo "3/5 - g++ failed";
    exit 3
fi

#make test-application executeable
chmod +x /tmp/generated/build/tests

# 4/5 - run generated test-application
echo "4/5 - starting tests";
if ! /tmp/generated/build/tests; then
    echo "4/5 - tests failed";
    exit 4
fi

echo "5/5 - copy generated headers into appropriate directories"
for file in c15_config.h parameter_declarations.h parameter_list.h parameter_descriptor.h placeholder.h parameter_group.h display_scaling_type.h; do
    if ! cp /tmp/generated/src/$file $binaryDir/; then
        echo "5/5 - copying of headers to build-dir failed";
        exit 5
    fi
done
