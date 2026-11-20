# Optional development tools

These helpers require Desk Box 0.15.0-dev.27 or later and run after VS Code is installed. They use the public
package interface and app-private home; no root, chroot, system mounts or upstream
extension patches are required. Run downloaded helpers from the same release tag
as their adjacent lock files. Existing projects and unrelated settings are retained.

- `sh install-cpp.sh`: install Clang/Make, install the signed LLVM clangd extension,
  and discover the compiler's target and include directories for editor analysis.
  Microsoft IntelliSense is disabled through its supported setting. This provides
  completion, diagnostics and definition navigation through clangd; it does not
  repair Microsoft's native IntelliSense engine or validate its debugger.
  Existing custom clangd paths/flags take precedence. Settings containing JSONC
  comments must be configured through the editor; the helper refuses to replace them.
- `sh install-dotnet.sh`: install the pinned .NET 10 LTS ARM64 SDK and matching ICU
  dependency using the adjacent `dotnet-sdk.lock.json`. Both downloads are checked.
  The `dotnet` launcher goes in `~/.local/bin`; no invariant-globalization bypass is used.
  An owned `~/.config/deskbox/environment.d/dotnet.sh` fragment makes ICU available
  to all programs and terminals, including extension apphosts.
  After installing the C# extension, run `sh configure-csharp.sh` to select this SDK.
- `sh configure-python.sh`: select the upstream JavaScript environment locator and
  disable its experimental native locator, which crashes on this Android app UID.
  Run after installing the Microsoft Python extension, then reload VS Code.
- `sh python-venv.sh /absolute/project/.venv`: create a Python virtual environment and
  bootstrap the pinned official PyPI pip wheel, checking SHA-256. This avoids relying
  on an ensurepip wheel in the immutable APK base. Activate normally and use
  `python -m pip install ...`. It does not replace the base interpreter or system pip.

Program execution is provided by Desk Box's shared runtime. There are no Git/gh
aliases or per-application tool lists. Install `gh` with `pkg install gh`, authenticate
on the device, and run `gh auth setup-git` there. Never copy another machine's credentials.

The SDK and compiler packages are optional; the standard VS Code installation does
not download all language toolchains. See the main Desk Box device validation report
for tested versions and remaining platform limitations.
