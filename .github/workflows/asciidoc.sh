#!/bin/bash
set -e

CURRENT_PATH=`pwd`

mkdir -p ./dist/

# htmlの表示用と、pdfの埋め込み用に、imagesをdistに配置(pdfは出力時のみ参照)
cp -rf ./src/images/ ./dist/

# drawioで出力するSVGのfont-familyを一括変換 Helvetica -> GenShinGothic-P
dir_path="${CURRENT_PATH}/dist/images/*"
dirs=`find $dir_path -maxdepth 0 -type f -name *.drawio.svg`
for dir in $dirs;
do
  sed -i 's/font-family="Helvetica"/font-family="GenShinGothic-P"/g' $dir
done

# html出力
asciidoctor -D ./dist/ -o index.html -r asciidoctor-diagram ${CURRENT_PATH}/src/index.adoc

# pdf出力
asciidoctor-pdf \
  -a pdf-theme=${CURRENT_PATH}/src/resource/user-theme.yml \
  -a pdf-fontsdir=${CURRENT_PATH}/src/resource/fonts \
  -a source-highlighter=pygments \
  -a imagesdir=${CURRENT_PATH}/dist/images \
  -r ${CURRENT_PATH}/src/resource/patch-prawn.rb \
  -D ${CURRENT_PATH}/dist/ \
  -o index.pdf \
  -a scripts=cjk \
  -r asciidoctor-diagram \
  ${CURRENT_PATH}/src/index.adoc
