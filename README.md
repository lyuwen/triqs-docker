# TRIQS Docker Image built from source.

A triqs docker image built completely from source which includes [triqs](https://triqs.github.io/triqs)
and the applications [cthyb](https://triqs.github.io/cthyb), [dft_tools](https://triqs.github.io/dft_tools), [maxent](https://triqs.github.io/maxent) and [tprf](https://triqs.github.io/tprf).

It can be used to run a Jupyter notebook environment yourself, or to run a shell for development:


* Jupyter notebook
```
docker run [--name <contailer name>] [-v <host dir>:<container dir>] -p 8888:8888 fulvwen/triqs
```

* Command line
```
docker run [--name <contailer name>] [-v <host dir>:<container dir>] -ti docker/triqs bash
```
