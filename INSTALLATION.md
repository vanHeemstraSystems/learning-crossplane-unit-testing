# Crossplane CLI Installation (Required for Unit Tests)

This repository’s unit tests rely on the **Crossplane CLI** commands:

- `render`
- `beta validate`

If your CLI doesn’t show these commands in `--help`, you have the wrong binary (common on Windows when installing `crossplane.exe` via WinGet).

See official docs:
- [Install Crossplane CLI](https://docs.crossplane.io/latest/cli/)
- [Crossplane CLI command reference](https://docs.crossplane.io/latest/cli/command-reference/)

---

## Verify you have the right CLI

Run:

```bash
crossplane --help
```

You must see **both**:
- `render`
- `beta validate`

If you don’t, install the correct CLI (Windows typically uses `crank.exe`).

---

## macOS (recommended)

### Install

Use the official install script:

```bash
curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh" | sh
sudo mv crank /usr/local/bin/crossplane
```

### Verify

```bash
crossplane --help
crossplane render --help
crossplane beta validate --help
```

---

## Linux (recommended)

### Install

```bash
curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh" | sh
sudo mv crank /usr/local/bin/crossplane
```

### Verify

```bash
crossplane render --help
crossplane beta validate --help
```

---

## Windows 11 (recommended)

On Windows, the Crossplane CLI binary is commonly named **`crank.exe`**.

### 1) Confirm your CPU architecture

In **PowerShell**:

```powershell
$env:PROCESSOR_ARCHITECTURE
```

- `AMD64` → use `windows_amd64`
- `ARM64` → use `windows_arm64`

### 2) Download `crank.exe` directly

Browser directory listings may be blank/broken. Use a direct URL instead.

- **AMD64 (x64)**: `https://releases.crossplane.io/stable/current/bin/windows_amd64/crank.exe`
- **ARM64**: `https://releases.crossplane.io/stable/current/bin/windows_arm64/crank.exe`

PowerShell download example (AMD64):

```powershell
Invoke-WebRequest `
  -Uri "https://releases.crossplane.io/stable/current/bin/windows_amd64/crank.exe" `
  -OutFile "$env:USERPROFILE\Downloads\crank.exe"
```

### 3) Put `crank.exe` on your PATH (no admin)

Recommended per-user location:

- `C:\Users\<you>\bin\`

Steps:
- Create `C:\Users\<you>\bin\`
- Move `crank.exe` into `C:\Users\<you>\bin\crank.exe`
- Add `C:\Users\<you>\bin\` to your **User PATH**
  - Start → search “Environment Variables”
  - Open “Edit the system environment variables”
  - “Environment Variables…”
  - Under “User variables” select “Path” → “Edit…” → “New”
  - Add `C:\Users\<you>\bin\`
- Open a **new** terminal

### 4) Verify

```powershell
crank --help
crank render --help
crank beta validate --help
```

If `crank --help` shows `render` and `beta validate`, you’re ready.

---

## Docker requirement (for `render`)

`crossplane render` runs Composition Functions using Docker by default.

- Ensure **Docker Desktop / Docker Engine is running**
- If you use a non-default Docker context (common on macOS), the scripts in this repo attempt to auto-detect and set `DOCKER_HOST` to match the active Docker context.

Quick check:

```bash
docker ps
```

---

## Using this repo’s scripts on Windows

This repo’s scripts auto-detect which CLI binary is available:

- uses `crossplane` if found
- otherwise uses `crank`

You can also force the binary with:

```bash
XP_BIN=crank ./scripts/run-render-tests.sh
```

