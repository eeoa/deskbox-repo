# Shared process environment

The current VS Code and ChatGPT script revisions require Desk Box 0.15.0-dev.27 or later. Update the APK before updating these program releases.

Desk Box starts all managed processes through its common seccomp/ptrace supervisor. Scripts execute the actual tool or use `gnu_exec` for a GNU program; they do not create Bash/Git/gh aliases or maintain caller-specific tool lists. Optional SDK installers place shared environment fragments in `~/.config/deskbox/environment.d/`.

The optional .NET installer writes its environment directly to the common directory. Installing VS Code does not install a language SDK.

After authenticating with `gh`, run `gh auth setup-git` to configure Git's credential helper. These script revisions use the common runtime directly; they do not migrate or clean up earlier execution wrappers or program-specific environment directories.
