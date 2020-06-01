[![pipeline status](https://gitlab.rm.ingv.it/shakemap/shakemap4/badges/master/pipeline.svg)](https://gitlab.rm.ingv.it/shakemap/shakemap4/commits/master)

# ShakeMap4

## Quickstart
### Get repository
```
$ git clone git@gitlab.rm.ingv.it:shakemap/shakemap4.git
```

### Build image
```
$ cd shakemap4
$ DOCKER_BUILDKIT=1 docker build --no-cache --tag shakemap4 .
```
or with tag:
```
$ DOCKER_BUILDKIT=1 docker build --no-cache --tag shakemap4:20200211 .
```

**NOTE**: If you set daemon configuration in `/etc/docker/daemon.json` with `{ "features": { "buildkit": true } }`, the `DOCKER_BUILDKIT=1` could be omitted.

### Run ShakeMap
Run docker container from shakemap4 image:
```
# docker run --rm -v $(pwd)/data/shakemap_profiles:/root/shakemap_profiles -v $(pwd)/data/shakemap_data:/root/shakemap_data -v $(pwd)/data/local:/root/.local shakemap4:20200530 -p world -c"shake 8863681 select assemble -c \"SM4 run\" model contour shape save info stations raster rupture gridxml history plotregr mapping"
```

### Override `entrypoint`:
Enter into the container:
```
$ docker run -it --rm -v $(pwd)/data/shakemap_profiles:/root/shakemap_profiles -v $(pwd)/data/shakemap_data:/root/shakemap_data -v $(pwd)/data/local:/root/.local --entrypoint=bash shakemap4 
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

creare un container dell'immagine Docker *shakemap4:20200530* montando all'interno i volumi necessari:
```
shake@shakemap4:~/gitwork/_shakemap/shakemap4$ docker run -it --rm -v $(pwd)/data/shakemap_profiles:/root/shakemap_profiles -v $(pwd)/data/shakemap_data:/root/shakemap_data -v $(pwd)/data/local:/root/.local --entrypoint=bash shakemap4:20200530
(shakemap) root@d0263fbd02ae:/opt#
```

i volumi, all'interno del *container* ora sono nelle seguenti dir:
- `/root/shakemap_profiles`
- `/root/shakemap_data`
- `/root/.local`

lanciare una shakemap:
```
(shakemap) root@d0263fbd02ae:/opt# shake 8863681 select assemble -c "SM4 run" model contour shape save info stations raster rupture gridxml history plotregr mapping
```

## Contribute
Please, feel free to contribute.

## Author
(c) 2019 Valentino Lauciani valentino.lauciani[at]ingv.it

Istituto Nazionale di Geofisica e Vulcanologia, Italia
