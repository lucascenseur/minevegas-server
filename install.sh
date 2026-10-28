#!/usr/bin/env bash
# Télécharge le lanceur Fabric, les mods et les optimisations serveur.
# Le serveur vanilla Mojang est récupéré par Fabric au premier démarrage.
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl est requis pour installer le serveur." >&2
  exit 1
fi

MC_VERSION="26.3"
LOADER_VERSION="0.20.1"
INSTALLER_VERSION="1.1.2"

FABRIC_API_FILE="mods/fabric-api-0.165.0+26.3.jar"
FABRIC_API_URL="https://cdn.modrinth.com/data/P7dR8mSH/versions/EQKgpeKu/fabric-api-0.165.0%2B26.3.jar"
FABRIC_API_SHA1="8f8a23d6c9fbf7b075b31b4fb0a1007b0488d1d2"

MINEVEGAS_FILE="mods/minevegas-casino-fabric-26.3-1.0.4.jar"
MINEVEGAS_URL="https://edge.forgecdn.net/files/9275/496/minevegas-casino-fabric-26.3-1.0.4.jar"
MINEVEGAS_SHA1="0ac3d8668e9555f2a100e63db13609fa77ace1a9"

# Nom de fichier sans crochets : certains shells et outils les gèrent mal.
DNT_FILE="mods/dungeons-and-taverns-6.0.2-fabric.jar"
DNT_URL="https://edge.forgecdn.net/files/9025/950/dungeons-and-taverns-6.0.2%20%5bFabric%5d.jar"
DNT_SHA1="172ba3915c8da4c46bdf63a24a8cff2b485b838d"

LITHIUM_FILE="mods/lithium-fabric-0.26.2+mc26.3.jar"
LITHIUM_URL="https://cdn.modrinth.com/data/gvQqBUqZ/versions/xS0Q8LSi/lithium-fabric-0.26.2%2Bmc26.3.jar"
LITHIUM_SHA1="dd5a4ec2c68d7601d8bce9076f789c55a5f8bef3"

FERRITECORE_FILE="mods/ferritecore-9.0.0-fabric.jar"
FERRITECORE_URL="https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar"
FERRITECORE_SHA1="eac76ff0f3753422c61b2c44487d0d195d88d4bc"

SERVER_FILE="server.jar"
SERVER_URL="https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}/${LOADER_VERSION}/${INSTALLER_VERSION}/server/jar"
SERVER_SHA1="9f2e39ea6548d42ae9cdbd5b133a29aec0fb16c7"

sha1_of() {
  if command -v sha1sum >/dev/null 2>&1; then
    sha1sum "$1" | awk '{print $1}'
  else
    shasum -a 1 "$1" | awk '{print $1}'
  fi
}

download() {
  local url="$1"
  local dest="$2"
  local expected="$3"

  if [[ -f "$dest" ]]; then
    local current
    current="$(sha1_of "$dest")"
    if [[ "$current" == "$expected" ]]; then
      echo "OK  $dest"
      return 0
    fi
    echo "Somme SHA1 différente, nouveau téléchargement : $dest"
  fi

  mkdir -p "$(dirname "$dest")"
  echo "Téléchargement de $dest"
  curl -fL --retry 5 --retry-delay 2 -A "Mozilla/5.0" -o "${dest}.partial" "$url"
  local got
  got="$(sha1_of "${dest}.partial")"
  if [[ "$got" != "$expected" ]]; then
    rm -f "${dest}.partial"
    echo "SHA1 invalide pour $dest" >&2
    echo "  attendu : $expected" >&2
    echo "  obtenu  : $got" >&2
    exit 1
  fi
  mv "${dest}.partial" "$dest"
  echo "OK  $dest"
}

mkdir -p mods
download "$SERVER_URL" "$SERVER_FILE" "$SERVER_SHA1"
download "$FABRIC_API_URL" "$FABRIC_API_FILE" "$FABRIC_API_SHA1"
download "$MINEVEGAS_URL" "$MINEVEGAS_FILE" "$MINEVEGAS_SHA1"
download "$DNT_URL" "$DNT_FILE" "$DNT_SHA1"
download "$LITHIUM_URL" "$LITHIUM_FILE" "$LITHIUM_SHA1"
download "$FERRITECORE_URL" "$FERRITECORE_FILE" "$FERRITECORE_SHA1"

shopt -s nullglob
for jar in mods/fabric-api-*.jar; do
  if [[ "$jar" != "$FABRIC_API_FILE" ]]; then
    echo "Suppression de l'ancienne Fabric API : $jar"
    rm -f "$jar"
  fi
done
for jar in mods/minevegas-casino-*.jar; do
  if [[ "$jar" != "$MINEVEGAS_FILE" ]]; then
    echo "Suppression de l'ancienne version de MineVegas : $jar"
    rm -f "$jar"
  fi
done
for jar in mods/dungeons-and-taverns*.jar; do
  if [[ "$jar" != "$DNT_FILE" ]]; then
    echo "Suppression de l'ancienne version de Dungeons and Taverns : $jar"
    rm -f "$jar"
  fi
done
for jar in mods/lithium-*.jar; do
  if [[ "$jar" != "$LITHIUM_FILE" ]]; then
    echo "Suppression de l'ancienne version de Lithium : $jar"
    rm -f "$jar"
  fi
done
for jar in mods/ferritecore-*.jar; do
  if [[ "$jar" != "$FERRITECORE_FILE" ]]; then
    echo "Suppression de l'ancienne version de FerriteCore : $jar"
    rm -f "$jar"
  fi
done
shopt -u nullglob

echo
echo "Installation terminée."
echo "Démarre le serveur avec ./start.sh"
