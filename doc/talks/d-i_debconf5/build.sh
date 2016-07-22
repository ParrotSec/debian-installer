#!/bin/sh

xsltproc=`which xsltproc`
lynx=`which lynx`
sgmltools=`which sgmltools`
w3m=`which w3m`
stylesheet=/usr/share/sgml/docbook/stylesheet/xsl/nwalsh/html/chunk.xsl

if [ -n "$xsltproc" ] ; then
    if [ -e "$stylesheet" ]; then
	$xsltproc style-html.xsl d-i_debconf5.xml
    else
	echo stylesheet missing. Please install the docbook-xsl Debian package
	exit 1
    fi
else
    echo xsltproc not found. Please install the xsltproc Debian package
    exit 1
fi

if [ -f index.html ] ; then
 # The mv thing breaks internal links
 # mv index.html d-i_debconf5.html
 if [ -n "$sgmltools" -a -n "$w3m" ] ; then
    # To be checked
    $sgmltools --backend=txt d-i_debconf5.html >d-i_debconf5.txt
 else
    if [ -n "$lynx" ] ; then
	$lynx -dump -nolist d-i_debconf5.html >d-i_debconf5.txt
    else
	echo sgmltools, w3m or lynx not found. 
        echo You need installing either sgmltools+w3m or lynx for
        echo being able to convert the HTML documentation to text
	exit 1
    fi
 fi
fi



