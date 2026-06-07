# Atelier

Atelier is the clean native macOS client for this Boop fork.

Boop remains the backend and agent runner. Atelier talks to the local Boop
server for chat, runtime status, and connection status, and reads Boop's Convex
deployment for memory and automations.

## Run

From this folder:

```sh
./script/build_and_run.sh
```

Use `--verify` to build, launch, and confirm the app process exists:

```sh
./script/build_and_run.sh --verify
```

## Defaults

- Boop server: `http://127.0.0.1:3456`
- Convex cloud URL: `https://limitless-meerkat-752.convex.cloud`

Both are editable in Atelier's Settings screen.

## Scope

The first version intentionally avoids the old Harvey dashboard clone. It only
contains the core native surfaces needed to prove the backend contract:

- Chat
- Memory
- Automations
- Connections
- Settings/status
