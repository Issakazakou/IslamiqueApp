#!/usr/bin/env bash
# Test d'intégration HTTP :  bash backend/tests/integration.sh
set -u
cd "$(dirname "$0")/.."
PORT=${PORT:-8791}; B=http://127.0.0.1:$PORT
STORE=$(mktemp -d)
# SOURCE=sqlite bash tests/integration.sh  -> mêmes tests, questions lues depuis une base SQLite
if [ "${SOURCE:-json}" = "sqlite" ]; then
  php tests/make_sqlite.php "$STORE/quiz.sqlite" >/dev/null || exit 2
  export QUIZ_DB_DSN="sqlite:$STORE/quiz.sqlite" QUIZ_DB_SCHEMA=""
  echo "(source des questions : base SQLite)"
fi
QUIZ_STORAGE_DIR=$STORE QUIZ_RATE_LIMIT=${QUIZ_RATE_LIMIT:-120} php -S 127.0.0.1:$PORT -t public public/index.php >/dev/null 2>&1 &
PID=$!
trap 'kill $PID 2>/dev/null; rm -rf "$STORE"' EXIT
for i in $(seq 1 30); do curl -s $B/api/health >/dev/null && break; sleep 0.2; done
fail=0
ok(){ if [ "$2" = "$3" ]; then echo "  OK   $1"; else echo "  FAIL $1 (obtenu: $2, attendu: $3)"; fail=$((fail+1)); fi; }
j(){ python3 -c "import sys,json; d=json.load(sys.stdin); print($1)"; }
post(){ curl -s -X POST "$B$1" -H 'Content-Type: application/json' -d "$2"; }
code(){ curl -s -o /dev/null -w '%{http_code}' -X POST "$B$1" -H 'Content-Type: application/json' -d "$2"; }

echo "Questions & session"
R=$(curl -s "$B/api/questions/coran_culture?level=debutant&limit=3&random=1")
SESS=$(echo "$R" | j "d['session']")
ok "32 hex"                         "$(echo -n "$SESS" | wc -c | tr -d ' ')" "32"
ok "3 questions"                    "$(echo "$R" | j "d['count']")" "3"
ok "aucune bonneReponse exposée"    "$(echo "$R" | grep -c bonneReponse)" "0"
ok "answers=1 ignoré"               "$(curl -s "$B/api/questions/coran_culture?limit=1&answers=1" | grep -c bonneReponse)" "0"
ID=$(echo "$R" | j "d['questions'][0]['id']")
OTHER=$(python3 -c "import json;d=json.load(open('data/questions.json'))['coran_culture'];ids=[q['id'] for q in d];print(next(i for i in ids if i not in $(echo "$R" | j "[q['id'] for q in d['questions']]")))")

echo "Check"
R1=$(post /api/quiz/coran_culture/check "{\"session\":\"$SESS\",\"id\":$ID,\"choice\":0}")
RIGHT=$(echo "$R1" | j "d['bonneReponse']")
ok "check renvoie bonneReponse"     "$([ -n "$RIGHT" ] && echo yes)" "yes"
R2=$(post /api/quiz/coran_culture/check "{\"session\":\"$SESS\",\"id\":$ID,\"choice\":0}")
ok "idempotent (même choix)"        "$(echo "$R2" | j "d['bonneReponse']")" "$RIGHT"
OTHERCHOICE=$(( (RIGHT+1) % 4 ))
ok "autre choix -> 409 (anti-brute-force)" "$(code /api/quiz/coran_culture/check "{\"session\":\"$SESS\",\"id\":$ID,\"choice\":$OTHERCHOICE}")" "409"
ok "question hors session -> 422"   "$(code /api/quiz/coran_culture/check "{\"session\":\"$SESS\",\"id\":$OTHER,\"choice\":0}")" "422"
ok "sans session -> 422"            "$(code /api/quiz/coran_culture/check "{\"id\":$ID,\"choice\":0}")" "422"
ok "session inconnue -> 410"        "$(code /api/quiz/coran_culture/check "{\"session\":\"$(printf 'a%.0s' $(seq 32))\",\"id\":$ID,\"choice\":0}")" "410"
C=$(code /api/quiz/hadith/check "{\"session\":\"$SESS\",\"id\":$ID,\"choice\":0}")
ok "session d'une autre catégorie refusée (410/422)" "$([ "$C" = 410 ] || [ "$C" = 422 ] && echo refusée)" "refusée"
ok "choix hors limites -> 422"      "$(code /api/quiz/coran_culture/check "{\"session\":\"$SESS\",\"id\":$ID,\"choice\":9}")" "422"

echo "Submit"
ID2=$(echo "$R" | j "d['questions'][1]['id']")
S1=$(post /api/quiz/coran_culture/submit "{\"session\":\"$SESS\",\"answers\":{\"$ID\":$OTHERCHOICE,\"$ID2\":-1}}")
ok "submit garde le choix déjà vérifié" "$(echo "$S1" | j "[r for r in d['results'] if r['id']==$ID][0]['choice']")" "0"
ok "temps écoulé (-1) = faux"       "$(echo "$S1" | j "[r for r in d['results'] if r['id']==$ID2][0]['correct']")" "False"
ok "total = 2"                      "$(echo "$S1" | j "d['total']")" "2"
ok "submit hors session -> 422"     "$(code /api/quiz/coran_culture/submit "{\"session\":\"$SESS\",\"answers\":{\"$OTHER\":0}}")" "422"
ok "submit sans session -> 422"     "$(code /api/quiz/coran_culture/submit "{\"answers\":{\"$ID\":0}}")" "422"

echo "Niveaux"
for lvl in debutant intermediaire avance; do
  ok "coran/$lvl = 25 questions" "$(curl -s "$B/api/questions/coran_culture?level=$lvl" | j "d['count']")" "25"
done
ok "niveau invalide -> 422" "$(curl -s -o /dev/null -w '%{http_code}' "$B/api/questions/coran_culture?level=zzz")" "422"

echo
[ $fail -eq 0 ] && echo "Tous les tests d'intégration passent." || echo "$fail test(s) en échec."
exit $fail
