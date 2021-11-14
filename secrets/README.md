# Secrets

This folder contains private CA keys, passwords and other files related to specific installation security.

## Utilities

### Passwords and secrets

Generate passwords and secrets with:

```bash
# Screen
echo $(head -c 512 /dev/urandom | LC_ALL=C tr -cd 'a-zA-Z0-9' | head -c 16)

# File (without newline)
printf $(head -c 512 /dev/urandom | LC_ALL=C tr -cd 'a-zA-Z0-9' | head -c 16) > admin-password
```

Change the parameter `head -c 16` according with the desired length of the secret.

### Base64

You can obtain the base64 values `tls.crt` and `tls.key` from the private and public CA keys with the command:

```bash
# Base64 encoding with single line format
# Public key
base64 -i ca-test-internal.crt -o ca-test-internal.crt.b64
# Private key
base64 -i ca-test-internal.key -o ca-test-internal.key.b64
```

### Certificate information

You can obtain information for a given certificate with the command:

```bash
# Show certificate information
openssl x509 -in ca-test-internal.crt -noout -text
```
