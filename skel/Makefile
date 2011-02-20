all : pdf

pdf : book.pdf

book.pdf : out/tmpl.dvi
	dvipdfmx -o book.pdf out/tmpl.dvi

out/tmpl.dvi : tmpl.tex head.tex body.tex
	platex -output-directory=out tmpl.tex
	platex -output-directory=out tmpl.tex

body.tex : body.txt
	wikitex convert
