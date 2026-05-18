# serve-local

A lightweight Zsh script to quickly expose local ports via custom local domains over HTTPS using Caddy. It handles local DNS routing and SSL certificate provisioning automatically, cleaning up entirely when you stop it.

## How it Works

1. It appends a temporary loopback mapping for your custom domain to `/etc/hosts`.
2. It dynamically generates a temporary Caddyfile configured with internal TLS and a reverse proxy to your specified local port.
3. It spins up Caddy using this configuration to serve secure HTTPS traffic locally.
4. Upon script exit or interception of a termination signal (Ctrl+C), it automatically reverts the `/etc/hosts` changes and deletes the temporary configuration file.

Note: If the script was stopped non-gracefully, you will have to manually edit out the changes made to `/etc/hosts`

## Prerequisites

Ensure you have `caddy` installed and available in your PATH.

```bash
brew install caddy

```

## Usage

```bash
chmod +x serve-local
./serve-local <domain> <port>

```

### Example

```bash
./serve-local test.bijira.dev 8080

```
