FROM public.ecr.aws/bitnami/python:3.8

COPY requirements /requirements
RUN python -m pip install --no-cache -r /requirements/production.txt

COPY ci/run_server.sh /run_server
RUN chmod +x /run_server

WORKDIR /app
COPY src .

ENTRYPOINT [ "bash", "-c" ]
CMD [ "/run_server" ]
