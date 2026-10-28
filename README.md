# Serveur MineVegas Casino

Serveur Minecraft **26.3** avec [MineVegas Casino](https://www.curseforge.com/minecraft/mc-mods/minevegas-casino) (blackjack, roulette, machines à sous, Derby des canards, roue de la fortune, Plinko).

| Réglage | Valeur |
| --- | --- |
| Version | Minecraft 26.3 |
| Chargeur | Fabric Loader 0.20.1 |
| Dépendance | Fabric API 0.165.0+26.3 |
| Mods | MineVegas Casino 1.0.4, Dungeons and Taverns 6.0.2, Lithium 0.26.2, FerriteCore 9.0.0, Distant Horizons 3.3.4 |
| Java | 25 ou plus récent |
| Monde | Survie, difficulté normale, PVP activé |
| Comptes | Officiels uniquement (`online-mode=true`) |
| Port | TCP `25565` |
| Joueurs | 20 |
| RAM | 4 Go (`server.env`) |

Le dépôt ne contient pas les jars. `install.sh` les télécharge et vérifie leur somme SHA1. Au premier `start.sh`, Fabric récupère le serveur officiel Mojang (environ 60 Mo).

MineVegas Casino est créé par medmed_dev (byMehd), sous licence MIT avec attribution.

## Prérequis du VPS

- Linux x64 ou arm64
- Java 25
- Au moins 4 Go de RAM pour le processus (6 Go sur la machine si le système doit aussi tourner)
- Environ 2 Go de disque au départ, plus au fur et à mesure du monde
- Port TCP `25565` ouvert dans le pare-feu du VPS et chez l'hébergeur
- HTTPS sortant vers les serveurs de session Mojang

### Installer Java 25

Ubuntu ou Debian, avec Temurin :

```bash
sudo apt update
sudo apt install -y wget apt-transport-https gpg
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | sudo tee /usr/share/keyrings/adoptium.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt update
sudo apt install -y temurin-25-jre
java -version
```

Sur une distribution récente, `openjdk-25-jre-headless` convient aussi s'il est dans les dépôts.

## Installation

```bash
git clone https://github.com/lucascenseur/minevegas-server.git
cd minevegas-server
./install.sh
./start.sh
```

Le premier démarrage télécharge le serveur vanilla et génère le monde. Attends la ligne `Done` dans la console.

Pour t'ajouter comme opérateur, tape dans cette console, avec le pseudo exact du compte :

```text
op TonPseudo
```

Arrêt propre :

```text
stop
```

## Lancer en service

Adapte `User` et les chemins dans `minevegas.service` si le dossier n'est pas `/opt/minevegas`.

```bash
sudo useradd --system --create-home --home-dir /opt/minevegas --shell /usr/sbin/nologin minecraft
sudo mkdir -p /opt/minevegas
sudo chown minecraft:minecraft /opt/minevegas
sudo -u minecraft git clone https://github.com/lucascenseur/minevegas-server.git /opt/minevegas
sudo -u minecraft /opt/minevegas/install.sh
sudo cp /opt/minevegas/minevegas.service /etc/systemd/system/minevegas.service
sudo systemctl daemon-reload
sudo systemctl enable --now minevegas
```

Suivre les logs :

```bash
journalctl -u minevegas -f
```

`sudo -u minecraft java -version` doit afficher Java 25. Sinon le service ne démarrera pas.

Pare-feu, si `ufw` est actif :

```bash
sudo ufw allow 25565/tcp
```

Ouvre le même port dans le pare-feu du fournisseur (OVH, Hetzner, etc.). Les joueurs se connectent à `IP_DU_VPS`. Le port par défaut `25565` peut être omis dans le client.

## Côté joueur

Le mod est client et serveur. Chaque joueur installe :

1. Minecraft **26.3**
2. [Fabric](https://fabricmc.net/use/installer/) pour 26.3, loader **0.20.1**
3. Les jars présents dans `mods/` après `./install.sh` :
   - `fabric-api-0.165.0+26.3.jar`
   - `minevegas-casino-fabric-26.3-1.0.4.jar`
   - `dungeons-and-taverns-6.0.2-fabric.jar`
   - `DistantHorizons-3.3.4-26.3-fabric-neoforge.jar` (pour voir loin)

Lithium et FerriteCore sont des optimisations serveur : les joueurs n'ont pas besoin de les installer pour se connecter. Distant Horizons peut rester optionnel côté client, mais sans le même jar le rendu distant ne s'affiche pas.

Copie les jars client dans le dossier `mods` du profil Fabric. N'ajoute pas d'anciens mods `casinodeco` ou `casinosound` : MineVegas les remplace et refuse de démarrer avec eux.

[Dungeons and Taverns](https://www.curseforge.com/minecraft/mc-mods/dungeon-and-taverns) ajoute des tavernes et donjons vanilla-like. Les structures n'apparaissent que dans les chunks non explorés. Pour en trouver une : `/locate structure nova_structures:` puis le nom proposé.

Le compte Minecraft doit être officiel. Le pseudo tapé dans `op` est celui du compte.

## Réglages

`server.properties` fixe la survie, la difficulté normale, le PVP, les comptes officiels et le port. Baisse `view-distance` et `simulation-distance` si le VPS manque de CPU.

`pause-when-empty-seconds=60` met le monde en pause après 60 secondes sans joueur. Le serveur se réveille quand quelqu'un se connecte. Mets `0` pour le laisser tourner en permanence.

Le serveur de gestion à distance (`management-server-enabled`) est désactivé, et son secret est laissé vide. Ne le remplis pas dans git.

`server.env` (créé au premier `start.sh` depuis `server.env.example`) contient la RAM. Il n'est pas versionné : un `git pull` ne l'écrase pas.

```bash
MEMORY=4G
```

Puis redémarre le serveur.

## Mettre à jour

```bash
git pull
./install.sh
```

Puis `stop` et relance, ou `sudo systemctl restart minevegas`.

Les versions sont épinglées dans `install.sh`. Un changement de Minecraft, de Fabric ou du mod se fait dans ce script, avec la nouvelle somme SHA1.
