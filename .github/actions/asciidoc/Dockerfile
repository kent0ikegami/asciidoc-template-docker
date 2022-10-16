# Container image that runs your code
FROM asciidoctor/docker-asciidoctor:latest

LABEL "version"="1.0"


RUN gem install asciidoctor-pdf-cjk-kai_gen_gothic && \
  asciidoctor-pdf-cjk-kai_gen_gothic-install

# Copies your code file from your action repository to the filesystem path `/` of the container

COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]