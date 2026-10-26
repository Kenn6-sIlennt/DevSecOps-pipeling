#!/usr/bin/env bash
# Menerapkan satu skenario studi kasus ke branch baru lalu push ke GitHub.
# Pemakaian: bash studi-kasus/run.sh <g1|g2|g3|g4|s1|s2>
set -euo pipefail

ID="${1:-}"
cd "$(git rev-parse --show-toplevel)"
DIR="studi-kasus/scenarios"

case "$ID" in
  g1) NAME="g1-sqli";          BRANCH="case/g1-sqli";          BASE_MODE="main";     MSG="case G1: kode rentan SQL Injection" ;;
  g2) NAME="g2-pylint";        BRANCH="case/g2-pylint";        BASE_MODE="main";     MSG="case G2: kode aman tapi tidak rapi (Pylint)" ;;
  g3) NAME="g3-dependency";    BRANCH="case/g3-dependency";    BASE_MODE="main";     MSG="case G3: dependensi flask lama (pip-audit)" ;;
  g4) NAME="g4-runtime-crash"; BRANCH="case/g4-runtime-crash"; BASE_MODE="main";     MSG="case G4: template hilang, HTTP 500 saat runtime" ;;
  s2) NAME="s2-new-routes";    BRANCH="case/s2-new-routes";    BASE_MODE="main";     MSG="case S2: tambah route /health dan /about" ;;
  s1) NAME="s1-remediation";   BRANCH="case/g1-sqli";          BASE_MODE="existing"; MSG="case S1: remediasi SQLi, docstring, urutan import" ;;
  *) echo "Pemakaian: bash studi-kasus/run.sh <g1|g2|g3|g4|s1|s2>"; exit 1 ;;
esac

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ERROR: ada perubahan yang belum di-commit. Commit atau stash dulu."; exit 1
fi

git fetch origin --quiet
DEFAULT="$(git remote show origin | sed -n 's/.*HEAD branch: //p')"

if [ "$BASE_MODE" = "main" ]; then
  git checkout "$DEFAULT" --quiet
  git pull --ff-only origin "$DEFAULT" --quiet
  git checkout -B "$BRANCH" --quiet
else
  # S1 memperbaiki branch G1 yang sama, jadi satu PR menampilkan merah lalu hijau
  if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
    git checkout "$BRANCH" --quiet
  elif git show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
    git checkout -b "$BRANCH" "origin/$BRANCH" --quiet
  else
    echo "ERROR: branch $BRANCH belum ada. Jalankan skenario g1 dulu."; exit 1
  fi
fi

COUNT=0
while IFS= read -r f; do
  dest="${f#"$DIR/$NAME/"}"; dest="${dest%.scenario}"
  mkdir -p "$(dirname "$dest")"
  cp "$f" "$dest"
  git add "$dest"
  COUNT=$((COUNT+1))
done < <(find "$DIR/$NAME" -type f -name '*.scenario')

if git diff --cached --quiet; then
  echo "Tidak ada perubahan yang perlu di-commit (skenario sudah diterapkan)."; exit 0
fi

git commit -m "$MSG" --quiet
git push -u origin "$BRANCH" --quiet
echo "OK: $COUNT file diterapkan, branch '$BRANCH' sudah di-push."

if command -v gh >/dev/null 2>&1; then
  gh pr create --base "$DEFAULT" --head "$BRANCH" --title "$MSG" \
    --body "Studi kasus pipeline IMP-DevSecOps ($ID)." 2>/dev/null \
    || echo "PR sudah ada untuk branch ini, pipeline berjalan ulang dari commit baru."
else
  REPO="$(git remote get-url origin | sed -E 's#(git@github.com:|https://github.com/)##; s#\.git$##')"
  echo "Buka Pull Request: https://github.com/$REPO/compare/$DEFAULT...$BRANCH?expand=1"
fi
echo "Lanjut: buka tab Actions dan ambil screenshot sesuai studi-kasus/README.md"
