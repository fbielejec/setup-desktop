# Future Improvements

## Interactive Component Selection

Add a first phase to run.sh where the user selects which components to install via a TUI or simple menu. Could also ask questions that drive the setup (e.g., preferred editor, optional languages, etc.).

## Full Idempotency

Each script should:
- Check current state thoroughly (version installed, config already deployed, etc.)
- Skip what's already done
- Report what it did vs skipped
- Support a `--force` flag to reinstall/reconfigure even if already present
- Handle version upgrades gracefully (e.g., Java 17 installed but 21 desired)

## Broader OS Support

Currently targets Linux Mint only. Could generalize to:
- Ubuntu (minimal changes)
- Other Debian-based distros (Pop!_OS, etc.)
- Would need OS detection and conditional logic for package names/repos

## Emacs

Review and improve emacs.d

## AGENTS.md / CLAUDE.md

Maintain a repository with current personal/global CLAUDE.md/AGENTS.md.

## Dry Run Mode

A `--dry-run` flag that shows what would be installed/configured without making changes. Useful for reviewing before running on a new machine.

## Test Suite

Automated testing using Docker containers to verify scripts work on a fresh Mint install. Could run in CI on each commit.

## Backup/Restore

Before overwriting configs (bashrc, i3 config, etc.), back up existing files to a timestamped directory. Allows easy rollback.
