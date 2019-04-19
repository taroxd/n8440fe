sudo tlmgr install luatexja
mkdir fonts
cd fonts
wget https://github.com/adobe-fonts/source-han-sans/raw/release/OTF/SourceHanSansJ.zip
sudo apt-get install unzip
unzip SourceHanSansJ.zip
rm SourceHansSansJ.zip
sudo mkdir -p /usr/share/fonts/custom
sudo cp -r ./ /usr/share/fonts/custom
sudo chmod -r 744 /usr/share/fonts/custom/*

sudo mkfontscale 
sudo mkfontdir

cd /workdir
latexmk -cd -f -lualatex -interaction=nonstopmode -synctex=1 n8440fe.tex
