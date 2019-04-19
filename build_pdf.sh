tlmgr install luatexja
mkdir fonts
cd fonts
wget https://github.com/adobe-fonts/source-han-sans/raw/release/SubsetOTF/SourceHanSansJP.zip
wget http://saigetsu.moe/Saigetsu/FZLTXIHK--GBK1-0.TTF
unzip SourceHanSansJP.zip
mkdir -p /usr/share/fonts/custom
cp -r ./SourceHanSansJP/* /usr/share/fonts/custom
cp FZLTXIHK--GBK1-0.TTF /usr/share/fonts/custom
chmod 744 /usr/share/fonts/custom/*



mkfontscale 
mkfontdir

fc-list

echo "Finished Font import"

cd /workdir
latexmk -cd -f -lualatex -interaction=nonstopmode -synctex=1 n8440fe.tex
