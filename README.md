# Grimoire
 
Just a repository for my spel..err convinience scripts.

## HHVM cleaner

**hhvm-cleaner.sh**

cmake/make do a pretty lousy job when clean HHVM sometimes it give us build 
errors especially with Hack. So this script make a nice clean on HHVM before 
build again.

`hhvm-cleaner.sh <hhvm root path>`

## PPC64 Encoder/Decoder script

**ppc64-instr-info.sh**

A script to encode ou decode a PPC64 instruction. You can 
pass a instruction mnemonic and the script will encode and print the instruction image or pass a instruction image and it will decode the instruction printing the instruction mnemonic.

```
ppc64-instr-info.sh -e '<mnemonic>'

ppc64-instr-info.sh -d '<innstruction image>'


<mnemonic> : lmw 3,128(1)
<instruction image> : 8000 61b8

- You have to pass arguments between single quotes.
- Instruction image must be passed in xxxx xxxx format with a space between byte 16 (it will be fixed someday).
- You can't use 'r' as register prefix.

```

