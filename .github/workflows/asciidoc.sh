#!/bin/bash
set -e

mkdir -p ./dist/
mkdir -p ./themes/

CURRENT_PATH=`pwd`
ASCIIDOCTOR_PDF_DIR=`gem contents asciidoctor-pdf --show-install-dir`

cp "./src/resource/themes/default-theme.yml" ${CURRENT_PATH}/themes/default-theme.yml
cp -r -f "./src/resource/fonts/" ${CURRENT_PATH}/


# -a, --attribute=ATTRIBUTE
# -B, --base-dir=DIR
# -D, --destination-dir=DIR
# -o, --out-file=OUT_FILE
# -R, --source-dir=DIR
# -b, --backend=BACKEND
# -d, --doctype=DOCTYPE
# -r, --require=LIBRARY

asciidoctor -D ./dist/ -o index.html -r asciidoctor-diagram ./src/index.adoc

asciidoctor-pdf -D ./dist/ -o index.pdf -a scripts@=cjk -r asciidoctor-diagram ./src/index.adoc
# -a pdf-theme=./src/resource/theme-pdf.yml -a pdf-fontsdir=./src/resource/fonts
cp -rf ./src/images/ ./dist/images/