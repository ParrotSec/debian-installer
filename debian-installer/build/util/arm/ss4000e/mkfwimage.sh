#!/bin/sh

INPUT=$1
OUTPUT=$2

if [ -z "$OUTPUT" ] || [ -z "$INPUT" ]; then
	echo "Usage: $0 <inputfile> <outputfile>" >&2
	exit 1
fi

printf 'FALCONSTOR@EP219\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\08\0\0\0\0\0\0\09.9-b999\0\0\0\0\0\0\0\0fs-bc\0\0\0\0\0\0\0\0\0\0\0' > $OUTPUT.tmp
cat $INPUT >> $OUTPUT.tmp
MD5=$(md5sum $OUTPUT.tmp | awk -F' ' '{print $1}')
(printf $MD5; cat $OUTPUT.tmp) > $OUTPUT
rm $OUTPUT.tmp
