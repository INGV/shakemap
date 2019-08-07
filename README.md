# ShakeMap4

## Quickstart
### Build docker
```
$ git clone git@gitlab.rm.ingv.it:shakemap/shakemap4.git
$ cd shakemap4
$ docker build --tag shakemap4 .
```

### Run ShakeMap
Run docker container from shakemap4 image:
```
# docker run -it --rm -v $(pwd)/data/shakemap_profiles:/root/shakemap_profiles -v $(pwd)/data/shakemap_data:/root/shakemap_data -v $(pwd)/data/local:/root/.local shakemap4 -p world -c'shake 2886368 select assemble -c "SM4 run" model mapping contour'
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
