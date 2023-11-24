# FROM ubuntu:latest
FROM ghcr.io/lyuwen/mpich-ucx:main

RUN sed -i -e 's/archive.ubuntu.com/mirrors.ustc.edu.cn/' -e 's/security.ubuntu.com/mirrors.ustc.edu.cn/' /etc/apt/sources.list

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      make cmake g++-12 gfortran git hdf5-tools \
      clang libclang-dev python3-clang \
      libblas-dev libboost-dev libfftw3-dev libgfortran5 \
      libgmp-dev libhdf5-dev liblapack-dev \
      python3-dev python3-mako python3-matplotlib \
      python3-numpy python3-scipy \
      curl \
      libboost-all-dev \
      libnfft3-dev \
      openssh-client \
      python3-h5py \
      python3-pip \
      python3-setuptools \
      sudo \
      libucx-dev ucx-utils \
      && \
    apt-get autoremove --purge -y && \
    apt-get autoclean -y && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/*


ENV MPICC=mpicc
RUN pip install --no-cache-dir jupyter mpi4py 'jupyter-client>8.5.0'

ENV CXX=g++-12
ENV CC=gcc-12
ENV INSTALL_PREFIX=/opt/triqs

RUN mkdir -p $INSTALL_PREFIX

WORKDIR /tmp

ENV CPATH=/usr/include/hdf5/serial:$CPATH
ENV TRIQS_ROOT=/opt/triqs
ENV CPLUS_INCLUDE_PATH=/opt/triqs/include:$CPLUS_INCLUDE_PATH
ENV PATH=/opt/triqs/bin:$PATH
ENV LIBRARY_PATH=/opt/triqs/lib:$LIBRARY_PATH 
ENV LD_LIBRARY_PATH=/opt/triqs/lib:$LD_LIBRARY_PATH 
ENV PYTHONPATH=/opt/triqs/lib/python3.10/site-packages:$PYTHONPATH
ENV CMAKE_PREFIX_PATH=/opt/triqs/lib/cmake/triqs:/opt/triqs/lib/cmake/cpp2py:$CMAKE_PREFIX_PATH

RUN git clone https://github.com/TRIQS/triqs triqs.src && \
    mkdir -p triqs.build && cd triqs.build && \
    cmake ../triqs.src -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX && \
    make  && make install && \
    rm -rf /tmp/triqs.src /tmp/triqs.build

RUN git clone https://github.com/TRIQS/dft_tools dft_tools.src && \
    mkdir -p dft_tools.build && cd dft_tools.build && \
    cmake ../dft_tools.src -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX && \
    make  && make install && \
    rm -rf /tmp/dft_tools.src /tmp/dft_tools.build

RUN git clone https://github.com/TRIQS/cthyb cthyb.src && \
    mkdir -p cthyb.build && cd cthyb.build && \
    cmake ../cthyb.src -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX && \
    make  && make install && \
    rm -rf /tmp/cthyb.src /tmp/cthyb.build

RUN git clone https://github.com/TRIQS/maxent maxent.src && \
    mkdir -p maxent.build && cd maxent.build && \
    cmake ../maxent.src -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX && \
    make  && make install && \
    rm -rf /tmp/maxent.src /tmp/maxent.build

RUN git clone https://github.com/TRIQS/tprf tprf.src && \
    mkdir -p tprf.build && cd tprf.build && \
    cmake ../tprf.src -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX && \
    make  && make install && \
    rm -rf /tmp/tprf.src /tmp/tprf.build

ARG NB_USER=triqs
ARG NB_UID=1000
RUN useradd -u $NB_UID -m $NB_USER && \
    echo 'triqs ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER $NB_USER
WORKDIR /home/$NB_USER

RUN curl -L https://api.github.com/repos/TRIQS/tutorials/tarball/unstable | tar xzf - --one-top-level=tutorials --strip-components=1
WORKDIR /home/$NB_USER

EXPOSE 8888
CMD ["jupyter","notebook","--ip","0.0.0.0"]
