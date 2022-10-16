#!/bin/bash
set -e

mkdir -p ./dist/

CURRENT_PATH=`pwd`
ASCIIDOCTOR_PDF_DIR=`gem contents asciidoctor-pdf --show-install-dir`

# cp "${ASCIIDOCTOR_PDF_DIR}/data/themes/default-theme.yml" ${CURRENT_PATH}/themes/default-theme.yml
# cp -r -f "${ASCIIDOCTOR_PDF_DIR}/data/fonts/" ${CURRENT_PATH}/


# -a, --attribute=ATTRIBUTE
# -B, --base-dir=DIR
# -D, --destination-dir=DIR
# -o, --out-file=OUT_FILE
# -R, --source-dir=DIR
# -b, --backend=BACKEND
# -d, --doctype=DOCTYPE
# -r, --require=LIBRARY

asciidoctor -D ${CURRENT_PATH}/dist/ -o index.html -r asciidoctor-diagram ${CURRENT_PATH}/src/index.adoc

asciidoctor-pdf -a pdf-theme=${CURRENT_PATH}/src/assets/theme-pdf.yml -a pdf-fontsdir=${CURRENT_PATH}/src/assets/fonts -D ${CURRENT_PATH}/dist/ -o index.pdf -a scripts@=cjk -r asciidoctor-diagram ${CURRENT_PATH}/src/index.adoc

cp -rf ./src/images/ ./dist/images/