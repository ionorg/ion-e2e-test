FROM ubuntu:20.04

RUN apt update -yq
RUN DEBIAN_FRONTEND=noninteractive apt install -yq python3-pip wget unzip ssh jq golang

RUN wget https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip -O terraform.zip
RUN unzip terraform.zip
RUN install terraform /bin

RUN pip3 install linode-cli selenium Pillow numpy
 
ENV TRAVIS_BUILD_ID=""
ENV BROWSERSTACK_URL=""
ENV JOB_ID=""
ENV MULTI=""
ENV LINODE_KEY=""
ENV LINODE_DOMAIN_ID=""
ENV GO111MODULE=on

RUN mkdir /test
WORKDIR /test

COPY join.go go.mod go.sum /test/

RUN go get .

COPY . /test