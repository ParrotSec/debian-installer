#!/bin/sh

xsltproc=`which xsltproc`
stylesheet=/usr/share/sgml/docbook/stylesheet/xsl/nwalsh/html/chunk.xsl

if [ -n "$xsltproc" ] ; then
    if [ -e "$stylesheet" ]; then
	$xsltproc --xinclude style-html.xsl partman-doc.dbk
    else
	echo "stylesheet missing; please install the docbook-xsl Debian package"
	exit 1
    fi
else
    echo "xsltproc not found; please install the xsltproc Debian package"
    exit 1
fi
