#!/bin/sh
# PreToolUse hook: intercept rm commands, only allow single-file deletion
# Reads hook input JSON from stdin, outputs blocking JSON for dangerous rm

read -r json
cmd=$(echo "$json" | grep -o '"command":"[^"]*"' | sed 's/"command":"//;s/"$//')

case "$cmd" in
  rm\ *|rm)
    # Extract arguments after 'rm '
    rest="${cmd#rm }"

    # Check for recursive flags (-r, -R)
    first="${rest%% *}"
    case "$first" in
      -*[rR]*)
        # Find the first target argument (non-flag)
        first_target=""
        for arg in $rest; do
          case "$arg" in
            -*) ;;
            *) first_target="$arg"; break ;;
          esac
        done
        # Allow recursive rm for any build directory (any depth)
        case "$first_target" in
          build|build/*|./build|./build/*|*/build|*/build/*) ;;
          *)
            echo '{"continue":false,"stopReason":"❌ 禁止递归删除，只允许删除单个文件"}'
            exit 0
            ;;
        esac
        ;;
    esac

    # Check for wildcards (*, ?)
    case "$rest" in
      *[*?]*)
        echo '{"continue":false,"stopReason":"❌ 禁止使用通配符删除，只允许删除单个文件"}'
        exit 0
        ;;
    esac

    ;;
esac
# If we get here, the command is allowed (exit 0, no output)
