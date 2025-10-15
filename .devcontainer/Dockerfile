# Use an official lightweight Ubuntu as the base
FROM ubuntu:22.04

# Install essentials
RUN apt-get update && \
    apt-get install -y sudo curl git docker.io docker-compose php-cli php-xml php-mbstring php-zip php-intl php-curl unzip vim && \
    apt-get clean

# Create vscode user (Codespaces uses this)
RUN useradd -m vscode && echo "vscode ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /workspace
USER vscode
