# Docker Container for Logitech Media Server

Docker image for [Logitech Media Server](https://github.com/Logitech/slimserver) (aka SqueezeCenter, SqueezeboxServer, SlimServer).

Runs as non-root user, installs useful dependencies, sets a locale,
exposes ports needed for various plugins and server discovery and
allows editing of config files like `convert.conf`.

Newer versions of Logitech Media Server support updates in place.  To
recreate this container I keep a tag of the latest version build in the
working directory.  To update that:

```
make update
```

To build the image:

```
make build
```

(edit `USER` in `Makefile` if you want).

Run:

```
docker run -d -p 9000:9000 -p 3483:3483 -v <local-state-dir>:/mnt/state -v <audio-dir>:/mnt/music --name logitechmediaserver justifiably/logitechmediaserver
```

or:

```
docker-compose up -d
```

(see `docker-compose.yml` to add volumes)

See Github network for other authors (JingleManSweep, map7, joev000).

Works well with my [MusicIP container](https://hub.docker.com/r/justifiably/musicip/).

