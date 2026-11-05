# Helix LSP Bridge

A Zed extension that starts language servers using the command, arguments, and
environment defined in the user's Helix `languages.toml`, instead of resolving
them itself.

The practical goal: if you already maintain Helix language-server
configuration, that same configuration becomes the source of truth for Zed's
language servers.

## Building locally

Zed compiles the extension itself when you install it as a dev extension, so
this is only needed to validate the code yourself. The target is
`wasm32-wasip2`:

```sh
RUSTC=$(rustup which rustc) rustup run stable cargo build --target wasm32-wasip2
```

## References

- [Zed language extensions](https://zed.dev/docs/extensions/languages)
- [Zed extension API](https://docs.rs/zed_extension_api)
- [Zed extension capabilities](https://zed.dev/docs/extensions/capabilities)
- [Helix `languages.toml`](https://github.com/helix-editor/helix/blob/master/book/src/languages.md)
