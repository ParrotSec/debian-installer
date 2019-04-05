#!/bin/sh
if which xsltproc >/dev/null ; then
	xsltproc emails.xsl languages.xml
else
	xsltproc not found
fi
