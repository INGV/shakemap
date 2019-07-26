# ShakeMap4

## Quickstart
### Build docker
```
$ git clone git@gitlab.rm.ingv.it:shakemap/shakemap4.git
$ cd shakemap4
$ docker build --tag shakemap4 .
```

### Run docker container
Run docker container from shakemap4 image:
```
$ docker run -it --rm shakemap4 bash
```

### Run ShakeMap
```
$ docker run -it --rm -v $(pwd)/data/shakemap_profiles:/root/shakemap_profiles -v $(pwd)/data/shakemap_data:/root/shakemap_data shakemap4 bash
#
# conda activate shakemap
(shakemap) #:/opt/gitwork/shakemap_src#
(shakemap) #:/opt/gitwork/shakemap_src# sm_profile -c world -n -a
```

run:
```
# shake 8863681 select assemble -c "test" model mapping
```

## Contribute
Please, feel free to contribute.

## Author
(c) 2019 Valentino Lauciani valentino.lauciani[at]ingv.it

Istituto Nazionale di Geofisica e Vulcanologia, Italia
