#!/bin/sh

set -e

[ -r ./po_functions ] || exit 1
. ./po_functions

if [ -z "$languages" ]; then
    # Buildlist of languages to be included on the official website
    languages="en"
fi

if [ -z "$destination" ]; then
    destination="/tmp/manual"
fi

if [ -z "$formats" ]; then
    formats="html pdf txt"
fi

[ -e "$destination" ] || mkdir -p "$destination"

export official_build="1"
export web_build="1"

# We need to merge the XML files for English and update the POT files
export PO_USEBUILD="1"
update_templates

for lang in $languages; do
    echo "Language: $lang";

    # Update PO files and create XML files
    check_po
    if [ -n "$USES_PO" ] ; then
        generate_xml
    fi
    
        ./buildone.sh "$lang" "$formats"
        mkdir -p "$destination/$destsuffix"
        for format in $formats; do
            if [ "$format" = html ]; then
                mv ./build.out/html/* "$destination/$destsuffix"
            else
                # Do not fail because of missing PDF support for some languages
                mv ./build.out/install.$lang.$format "$destination/$destsuffix/install.$format.$lang" || true
            fi
        done

        ./clear.sh

    # Delete generated XML files
    [ -n "$USES_PO" ] && rm -r ../$lang || true
done

PRESEED="../en/appendix/example-preseed.xml"
if [ -f $PRESEED ] && [ -f preseed.awk ] ; then
    gawk -f preseed.awk $PRESEED >$destination/example-preseed.txt
fi

clear_po
