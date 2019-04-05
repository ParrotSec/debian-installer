all: svnplot.png

clean:
	rm -f svnplot.png log commits committers
	
log: svndir
	svn log -v $(shell cat svndir) > log

commits: log svncommits
	./svncommits log > commits

committers: log svncommitters
	./svncommitters log > committers

svnplot.png: commits committers plotdata
	./plotdata > svnplot.png
