#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -f server.env ]]; then
  cp server.env.example server.env
fi

set -a
# shellcheck disable=SC1091
source server.env
set +a

MEMORY="${MEMORY:-4G}"

if [[ ! -f server.jar \
  || ! -f mods/fabric-api-0.165.0+26.3.jar \
  || ! -f mods/minevegas-casino-fabric-26.3-1.0.4.jar \
  || ! -f mods/dungeons-and-taverns-6.0.2-fabric.jar ]]; then
  echo "Fichiers manquants. Lance d'abord ./install.sh" >&2
  exit 1
fi

if ! command -v java >/dev/null 2>&1; then
  echo "Java introuvable. Minecraft 26.3 exige Java 25. Voir README.md." >&2
  exit 1
fi

major="$(java -version 2>&1 | sed -nE 's/.*version "([0-9]+).*/\1/p' | head -n1)"
if [[ -z "$major" || "$major" -lt 25 ]]; then
  echo "Java ${major:-inconnu} détecté. Il faut Java 25 ou plus récent." >&2
  exit 1
fi

if [[ ! -f eula.txt ]] || ! grep -q '^eula=true' eula.txt; then
  echo "Accepte le CLUF Minecraft dans eula.txt (eula=true)." >&2
  exit 1
fi

echo "Démarrage MineVegas Casino (mémoire ${MEMORY}, Java ${major})"
exec java \
  -Xms"${MEMORY}" \
  -Xmx"${MEMORY}" \
  -XX:+UseG1GC \
  -XX:+ParallelRefProcEnabled \
  -XX:MaxGCPauseMillis=200 \
  -Dfile.encoding=UTF-8 \
  -jar server.jar \
  nogui
