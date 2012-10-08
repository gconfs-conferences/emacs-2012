all:
	pandoc -t beamer -s emacs.markdown --toc -V theme:Warsaw -o emacs.pdf
