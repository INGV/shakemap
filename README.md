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
Enter into the container :
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
$ shake@shakemap4:~/gitwork/_shakemap/shakemap4
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

## Creare nuovi moduli IPE o GMPE
Istruzioni per creare o modificare moduli di OpenQuake per ShakeMap

```
$ ssh shake@shakemap4.int.ingv.it
```

vai nella directory dove sono presenti le directory da montare, come "volumi", nel *container*:
```
$
$ cd /home/shake/gitwork/_shakemap/shakemap4
shake@shakemap4:~/gitwork/_shakemap/shakemap4$
```

Entra dentro il docker con questo comando

```
docker run -it --rm -v $(pwd)/data/shakemap_profiles:/home/shake/shakemap_profiles -v $(pwd)/data/shakemap_data:/home/shake/shakemap_data -v $(pwd)/data/local:/home/shake/.local --entrypoint=bash shakemap4:4.1.4
```

—> attento alla **versione di ShakeMap** da usare (qui per semepio c'è la vesrione **shakemap4:4.1.4**)

Poi lancia i comandi:
```
(shakemap) shake@8e89e2d3b427:~$ conda activate base
(shakemap) shake@8e89e2d3b427:~$ conda activate shakemap
(shakemap) shake@8e89e2d3b427:~$ sm_profile -s world
```

I file relativi a IPE e GMPE sono qui:
```
/miniconda/envs/shakemap/lib/python3.8/site-packages/openquake/hazardlib/gsim
```

Copia i file sempre della dir *shakemap_profile/world* .

I file qui non vengono persi quando entri nel *container*

```
(shakemap) shake@8e89e2d3b427:~$ cd /miniconda/envs/shakemap/lib/python3.8/site-packages/openquake/hazardlib/gsim
(shakemap) shake@8e89e2d3b427:~$ cp *ipe.py ../../../../../../../../../shakemap_profiles/world/.
```

Da qui li puoi portare nel tuo computer per lavorarci.

Una volta che sei soddisfatto delle modifiche li metti dentro *shakemap4-dev* della dir */home/shake/gitwork/_shakemap/shakemap4/data/shakemap_profiles/world*
``` 
shake@shakemap4-dev:~/gitwork/_shakemap/shakemap4 (master)*$ 
shake@shakemap4-dev:~/gitwork/_shakemap/shakemap4 (master)*$ cd /home/shake/gitwork/_shakemap/shakemap4/data/shakemap_profiles/world
```

I file che sono qui dentro vengono sempre salvati anche se chiudi il *container* o ne apri un altro.

A questo punto devi riportare il file modificato dentro il *container* (quello di prima se è ancora aperto o ne apri un altro) all'intreno della dir:
```
/miniconda/envs/shakemap/lib/python3.8/site-packages/openquake/hazardlib/gsim
```

Fai un po' di prove per vedere se il modulo lavora correttamente, lanciano il comando standard di ShakeMap quando si è dentro al *container*, tipo questo
```
shake EVENT-ID select assemble -c "SM4 run" model contour shape info stations raster rupture gridxml history plotregr mapping
```

Quando sei soddisfatto del modulo lo metti qui:

- `https://gitlab.rm.ingv.it/shakemap/shakemap4/-/tree/master/ext`

a seguito della modifica, partirà la *build* e i *test* in automatico e li potrai seguire qui:
- `https://gitlab.rm.ingv.it/shakemap/shakemap4/-/pipelines`


Se è già predisposta una modifica del pacchetto per i moduli che hai modificato allinterno del Dorkerfile, tutto verrà integrato in automatico.  

Se invece non è presente alcuna modifica dentro il dokerfile bisogna modificarlo.

## Creare o modificare una GMICE

La procedura è simile a quello fatto per la IPE solo che la GMICE vanno qui:
```
/home/shake/gitwork/shakemap_src/shakelib/gmice
```

## Istruzioni per far girare una shakemap con il docker:

Entrare in shakemap4-dev: 
```
ssh shake@shakemap4-dev.int.ingv.it
```
Andare nella dir di shakemap: 
```
shake@shakemap4-dev:~ $ cd gitwork/_shakemap/shakemap4
shake@shakemap4-dev:~/gitwork/_shakemap/shakemap4 (master)*$ pwd
/home/shake/gitwork/_shakemap/shakemap4
```
I comandi vanno sempre lanciati da questa dir.

Per capire quale sia l’immagine docker lanciare il comando 
```
docker image ls
```

Questo ti fornisce tutti le immagini che ci sono, il TAG ci restituisce in nome della reale da usare. 

Per esempio ora si usa la 4.1.4

Per lancio della shakemap usare il comando:
```
docker run --rm -v $(pwd)/data/shakemap_profiles:/home/shake/shakemap_profiles -v $(pwd)/data/shakemap_data:/home/shake/shakemap_data -v $(pwd)/data/local:/home/shake/.local shakemap4:4.1.4  -p world -c"shake EVENT-ID select assemble -c \"SM4 run\" model contour shape info stations raster rupture gridxml history plotregr mapping”
```

**—> attento alla versione di ShakeMap da usare.**

Creazione degli event-id: 
gli eventi vanno messi qui 
```
/home/shake/gitwork/_shakemap/shakemap4/data/shakemap_profiles/world/data
```

## Istruzioni per far girare una shakemap con dentro il docker:

Entrare in shakemap4-dev: 
```
ssh shake@shakemap4-dev.int.ingv.it
```

Andare nella dir di shakemap: 
```
shake@shakemap4-dev:~ $ cd gitwork/_shakemap/shakemap4
shake@shakemap4-dev:~/gitwork/_shakemap/shakemap4 (master)*$ pwd
/home/shake/gitwork/_shakemap/shakemap4
```

A questo punto usa i comandi:

```
docker run -it --rm -v $(pwd)/data/shakemap_profiles:/home/shake/shakemap_profiles -v $(pwd)/data/shakemap_data:/home/shake/shakemap_data -v $(pwd)/data/local:/home/shake/.local --entrypoint=bash shakemap4:4.1.4
```
**—> attento alla versione di ShakeMap da usare.**

```
(shakemap) shake@8e89e2d3b427:~$ conda activate base
(shakemap) shake@8e89e2d3b427:~$ conda activate shakemap
(shakemap) shake@8e89e2d3b427:~$sm_profile -s world
```
Da qui poi lanciare una mappa nel modo classico, ad esempio:
```
shake EVENT-ID select assemble -c "SM4 run" model contour shape info stations raster rupture gridxml history plotregr mappin
```

## Contribute
Please, feel free to contribute..

## Author
(c) 2019 Valentino Lauciani valentino.lauciani[at]ingv.it and Licia Faenza licia.faenza[at]ingv.it

Istituto Nazionale di Geofisica e Vulcanologia, Italia
