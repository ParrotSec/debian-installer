ALL = kernel-policy.html

all: $(ALL)

clean:
	-rm $(ALL)

%.html:	%.xml
	xsltproc --nonet -o $@ /usr/share/sgml/docbook/stylesheet/xsl/nwalsh/xhtml/profile-docbook.xsl $<
