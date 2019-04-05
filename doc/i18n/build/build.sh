#!/bin/sh

set -e

[ -r ./po_functions ] || exit 1
. ./po_functions

if [ -z "$languages" ]; then
    # Please add languages only if they build properly.
    # languages="en cs es fr ja nl pt_BR" # ca da de el eu it ru

    # Buildlist of languages to be included on RC3 CD's
    languages="en"
fi

if [ -z "$destination" ]; then
    destination="/tmp/manual"
fi

if [ -z "$formats" ]; then
    #formats="html pdf ps txt"
    formats="html txt"
fi

[ -e "$destination" ] || mkdir -p "$destination"

if [ "$official_build" ]; then
    # Propagate this to children.
    export official_build
fi

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
    
    destsuffix="$lang"
    ./buildone.sh "$lang" "$formats"
    mkdir -p "$destination/$destsuffix"
    for format in $formats; do
       if [ "$format" = html ]; then
           mv ./build.out/html/* "$destination/$destsuffix"
       else
           # Do not fail because of missing PDF support for some languages
           mv ./build.out/i18n.$lang.$format "$destination/$destsuffix" || true
       fi

        # ./clear.sh
    done

    # Delete generated XML files
    [ -n "$USES_PO" ] && rm -r ../$lang || true
done

clear_po
