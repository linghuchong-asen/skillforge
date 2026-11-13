#!/usr/bin/env bash
# 在修改 /root/.codex/cc-switch-model-catalog.json 之后运行。
#
# 原因：Codex 桌面端连接的是这台主机上长期运行的 `codex app-server`
# （启动命令类似 `codex -c features.code_mode_host=true app-server --listen unix://`）。
# 这个进程只在启动时读取一次模型目录，并把它保存在内存里。
# 只改 JSON 不会刷新桌面端模型选择器；`codex debug models` 能看到新模型，
# 是因为它每次都是新进程。
#
# 这个脚本会终止旧的 host agent。桌面端会自动重新拉起它（实测约 10 秒），
# 新进程会读取当前最新的模型目录。
set -uo pipefail

CATALOG=/root/.codex/cc-switch-model-catalog.json
echo "模型目录: $(stat -c '%y  %s bytes  %n' "$CATALOG" 2>/dev/null || echo missing)"

mapfile -t PIDS < <(pgrep -f 'codex .*app-server --listen unix' 2>/dev/null || true)
if [ "${#PIDS[@]}" -eq 0 ]; then
  echo "没有长期运行的 app-server；无需处理"
  echo "提示：在桌面端打开一个远程对话，它会自动启动 app-server"
  exit 0
fi

echo "正在终止: ${PIDS[*]}"
kill -TERM "${PIDS[@]}" 2>/dev/null || true
sleep 3
for p in "${PIDS[@]}"; do
  if ps -p "$p" >/dev/null 2>&1; then kill -KILL "$p" 2>/dev/null || true; fi
done
sleep 8

if ps -eo args | grep -q '[a]pp-server --listen unix'; then
  echo "新的 app-server:"
  ps -eo pid,lstart,args | grep '[a]pp-server --listen unix' | head -2
else
  echo "app-server 还没有重新启动；打开远程对话时会自动启动"
fi
echo "完成 - 请在桌面端重新打开模型选择器"