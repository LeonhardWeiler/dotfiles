I maintain a personal Arch Linux dotfiles repository with a custom Bash installer (`./install`). I want a professional CI/CD setup using GitHub Actions that automatically validates the repository.

Design a complete testing pipeline. The solution should include:

1. A fast workflow that runs on every push and pull request.

   - Run ShellCheck on all Bash scripts.
   - Run `bash -n` syntax checking.
   - Verify every source listed in `setup/links.conf` exists.
   - Detect duplicate targets in `links.conf`.
   - Detect malformed lines.
   - Run `./install -n`.
   - Run `./install status`.

2. An Arch Linux integration workflow.

   - Execute inside an Arch Linux environment (container or VM).
   - Install the minimum required packages.
   - Clone the repository.
   - Execute the installer in a non-interactive way.
   - Verify expected symlinks were created.
   - Verify user services were enabled where possible.
   - Verify idempotency by running the installer multiple times.
   - Verify `--force` correctly creates `.bak` backups.
   - Verify `unlink` removes only repository-managed symlinks.

3. Structure the workflows into reusable GitHub Actions YAML files.

4. If helper scripts are needed (for validating `links.conf`, smoke tests, etc.), implement them under a `tests/` directory.

5. Keep the workflows readable, well commented, and suitable for long-term maintenance.

Prefer standard GitHub Actions, avoid unnecessary dependencies, and fail fast with clear error messages.
