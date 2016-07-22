TEX    = latex
DVIPS  = dvips
PDFTEX = pdflatex

.PHONY: clean
.SILENT: all dvi clean


SOURCES = $(shell ls | grep -e '\.tex')
SOURCE  = d-i_debconf5

all: pdf

pdf: $(SOURCES:.tex=.pdf)

dvi: $(SOURCES:.tex=.dvi) 

ps:  buildps

buildps: $(SOURCES:.dvi=.ps)

.tex.dvi:
	$(TEX) $(TEXARGS) $(SOURCE)

.dvi.ps:
	$(DVIPS) $(DVIPSARGS) $<

d-i_debconf5.pdf: d-i_debconf5.tex
	$(PDFTEX) $<
	$(PDFTEX) $<

.tex.pdf:
	$(PDFTEX) $(PDFTEXARGS) $<

clean:
	rm -rf *.log *.nav *.out *.snm *.toc *.aux

distclean: clean
	rm -rf *.pdf *.dvi *.ps
