FROM ubuntu:20.10

COPY requirements.txt requirements.txt

RUN apt-get update && \
   apt-get -y install curl wget python3 python3-dev python3-pip

RUN pip3 install --no-cache -r requirements.txt

WORKDIR /usr/src/app

COPY test_smoke.py .
