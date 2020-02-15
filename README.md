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
# docker run -it --rm -v $(pwd)/data/shakemap_profiles:/root/shakemap_profiles -v $(pwd)/data/shakemap_data:/root/shakemap_data -v $(pwd)/data/local:/root/.local shakemap4 -p world -c'shake 8863681 select assemble -c "SM4 run" model mapping contour'
```

### Override `entrypoint`:
Enter into the container:
```
$ docker run -it --rm -v $(pwd)/data/shakemap_profiles:/root/shakemap_profiles -v $(pwd)/data/shakemap_data:/root/shakemap_data -v $(pwd)/data/local:/root/.local --entrypoint=bash shakemap4 
```

## Contribute
Please, feel free to contribute.

## Author
(c) 2019 Valentino Lauciani valentino.lauciani[at]ingv.it

Istituto Nazionale di Geofisica e Vulcanologia, Italia
