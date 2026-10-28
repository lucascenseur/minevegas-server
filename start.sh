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
  || ! -f mods/dungeons-and-taverns-6.0.2-fabric.jar \
  || ! -f mods/lithium-fabric-0.26.2+mc26.3.jar \
  || ! -f mods/ferritecore-9.0.0-fabric.jar \
  || ! -f mods/DistantHorizons-3.3.4-26.3-fabric-neoforge.jar \
  || ! -f mods/Jade-mc26.3-Fabric-26.3.5.jar \
  || ! -f mods/appleskin-fabric-mc26.3-3.0.10.jar \
  || ! -f mods/xaerominimap-fabric-26.3-26.6.2.jar \
  || ! -f mods/ForgeConfigAPIPort-v26.3.1-mc26.3.x-Fabric.jar \
  || ! -f mods/travelersbackpack-fabric-26.3-11.4.2.jar \
  || ! -f mods/ly-graves-3.0.1.jar ]]; then
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
