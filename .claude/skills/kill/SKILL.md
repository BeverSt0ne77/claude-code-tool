---
name: kill
description: >
  [Windows only] Force-kill Windows processes with escalation (taskkill -> wmic ->
  PowerShell). Handles stubborn processes that taskkill alone can't terminate.
platforms: [win32]
---

# /kill — Windows Force-Kill Helper

> ⚠ **Windows only.** On Linux/macOS skip this skill and use native `kill`/`pkill`.

When user types `/kill <process-name>`, terminate the matching process(es) using
escalating force methods until the process is gone. Returns a clear report of
what was killed (or why it failed).

## Usage

```
/kill <process_name_or_wildcard>
```

| Example | Kills |
|---------|-------|
| `/kill restudio.exe` | Terminate restudio.exe |
| `/kill flutter*.exe` | All flutter-related processes |
| `/kill dart.exe` | Dart VM process |
| `/kill adb.exe` | ADB server |
| `/kill java.exe` | All Java processes |

## Execution Steps

### Step 1 — Parse the Name

Take the user's argument as the process name. If no extension given, append `.exe`
for Windows. Wildcards (`*`, `?`) are supported.

### Step 2 — Check If Process Exists

```
tasklist //fi "IMAGENAME eq <name>"
```

If not running, report "no matching processes" and stop.

### Step 3 — Kill (escalating force)

Try each method in order until the process is gone (verify with `tasklist` after each):

**Method 1 — taskkill:**
```
taskkill //f //im <name>
```

**Method 2 — WMIC (if Method 1 fails):**
```
wmic process where name='<name>' delete
```

**Method 3 — PowerShell (if Method 2 fails):**
```
powershell -NoProfile -Command "Get-Process -Name '<base_name>' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue"
```

**Method 4 — WMIC terminate (last resort):**
```
wmic process where name='<name>' call terminate
```

> For wildcards (e.g., `flutter*.exe`): list matching processes first, then kill
> each one individually. Use `tasklist` with wildcards:
> ```
> tasklist //fi "IMAGENAME like flutter%"
> ```

> ⚡ **Git Bash note**: Use double slashes for Windows tools — `//f`, `//im`, `//fi`
> instead of `/f`, `/im`, `/fi`. Git Bash (MSYS) converts single `/` to paths.

### Step 4 — Report

Show which method succeeded and what processes were terminated:

```
✓ Killed <count> process(es) matching '<name>' via <method>
```

If all methods fail, show the remaining process info so the user can investigate:

```
✗ Failed: <name> still running after all kill methods.
  PID <pid> - owner: <username>
  Suggested: run terminal as Administrator, or use:
    wmic process where processid=<pid> call terminate
```

## Notes

- **Wildcards**: Use standard Windows wildcards (`*` = any, `?` = one char).
  `flutter*` matches flutter.exe, flutter_tester.exe, etc.
- **Admin**: Some processes (system, services) require Administrator. If killing
  fails, suggest running Claude Code or terminal as Admin.
- **Safety**: The skill kills by image name — be specific to avoid killing
  unrelated processes.
