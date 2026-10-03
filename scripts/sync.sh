#!/data/data/com.termux/files/usr/bin/bash
# Autonomous GitHub Sync Utility for zahidoverflow/aihackz
# Synchronizes local content, scripts, and trackers with private GitHub repository.

REPO_DIR="/data/data/com.termux/files/home/Git/aihackz"
REMOTE="origin"
BRANCH="main"

cd "$REPO_DIR" || exit 1

sync_once() {
  git fetch "$REMOTE" "$BRANCH" >/dev/null 2>&1

  # Check if there are local uncommitted changes
  if [ -n "$(git status --porcelain)" ]; then
    TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%SZ")
    git add -A
    git commit -m "sync(auto): update aihackz assets & content ledger [$TIMESTAMP]"
    echo "[✓] Local changes committed: $TIMESTAMP"
  fi

  # Push to GitHub
  if git push "$REMOTE" "$BRANCH" >/dev/null 2>&1; then
    echo "[✓] Synced cleanly with github.com/zahidoverflow/aihackz ($BRANCH)"
    return 0
  else
    echo "[!] Push failed or remote branch ahead. Pulling with rebase..."
    git pull --rebase "$REMOTE" "$BRANCH"
    git push "$REMOTE" "$BRANCH"
    return $?
  fi
}

sync_daemon() {
  INTERVAL="${1:-600}" # Default: 10 minutes
  echo "[*] Starting aihackz sync daemon (Interval: ${INTERVAL}s)..."
  if command -v termux-wake-lock >/dev/null 2>&1; then
    termux-wake-lock
    echo "[✓] Termux wake-lock held."
  fi
  while true; do
    sync_once
    sleep "$INTERVAL"
  done
}

case "${1:-once}" in
  once)
    sync_once
    ;;
  daemon)
    sync_daemon "${2:-600}"
    ;;
  status)
    git status
    ;;
  *)
    echo "Usage: $0 {once|daemon [interval_seconds]|status}"
    exit 1
    ;;
esac
