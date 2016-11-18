#!/bin/bash

display_usage() {
    echo -e "Usage:\n$0 -d 'string' or
    $0 -e 'string'.\n Options:
    -e, --encode\t Encode a instruction string to 32 bits hex instruction.
    -d, --decode\t Decode a 32 bits hex and print instruction.\n
    Examples:
    $0 -d 'lmw 3,128(1)'
    lmw     r3,128(r1) =>  80 00 61 b8

    $0 -e '8000 61b8'
    80 00 61 b8  =>  lmw     r3,128(r1)
    ";
}

check_install() {
  command -v $1 >/dev/null 2>&1 || {
    tput setaf 1
    echo >&2 "$1 is not installed. Please install $1 and try again";
    tput sgr0
    exit 1
  }
}

if [ $# -ne 2 ]; then
   display_usage
   exit 1
fi

if [[ $1 == "--help" ||  $1 == "-h" ]]; then
   display_usage
   exit 0
fi

# check if xxd and as is installed
# xxd is needed to hex dump obj code and as to asm code
check_install 'xxd'
check_install 'as'

# encode instruction
if [[ $1 == "--encode" ||  $1 == "-e" ]]; then

# TODO: parse result so we can ride spaces of result. 80 00 61 b8
  echo $2 | as -mvsx -mpower8 -o tmp 2>&1 || {
      tput setaf 1
    echo >&2 "Error: as returns an error for instruction $2.
Are you sure you pass a valid instruction?";
    tput sgr0
    exit 1;
   } &&
  tput setaf 2
  objdump -d --insn-width=10 tmp | fgrep : |
  awk -F '\t' 'BEGIN {} END {gsub(" "," ",$2); print $3,"=> ",$2} '
  tput sgr0
  exit 0
fi

# decode instruction
if [[ $1 == "--decode" ||  $1 == "-d" ]]; then

# TODO: get $1 and parse to allow pass a value without space separator
# echo "8000 61b8" | sed -e 's/.\{4\}/&'

# lhau 14,-21026(30) will generate a nice 0xdeaddead hex
cat > /tmp/gen.S <<EOF
   .text
        .global _start
   _start:
        lhau 14,-21026(30)
EOF
  as -mvsx -mpower8 /tmp/gen.S -o /tmp/gen.o
  # dump hex and hack
  xxd /tmp/gen.o /tmp/gen.dump
  sed -i "s/dead dead/$2/" /tmp/gen.dump
  # now revert to a obj code
  xxd -r /tmp/gen.dump /tmp/gen-hack.o

  #check if valid
  objdump -d /tmp/gen-hack.o >/dev/null 2>&1 || {
    tput setaf 1
    echo >&2 "Error: objdump returns an error for instruction $2.
Are you sure you pass a valid instruction?";
    rm -rf /tmp/gen.o /tmp/gen.S /tmp/gen.dump /tmp/gen-hack.o
    tput sgr0
    exit 1;
  }

  tput setaf 2
  # print instruction
  objdump -d /tmp/gen-hack.o | fgrep : |
  awk -F '\t' 'BEGIN {} END {gsub(" "," ",$2); print $2,"=> ",$3} '
  rm -rf /tmp/gen.o /tmp/gen.S /tmp/gen.dump /tmp/gen-hack.o
  tput sgr0 #normal output
  exit 0;
fi
