all:
	pandoc -t beamer -s emacs.markdown --toc -V theme:Warsaw -o emacs.tex
	patch emacs.tex gconfs.patch
	texi2pdf emacs.tex
