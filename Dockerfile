# Test harness: provision the playbook inside a container instead of a real
# machine. Build the plain desktop image or the Neovim variant via build args.
#
#   docker build -t new-computer .
#   docker build -t nvim-computer --build-arg INSTALL_NVIM=true .
#
# Tasks that decrypt secrets (the SSH key) need a vault password at run time:
#   docker run --rm -e TAGS="--ask-vault-pass" -it new-computer
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

ENV DEBIAN_FRONTEND=noninteractive
ENV TAGS=""

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y software-properties-common sudo curl git build-essential && \
    apt-add-repository -y ppa:ansible/ansible && \
    apt-get update && apt-get install -y ansible && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ARG INSTALL_NVIM=false
RUN if [ "$INSTALL_NVIM" = "true" ]; then \
      apt-add-repository -y ppa:neovim-ppa/unstable && \
      apt-get update && apt-get install -y neovim && \
      apt-get clean && rm -rf /var/lib/apt/lists/*; \
    fi

# Match the playbook's target user (uid/gid 1000, passwordless sudo).
# Ubuntu's official image ships a built-in `ubuntu` user/group at uid/gid 1000
# since 24.04 — remove it first so it doesn't collide with `jacob`.
RUN (userdel -r ubuntu 2>/dev/null || true) && \
    (groupdel ubuntu 2>/dev/null || true) && \
    addgroup --gid 1000 jacob && \
    adduser --disabled-password --gecos "" --uid 1000 --gid 1000 jacob && \
    usermod -aG sudo jacob && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER jacob
WORKDIR /home/jacob/ansible
COPY --chown=jacob:jacob . .

CMD ["sh", "-c", "ansible-playbook ${TAGS} ubuntu.yml"]
