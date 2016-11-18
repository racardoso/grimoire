#!/bin/bash

#
# Just a script to clean HHVM source folder.
# make clean doesn't do a good job cleaning HHVM folder and left lots of
# 'dirty' object and binary files which can give us build error (especially
# with hack.
#

display_success() {
  echo -e "\n"
  echo "Success: There's nothing like a clean house ┬─┬ノ( ◕◡◕ ノ)"
  echo -e "\n"
}

display_error() {
  echo -e "\n"
  echo "Error: $1 ┻━┻ ヘ╰( •̀ε•́ ╰)"
}

display_usage() {
    echo -e "\nUsage:\n$0 hhvm source path\n"
}

if [ $# -ne 1 ]; then
   display_error "You must pass hhvm path as argument"
   display_usage
   exit 1
fi

if [[ $1 == "--help" ||  $1 == "-h" ]]; then
   display_usage
   exit 0
fi

HHVM_HOME=$1
if [ ! -d "$HHVM_HOME" ]; then
  display_error "Path not found. Make sure you pass a valid hhvm source path"
  exit 1
# Check if in a valid source path
elif [ ! -d "$HHVM_HOME/hphp" ]; then
  display_error "Can't find hphp folder. Invalid path?"
  exit 1
fi

# Cleanup binaries
rm -rf $HHVM_HOME/hphp/hhvm/hhvm
rm -rf $HHVM_HOME/hphp/hhvm/verify.hhbc
# Clean hack
rm -rf $HHVM_HOME/hphp/hack/src/_build/
rm -rf $HHVM_HOME/hphp/hack/bin/h*

# Clean all cmake generated files
find . -name CMakeFiles -type d -exec rm -rf {} +
find . -name cmake_install.cmake -delete
find . -name CMakeCache.txt -delete
find . -name *.a -delete

display_success

