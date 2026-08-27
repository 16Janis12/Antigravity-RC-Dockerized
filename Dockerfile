FROM debian:bookworm-slim

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install core dependencies and useful development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    openssh-client \
    sudo \
    tar \
    procps \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Configure UTF-8 locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create a non-root developer user with sudo privileges
ARG USERNAME=antigravity
ARG USER_UID=1000
ARG USER_GID=1000

RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Create workspace directory with correct ownership as root
RUN mkdir -p /workspace && chown -R ${USERNAME}:${USERNAME} /workspace

# Switch to non-root user
USER ${USERNAME}
ENV HOME=/home/${USERNAME}
WORKDIR ${HOME}

# Pre-create config and runtime directories in home directory
RUN mkdir -p ${HOME}/.gemini/antigravity-cli ${HOME}/.antigravity

# Install Antigravity CLI (agy)
RUN curl -fsSL https://antigravity.google/cli/install.sh | bash

# Ensure binary is in PATH
ENV PATH="${HOME}/.local/bin:${PATH}"

# Workspace directory for mounting projects
WORKDIR /workspace

# Copy and configure entrypoint script
COPY --chown=${USERNAME}:${USERNAME} entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sudo chmod +x /usr/local/bin/entrypoint.sh

# Expose internal daemon hub port
EXPOSE 4400

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["run"]
