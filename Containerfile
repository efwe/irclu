# syntax=docker/dockerfile:1
FROM ubuntu:25.10

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        tzdata \
        openssh-server \
        fish \
        ca-certificates \
        tmux \
        weechat \
        vim \
        curl \
        wget \
        xh \
        ripgrep \
        ncurses-term \
    && ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime \
    && echo "$TZ" > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Static MOTD displayed on SSH login.
RUN printf '%s\n' '~~>2xS!' > /etc/motd

# Create an unprivileged user for SSH logins.
RUN useradd \
      --create-home \
      --shell /usr/bin/fish \
      irclu \
    && touch /home/irclu/.hushlogin \
    && mkdir -p /home/irclu/.ssh \
    && chmod 700 /home/irclu/.ssh \
    && chown -R irclu:irclu /home/irclu/.ssh \
    && chown irclu:irclu /home/irclu/.hushlogin

# sshd expects this directory.
RUN mkdir -p /run/sshd

COPY etc/ssh/sshd_config /etc/ssh/sshd_config
COPY etc/fish/conf.d/00-term.fish /etc/fish/conf.d/00-term.fish
COPY etc/fish/conf.d/10-tmux.fish /etc/fish/conf.d/10-tmux.fish
COPY etc/fish/config.fish /etc/fish/config.fish
COPY etc/tmux.conf /etc/tmux.conf
COPY weechat/ /home/irclu/.config/weechat/
COPY usr/local/bin/irclu-entrypoint /usr/local/bin/irclu-entrypoint
RUN chmod +x /usr/local/bin/irclu-entrypoint

RUN chown -R irclu:irclu /home/irclu/.config

EXPOSE 22

# IRCLU_SSH_KEYS: base64-encoded authorized_keys file content.
ENV IRCLU_SSH_KEYS=

ENTRYPOINT ["/usr/local/bin/irclu-entrypoint"]
