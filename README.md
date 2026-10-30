# Serveur MineVegas Casino

Serveur Minecraft **26.3** avec [MineVegas Casino](https://www.curseforge.com/minecraft/mc-mods/minevegas-casino) (blackjack, roulette, machines à sous, Derby des canards, roue de la fortune, Plinko).

| Réglage | Valeur |
| --- | --- |
| Version | Minecraft 26.3 |
| Chargeur | Fabric Loader 0.20.1 |
| Dépendance | Fabric API 0.165.0+26.3 |
| Mods | MineVegas, DnT, Lithium, FerriteCore, Distant Horizons, Jade, AppleSkin, Xaero's Minimap, Traveler's Backpack, Graves (lullaby), Tom's Simple Storage, Storage Drawers |
| Java | 25 ou plus récent |
| Monde | Survie, difficulté normale, PVP activé |
| Comptes | Officiels uniquement (`online-mode=true`) |
| Port | TCP `25565` |
| Joueurs | 20 |
| RAM | 4 Go (`server.env`) |
| Icône | `server-icon.png` (64×64) |
| MOTD | `motd.txt` (couleurs Minecraft) |

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
   - `DistantHorizons-3.3.4-26.3-fabric-neoforge.jar`
   - `Jade-mc26.3-Fabric-26.3.5.jar`
   - `appleskin-fabric-mc26.3-3.0.10.jar`
   - `xaerominimap-fabric-26.3-26.6.2.jar`
   - `ForgeConfigAPIPort-v26.3.1-mc26.3.x-Fabric.jar`
   - `travelersbackpack-fabric-26.3-11.4.2.jar`
   - `toms_storage_fabric-26.3-2.12.2.jar`
   - `StorageDrawers-fabric-26.3.0.1.jar`

Lithium, FerriteCore et Graves (lullaby) sont surtout serveur : les joueurs n'en ont pas besoin pour se connecter. Jade, AppleSkin, Xaero's Minimap et Distant Horizons s'installent surtout côté client ; sans eux tu te connectes, mais tu perds l'info-bulle, la faim détaillée, la minimap ou le rendu distant. Traveler's Backpack, Forge Config API Port, Tom's Simple Storage et Storage Drawers sont obligatoires côté client et serveur.

### Tri d'inventaire (client uniquement, optionnel)

[Inventory Profiles Next](https://modrinth.com/mod/inventory-profiles-next) trie l'inventaire et les coffres d'un clic. Il ne tourne que côté client et n'est pas installé sur le serveur. Chaque joueur qui le veut ajoute ces trois jars dans son dossier `mods` :

- [InventoryProfilesNext-fabric-26.3-2.3.8.jar](https://cdn.modrinth.com/data/O7RBXm3n/versions/y8vT21Sb/InventoryProfilesNext-fabric-26.3-2.3.8.jar)
- [libIPN-fabric-26.3-6.9.0.jar](https://cdn.modrinth.com/data/onSQdWhM/versions/aKBFonyQ/libIPN-fabric-26.3-6.9.0.jar)
- [fabric-language-kotlin-1.14.2+kotlin.2.4.21.jar](https://cdn.modrinth.com/data/Ha28R6CL/versions/SKW1BTL3/fabric-language-kotlin-1.14.2%2Bkotlin.2.4.21.jar)

### Stockage

[Tom's Simple Storage](https://modrinth.com/mod/toms-storage) relie des coffres et tonneaux vanilla à un terminal : place un **Inventory Connector** contre les coffres (ou relie-les avec des **Inventory Cables**), puis un **Storage Terminal** ou un **Crafting Terminal** sur le connecteur. Tout le contenu s'affiche et se cherche depuis le terminal.

[Storage Drawers](https://modrinth.com/mod/storagedrawers) ajoute des tiroirs qui stockent une grande quantité d'un même objet. Un **Drawer Controller** regroupe les tiroirs voisins, et un Inventory Connector de Tom's Simple Storage posé contre ce contrôleur devrait voir leur contenu (à vérifier en jeu).

Copie les jars client dans le dossier `mods` du profil Fabric. N'ajoute pas d'anciens mods `casinodeco` ou `casinosound` : MineVegas les remplace et refuse de démarrer avec eux.

[Dungeons and Taverns](https://www.curseforge.com/minecraft/mc-mods/dungeon-and-taverns) ajoute des tavernes et donjons vanilla-like. Les structures n'apparaissent que dans les chunks non explorés. Pour en trouver une : `/locate structure nova_structures:` puis le nom proposé.

Le compte Minecraft doit être officiel. Le pseudo tapé dans `op` est celui du compte.

## Réglages

`server.properties` fixe la survie, la difficulté normale, le PVP, les comptes officiels et le port. `view-distance` est à 16 et `simulation-distance` à 12. Monte jusqu'à 32 si le VPS suit, ou baisse si le CPU / la RAM saturent.

`pause-when-empty-seconds=60` met le monde en pause après 60 secondes sans joueur. Le serveur se réveille quand quelqu'un se connecte. Mets `0` pour le laisser tourner en permanence.

Le serveur de gestion à distance (`management-server-enabled`) est désactivé, et son secret est laissé vide. Ne le remplis pas dans git.

`server.env` (créé au premier `start.sh` depuis `server.env.example`) contient la RAM. Il n'est pas versionné : un `git pull` ne l'écrase pas.

`motd.txt` définit le message de la liste des serveurs (deux lignes, codes `§`). `start.sh` le recopie dans `server.properties` à chaque démarrage. `server-icon.png` doit faire exactement 64×64 pixels.

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
