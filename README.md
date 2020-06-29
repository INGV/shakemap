[![pipeline status](https://gitlab.rm.ingv.it/shakemap/shakemap4/badges/master/pipeline.svg)](https://gitlab.rm.ingv.it/shakemap/shakemap4/commits/master)

# ShakeMap4

## Quickstart
### Build docker image
**NOTE**: If you set daemon configuration in `/etc/docker/daemon.json` with `{ "features": { "buildkit": true } }`, the `DOCKER_BUILDKIT=1` could be omitted.
```
$ git clone https://gitlab.rm.ingv.it/shakemap/shakemap4.git
$ cd shakemap4
$ DOCKER_BUILDKIT=1 docker build --no-cache --build-arg ENV_UID=$(id -u) --build-arg ENV_GID=$(id -g) --tag shakemap4 .
```

### Run ShakeMap
Run docker container from shakemap4 image:
```
# docker run --rm -v $(pwd)/data/shakemap_profiles:/home/shake/shakemap_profiles -v $(pwd)/data/shakemap_data:/home/shake/shakemap_data -v $(pwd)/data/local:/home/shake/.local shakemap4 -p world -c"shake 8863681 select assemble -c \"SM4 run\" model contour shape info stations raster rupture gridxml history plotregr mapping"
```

### Override `entrypoint`:
Enter into the container:
```
$ docker run -it --rm -v $(pwd)/data/shakemap_profiles:/home/shake/shakemap_profiles -v $(pwd)/data/shakemap_data:/home/shake/shakemap_data -v $(pwd)/data/local:/home/shake/.local --entrypoint=bash shakemap4 
```

## Mini-HowTo
Piccola guida per interaggire con il docker
```
$ ssh shake@shakemap4.int.ingv.it
```

andare nella directory dove sono presenti le directory da montare, come "volumi", nel *container*:
```
$
$ cd /home/shake/gitwork/_shakemap/shakemap4
shake@shakemap4:~/gitwork/_shakemap/shakemap4$
```

i "volumi" sono:
- `$(pwd)/data/shakemap_profiles`
- `$(pwd)/data/shakemap_data`
- `$(pwd)/data/local`

creare un container dall'immagine Docker *shakemap4* montando all'interno i volumi necessari:
```
shake@shakemap4:~/gitwork/_shakemap/shakemap4$ docker run -it --rm -v $(pwd)/data/shakemap_profiles:/home/shake/shakemap_profiles -v $(pwd)/data/shakemap_data:/home/shake/shakemap_data -v $(pwd)/data/local:/home/shake/.local --entrypoint=bash shakemap4
(shakemap) root@d0263fbd02ae:/opt#
```

i volumi, all'interno del *container* ora sono nelle seguenti dir:
- `/home/shake/shakemap_profiles`
- `/home/shake/shakemap_data`
- `/home/shake/.local`

lanciare una shakemap:
```
(shakemap) root@d0263fbd02ae:/opt# shake 8863681 select assemble -c "SM4 run" model contour shape info stations raster rupture gridxml history plotregr mapping
```

## Contribute
Please, feel free to contribute.

## Author
(c) 2019 Valentino Lauciani valentino.lauciani[at]ingv.it

Istituto Nazionale di Geofisica e Vulcanologia, Italia
