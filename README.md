# irclu

A tiny rootless Podman container that exposes **SSH** and logs you in as user `irclu`.

This first iteration focuses on a working `sshd` with key-only auth and a `fish` login shell.

## Requirements

- Podman installed locally.
- A local `authorized_keys` file containing one or more public keys.

Useful sanity check:

```sh
echo $XDG_RUNTIME_DIR
# typically: /run/user/1000
```

## Build

From the repo root:

```sh
podman build -t localhost/irclu:latest -f Containerfile .
```

## Run locally

1) Create an `authorized_keys` file (example):

```sh
cat ~/.ssh/id_ed25519.pub > ./authorized_keys
```

2) Run the container and publish SSH on localhost:4444:

```sh
podman run --rm -it \
  --name irclu \
  -p 4444:22 \
  -e IRCLU_SSH_KEYS="$(base64 -w0 ./authorized_keys)" \
  -e IRCLU_NICK='your-nickname' \
  -e IRCLU_LIBERA_SASL_KEY='your-sasl-password' \
  # (optional fallback) -e IRCLU_NICKSERV_PASS='your-nickserv-password' \
  localhost/irclu:latest
```

Notes:

- `IRCLU_LIBERA_SASL_KEY` enables SASL (PLAIN) auth on Libera at startup.
- `IRCLU_NICK` is used as the SASL username and the IRC nick (defaults to the system username inside the container).

3) SSH in:

```sh
ssh -p 4444 -i irclu_testkey -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null irclu@localhost
```

You should land in a `fish` shell as user `irclu`.

## Transfer image to a cloud VM

### Option A: save/load tarball

On your laptop:

```sh
podman save -o irclu-image.tar localhost/irclu:latest
scp ./irclu-image.tar user@your-vm:
```

On the VM:

```sh
podman load -i ./irclu-image.tar
podman run -d --name irclu -p 4444:22 \
  -e IRCLU_SSH_KEYS="$(base64 -w0 ./authorized_keys)" \
  localhost/irclu:latest
```

### Option B: push over SSH (optional)

If you have Podman set up on both sides, you can also do a direct push:

```sh
podman push localhost/irclu:latest ssh://user@your-vm/localhost/irclu:latest
```

(Exact remote transport support can vary by Podman version/config.)
