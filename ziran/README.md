# Ziran in this fork

This fork of VSCodium ships the [Ziran language extension](https://github.com/ziranlang/ziran-vscode)
(`kryonlabs.ziran-language`) as a built-in extension. Everything else is
upstream VSCodium.

## How it is built

- `extension.json` pins the extension's repository and commit.
- `prepare_extension.sh` runs from `prepare_vscode.sh` right after
  `product.json` is merged. It downloads that commit's source archive, packages
  it with `vsce`, and adds a `builtInExtensions` entry with a local `vsix` path
  to VS Code's `product.json`.
- VS Code's own build then unpacks it into `.build/extensions`, so it ships in
  the desktop app and in the remote server (REH) like any other built-in
  extension.

Build as usual, for example `./dev/build.sh` (see
[docs/howto-build.md](../docs/howto-build.md)).

## Updating the extension

Set `commit` in `extension.json` to a newer `ziranlang/ziran-vscode` commit and
rebuild. Between rebuilds, a `.vsix` with a higher version installed with
`codium --install-extension ziran-language.vsix` overrides the built-in copy;
the same or a lower version is ignored in favour of the built-in one.
