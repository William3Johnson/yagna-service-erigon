FROM python:3.8
WORKDIR /erigon_server/

#   Install yagna
#   NOTE: ARG instead of ENV because I don't want this in the final image
ARG DEBIAN_FRONTEND=noninteractive

ADD https://github.com/golemfactory/yagna/releases/download/pre-rel-v0.7.0-rc8/golem-requestor_pre-rel-v0.7.0-rc8_amd64.deb yagna.deb
RUN dpkg-preconfigure ./yagna.deb
RUN echo "golem-requestor	golem/terms/testnet-01	select	yes" | debconf-set-selections
RUN apt install -y ./yagna.deb

#   Install certificates
RUN apt update \
    && apt install -y libssl-dev ca-certificates \
    && update-ca-certificates

COPY requirements.txt .
RUN python3 -m pip install -r requirements.txt

#   Cleanup
RUN rm yagna.deb requirements.txt

COPY yagna_and_server_init.sh .
RUN chmod +x yagna_and_server_init.sh

COPY server.py       .
COPY service_manager service_manager
COPY erigon_services erigon_services

ENV PYTHONUNBUFFERED=1

ENTRYPOINT ./yagna_and_server_init.sh