FROM ubuntu:focal AS base
WORKDIR /usr/local/bin
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common sudo curl git build-essential && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt-get update && \
    apt-get install -y curl git ansible build-essential && \
    apt-get clean autoclean && \
    apt-get autoremove --yes

FROM base AS prime
ARG TAGS
RUN addgroup --gid 1000 jacob
RUN adduser --disabled-password --gecos "" jacob --uid 1000 --gid 1000 && \
    usermod -aG sudo jacob && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER jacob
WORKDIR /home/jacob

FROM prime
COPY --chown=jacob:jacob . .
CMD ["sh", "-c", "ansible-playbook $TAGS local.yml"]

