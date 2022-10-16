# Container image that runs your code
FROM asciidoctor/docker-asciidoctor:latest

RUN gem install asciidoctor-pdf-cjk-kai_gen_gothic

COPY ./.github/workflows/asciidoc.sh /asciidoc.sh 

ENTRYPOINT ["/asciidoc.sh"]