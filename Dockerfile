FROM bitnami/python:3.8

COPY ci/install_requirements.sh /install_requirements
RUN chmod +x /install_requirements

COPY requirements /requirements
RUN /install_requirements production

COPY ci/run_server.sh /run_server
RUN chmod +x /run_server

WORKDIR /app
COPY src .

ENTRYPOINT [ "bash", "-c" ]
CMD [ "/run_server" ]
