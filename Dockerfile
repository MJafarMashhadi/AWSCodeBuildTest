FROM python:3.8-slim 

COPY ci/install_requirements.sh /install_requirements
RUN chmod +x /install_requirements

COPY requirements /requirements
RUN /install_requirements production

WORKDIR /app
COPY src .

ENTRYPOINT [ "python" ]
CMD [ "/app/start.py" ]
