## Insurgency: Sandstorm Docker Container
[![Docker Image CI](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/actions/workflows/docker-image.yml/badge.svg)](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/actions/workflows/docker-image.yml)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/andrewmhub/insurgency-sandstorm/lite?label=image%20size%20lite&logo=docker)](https://hub.docker.com/r/andrewmhub/insurgency-sandstorm)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/andrewmhub/insurgency-sandstorm/latest?label=image%20size%20latest&logo=docker)](https://hub.docker.com/r/andrewmhub/insurgency-sandstorm)
[![Docker Pulls](https://img.shields.io/docker/pulls/andrewmhub/insurgency-sandstorm?color=red&logo=docker)](https://hub.docker.com/r/andrewmhub/insurgency-sandstorm)

<p align="center">
  <img src="https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/blob/master/sandstorm-logo.png">
  <img src="https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/blob/master/docker-logo.png"
</p>
</p>

<details>
  <summary>Changelog</summary>

```
Feb, 2022
some fixes in modmap.env
mod.io token moved from Engine.ini to GameUserSettings.ini (because NWI)
fixed steam warning in dockerfile "Please use force_install_dir before logon!"
changed readme
changed ENTRYPOINT now you can use LAUNCH_SERVER_ENV to set map
new options on ini files
Nov, 2022
added lite version, because it's become so beefy
Sep, 2026
mod.io login for game update 1.20+ (see "Mods (mod.io)"), new modio helper, docker-compose.yml
old AccessToken and Insurgency/Mods volume are not used any more
```
</details>

This repository contains a docker image with a dedicated server for Insurgency Sandstorm that you can fully customize to your need for COOP and PVP servers.

This image will be built any time there are updates to the steam app or upstream docker image, so you don’t have to update anything inside a container. I tried to build the image as “best-practice” as possible and to document everything for you.
#### Official documentation: [Sandstorm Server Admin Guide](https://sandstorm-support.newworldinteractive.com/hc/en-us/articles/360049211072-Server-Admin-Guide)
#### Another Server Admin Guide [Server Admin Guide by mod.io](https://mod.io/g/insurgencysandstorm/r/server-admin-guide)
#### Mods guide: [How to Set Up a Steam Dedicated Server with Mods](https://mod.io/g/insurgencysandstorm/r/how-to-set-up-a-steam-dedicated-server-with-mods)
#### More config examples: [Configs by zWolfi](https://github.com/zWolfi/INS_Sandstorm)
#### ISMC Guide: [ISMCmod Installation Guide](https://mod.io/g/insurgencysandstorm/r/ismcmod-installation-guide)

## How to build/get Insurgency Sandstorm dedicated server
cd directory where ```Dockerfile```
```docker build -t andrewmhub/insurgency-sandstorm:latest .``` or get it on [docker hub](https://hub.docker.com/r/andrewmhub/insurgency-sandstorm) ```docker pull andrewmhub/insurgency-sandstorm```
## How to launch Insurgency Sandstorm dedicated server
Running multiple instances (use PORT, QUERYPORT and HOSTNAME) and LAUNCH_SERVER_ENV in [modmap.env](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/blob/master/modmap.env). For mods, get the seccomp profile first (see [Mods (mod.io)](#mods-modio)):
```
wget -O /home/user/coop-modmap/seccomp-modio.json https://raw.githubusercontent.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/master/seccomp-modio.json
```
```
docker run -d --restart unless-stopped --env-file /home/user/coop-modmap/modmap.env \
--name sandstorm-modmap --net=host \
--security-opt seccomp=/home/user/coop-modmap/seccomp-modio.json \
-v sandstorm-modmap-modio:/home/steam/mod.io \
-v /home/user/coop-modmap/config/ini:/home/steam/steamcmd/sandstorm/Insurgency/Saved/Config/LinuxServer:ro \
-v /home/user/coop-modmap/config/txt:/home/steam/steamcmd/sandstorm/Insurgency/Config/Server:ro andrewmhub/insurgency-sandstorm:latest
```
#### Lite version

All game data will be stored on disk
```
docker run -d --restart unless-stopped --env-file /home/user/coop-modmap/modmap.env \
--name sandstorm-modmap --net=host \
--security-opt seccomp=/home/user/coop-modmap/seccomp-modio.json \
-v /home/user/my_dir:/home/steam/steamcmd/sandstorm:rw \
-v sandstorm-modmap-modio:/home/steam/mod.io \
 andrewmhub/insurgency-sandstorm:lite
```
Each server needs its own `mod.io` volume (`sandstorm-modmap-modio` above): it keeps the mod.io login and the downloaded mods.

Examples config files in directory [config](https://github.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/tree/master/config)

Optional launch options:

```-NoEAC``` have problem with EAC just disables it

```-nominidumps``` some crash dump handler that uploads crash information to insurgency devs servers this option disables it 

### docker compose
[docker-compose.yml](docker-compose.yml) needs these files in the same folder: `modmap.env`, `config/` and **`seccomp-modio.json`**. The seccomp file is **not** inside the image, Docker reads it from your disk. Clone this repo, or if you only pull the image, download both files:
```
wget https://raw.githubusercontent.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/master/docker-compose.yml
wget https://raw.githubusercontent.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/master/seccomp-modio.json
```
Edit [modmap.env](modmap.env) and the files in [config](config), then:
```
docker compose up -d
docker compose logs -f
```
The compose file mounts `config/` read-only, keeps the mod.io login in a named volume and applies `seccomp-modio.json`.
### modmap.env example

```.env
HOSTNAME=[ISMC] MOD MAPS ONLY @120hz
PORT=12345
QUERYPORT=54321
MODIO_EMAIL=my-email@example.com
LAUNCH_SERVER_ENV=Ministry?Scenario=Scenario_Ministry_Checkpoint_Security?Game=CheckpointHardcore?password=MyPa$$word?MaxPlayers=10 -MapCycle=MapCycle -Mods -ModList=Mods.txt -mutators="ISMCarmory_legacy,ImprovedAI,NoRestrictedArea,ScaleBotAmount,AdvancedSupplyPoints,WelcomeMessage,JoinLeaveMessage,FpLegs,JumpShoot" -GameStatsToken=my_token -GameStats -GSLTToken=my_token -ModDownloadTravelTo=TORO?Scenario=Scenario_TORO_Checkpoint_Security
```

## Mods (mod.io)
Since game update 1.20 (Feb 2026) the server logs in to mod.io with a one-time code sent by email. The old `AccessToken` in `GameUserSettings.ini` does nothing now. The container does the login for you:

1. Make a mod.io account for the server on [mod.io](https://mod.io) with an email that is **not** the one you play with (don't sign in with Steam).
2. Put `MODIO_EMAIL=that-email@example.com` in `modmap.env` and your mod IDs in `Mods.txt`, one per line (text after the ID is ignored). Keep `-ModDownloadTravelTo=<map>?Scenario=<scenario>` in `LAUNCH_SERVER_ENV`: the server starts on a stock map, downloads the mods, then travels there. Without it, mutators on the first map show as `invalid`.
3. **Download `seccomp-modio.json` to your server.** It is not inside the image, Docker reads it from your disk. Without it mods do not work (why: see below).
   ```
   wget https://raw.githubusercontent.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/master/seccomp-modio.json
   ```
4. Start the container with `--security-opt seccomp=/path/to/seccomp-modio.json`. `docker-compose.yml` already has this line and expects the file next to itself. The container emails a code and waits:
   ```
   mod.io: waiting for the security code emailed to that@email. Send it with:
   mod.io:   docker exec <container> modio code <CODE>
   ```
5. Run that command with the code. The server logs in, subscribes its mod.io account to the mods in `Mods.txt` and starts.

That's all. Restarts and image updates need nothing more as long as `/home/steam/mod.io` is a volume. When the login expires (about once a year) the container asks for a new code the same way.

`Mods.txt` is the list of mods: on every start the server's mod.io account is subscribed to exactly those mods and unsubscribed from the rest. Leave it without IDs if you'd rather pick mods on the mod.io website while logged in as the server account.

| `docker exec <container> ...` | What it does |
|---|---|
| `modio code <CODE>` | give the server the code from the email |
| `-it ... modio login` | asks for the email, sends a code, asks for the code. Use it when `MODIO_EMAIL` is not set or the code expired |
| `modio status` | which mod.io account the server uses |
| `modio sync --dry-run` | what the next start would subscribe and unsubscribe |
| `modio reset` | log out, the next start asks for a new code |

- No `docker exec` on your host (game panels)? Set `MODIO_SECURITY_CODE=<code>` instead and restart.
- Already have your own `-SecurityCode=...` in `LAUNCH_SERVER_ENV`? Then the container leaves mod.io alone.
- **Why the seccomp profile:** the game's mod.io SDK reads and writes files with `io_uring`, and Docker 25+ blocks `io_uring` in its default seccomp profile. [seccomp-modio.json](seccomp-modio.json) is Docker's default profile (`moby/profiles/seccomp` v0.2.3, shipped with Docker 29.8.1) plus one rule allowing `io_uring_setup`, `io_uring_enter` and `io_uring_register`. Everything else stays blocked. Avoid `seccomp=unconfined`: it turns the whole filter off.
- **Several servers:** give each one its own mod.io account and its own `mod.io` volume. Servers sharing an account would keep unsubscribing each other's mods.
- **Coming from the old setup:** delete `AccessToken=...` from `GameUserSettings.ini`, drop the `Insurgency/Mods` volume, add a `mod.io` volume, set `MODIO_EMAIL`.

Troubleshooting:
- `opening seccomp profile (./seccomp-modio.json) failed: ... no such file or directory`: the file is missing on your disk. Download it (step 3) next to `docker-compose.yml`, or fix the path in `--security-opt`.
- `Insufficient permission for filesystem operation` in the log: the container runs without `seccomp-modio.json`. Recreate it with the profile.
- `the code was rejected or expired`: codes are single use. Get a new one with `docker exec -it <container> modio login`.
- `is not writable`: a host folder mounted at `/home/steam/mod.io` must belong to uid 1001, or use a named volume like the examples.
- Mods don't download: check `modio status` and `modio sync --dry-run`, make sure the account is not the one you play with, then `modio reset` and restart.

## Server auto update
Autoupdate game server. This script will keep your game servers automaticly updated updating intervals announce the server is shutting down for updates

Requirements: [rcon-cli](https://github.com/gorcon/rcon-cli/releases)
```
wget https://github.com/gorcon/rcon-cli/releases/download/v0.10.1/rcon-0.10.1-amd64_linux.tar.gz
tar -xvzf rcon-0.10.1-amd64_linux.tar.gz
cp rcon-0.10.1-amd64_linux/rcon /usr/local/bin/
```

Get restart script example

```
wget --no-check-certificate -O /opt/restart-ins.sh https://raw.githubusercontent.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/master/AutoUpdater/restart-ins.sh
chmod +x /opt/restart-ins.sh
```
The next script make version comparison
if game server version changed in steam or ISMC mod version you insurgency sandstorm server will automatically restarted and get update

```
wget --no-check-certificate -O /opt/check-manifest.sh https://raw.githubusercontent.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/master/AutoUpdater/check-manifest.sh
chmod +x /opt/check-manifest.sh
```
Get systemd unit daemon
```
wget --no-check-certificate -O /etc/systemd/system/my-server-check.service https://raw.githubusercontent.com/AndrewMarchukov/insurgency-sandstorm-server-dockerize/master/AutoUpdater/my-server-check.service
systemctl daemon-reload
systemctl enable my-server-check.service
systemctl start my-server-check.service
```
## Tips and Tricks
### How to save RAM on UE4 Linux(Docker) dedicated server

if you launch multiple servers on same host you can save some memory, on 2 game servers more than 1gb memory saved.

Make sure that parameter set on 1 after host reboot

```echo 1 > /sys/kernel/mm/ksm/run```

and add launch options ```-useksm -ksmmergeall``` then restart servers

wait some amount of time and check statistics ```grep -H '' /sys/kernel/mm/ksm/*```

```pages_shared``` - how many shared pages are being used

```pages_sharing``` - how many more sites are sharing them i.e. how much saved

```pages_unshared``` - how many pages unique but repeatedly checked for merging

```pages_sharing*4096/1024/1024=how much memory saved```

So, in your example, 264281 pages have been found to be shareable. KSM saved you about 1032 MB of memory.
