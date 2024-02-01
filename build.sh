#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_filename.go>"
    exit 1
fi

input_file="$1"

declare -A platforms

platforms=(
    ["aix"]="ppc64"
    ["android"]="386 amd64 arm arm64"
    ["darwin"]="amd64 arm64"
    ["dragonfly"]="amd64"
    ["freebsd"]="386 amd64 arm arm64"
    ["illumos"]="amd64"
    ["ios"]="amd64 arm64"
    ["js"]="wasm"
    ["linux"]="386 amd64 arm arm64 mips mips64 mips64le mipsle ppc64 ppc64le riscv64 s390x"
    ["netbsd"]="386 amd64 arm arm64"
    ["openbsd"]="386 amd64 arm arm64 mips64"
    ["plan9"]="386 amd64 arm"
    ["solaris"]="amd64"
    ["windows"]="386 amd64 arm arm64"
)

output_dir="builds"
mkdir -p "$output_dir"

compile_platform() {
    goos="$1"
    goarch="$2"
    output_name="$output_dir/$(basename "$input_file" .go)-$goos-$goarch"
    echo "Compiling for $goos/$goarch: $input_file"
    env GOOS="$goos" GOARCH="$goarch" go build -o "$output_name" "$input_file"
}

for goos in "${!platforms[@]}"; do
    for goarch in ${platforms["$goos"]}; do
        compile_platform "$goos" "$goarch" &
    done
done

wait

echo "Cross-compilation complete. Output files are in the '$output_dir' directory."