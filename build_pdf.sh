tlmgr install luatexja
cd /workdir
latexmk -cd -f -lualatex -interaction=nonstopmode -synctex=1 n8440fe.tex
