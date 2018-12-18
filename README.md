# insurgency: sandstorm server dockerize
## How to build
cd directory where ```Dockerfile```
```
docker build -t sandstorm:latest .
```
## How to launch
Running multiple instances (use PORT, QUERYPORT and HOSTNAME) if need other(custom) settings file use --volume:
```
docker run -d --net=host -e HOSTNAME="MY SERVER" -e PORT=1111 -e QUERYPORT=2222 \
--name=sandstorm-dedicated \
--volume mydirectory/ini/Engine.ini:/home/steam/steamcmd/sandstorm/Insurgency/Saved/Config/LinuxServer/Engine.ini:ro \
sandstorm:latest
```

examples config files see directory ```config```

Official documentation: [Server Admin Guide](https://docs.google.com/document/d/1GDLg5p9jjeIya7EgBk0ibzDtDlyQ-U_jpspOzby-JmM)
