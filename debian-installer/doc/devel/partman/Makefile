SHELL=bash
name=partman-doc

$(name).html/: $(name).sgml
	debiandoc2html $(name).sgml

%.txt: %.sgml
	debiandoc2text $<

%.pdf: %.sgml
	debiandoc2pdf $<

%.dvi: %.sgml
	debiandoc2dvi $<

%.info: %.sgml
	debiandoc2info $<

%.ps: %.sgml
	debiandoc2ps $<

%.tov: %.sgml
	debiandoc2textov $<

clean:
	rm -rf $(name).html
