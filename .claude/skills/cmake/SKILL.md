---
name: cmake
description: >
  [Windows only] Run cmake commands through Windows cmd with MSVC environment
  initialization and Ninja generator. Uses cmake-vs.bat to handle VS toolchain
  setup, and forces Ninja generator for configure commands.
platforms: [win32]
---

# /cmake — MSVC + Ninja Build Helper

> ⚠ **Windows only.** This skill only applies on Windows (win32). On Linux or macOS, skip this skill and run cmake directly — no VS env or Ninja override needed.

When user types `/cmake <arguments>`, run cmake inside Windows **cmd** with VS 2022 Community MSVC environment and Ninja generator.

## Available Helper

A batch script is at `.claude/skills/cmake/cmake-vs.bat` (in the skill directory itself) — it calls `vcvarsall.bat x64` then forwards all arguments to `cmake`. Use it to avoid Git Bash path/quoting issues with `cmd //c`.

## How to Run

### Configure command (`-B`, `-S`, `--preset`, or bare args)

Add `-G Ninja` if no `-G` flag in the user's arguments:
```
cmd //c "call .claude\skills\cmake\cmake-vs.bat -G Ninja <args>"
```

### Build / Install (--build, --install)
```
cmd //c "call .claude\skills\cmake\cmake-vs.bat <args>"
```

### User specified a generator already
If `-G <generator>` is in the arguments, respect it — don't add `-G Ninja`:
```
cmd //c "call .claude\skills\cmake\cmake-vs.bat <args>"
```

> The batch path uses backslashes because `cmd //c` sees them after MSYS argument processing.
> `.claude\skills\cmake\cmake-vs.bat` has no spaces, so quoting is simple.

## Examples

| Input | Command |
|-------|---------|
| `/cmake -B build -S .` | `cmd //c "call .claude\skills\cmake\cmake-vs.bat -G Ninja -B build -S ."` |
| `/cmake --build build` | `cmd //c "call .claude\skills\cmake\cmake-vs.bat --build build"` |
| `/cmake -B build -G "VS 17 2022"` | User chose generator → `cmd //c "call .claude\skills\cmake\cmake-vs.bat -B build -G \"VS 17 2022\""` |
