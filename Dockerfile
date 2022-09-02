FROM ubuntu:bionic

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      cmake \
      curl \
      gfortran \
      git \
      hdf5-tools \
      libblas-dev \
      libboost-all-dev \
      libfftw3-dev \
      libgfortran5 \
      libgmp-dev \
      libhdf5-dev \
      liblapack-dev \
      libnfft3-dev \
      libopenmpi-dev \
      openssh-client \
      python-backports-shutil-get-terminal-size \
      python-configparser \
      python-dev \
      python-h5py \
      python-mako \
      python-matplotlib \
      python-mpi4py \
      python-numpy \
      python-pip \
      python-scipy \
      python-setuptools \
      python-tk \
      sudo \
      clang-14 \
      clang-format-14 \
      libclang-14-dev \
      python-clang-14 \
      libomp-14-dev \
      && \
    apt-get autoremove --purge -y && \
    apt-get autoclean -y && \
    rm -rf /var/cache/apt/* /var/lib/apt/lists/*

RUN pip install --no-cache-dir jupyter

# clang compliers
ENV CC=clang-14
ENV OMPI_CC=$CC
ENV CXX=clang++-14
ENV OMPI_CXX=$CXX

ENV INSTALL_PREFIX=/opt/triqs

RUN mkdir -p $INSTALL_PREFIX

WORKDIR /tmp

ENV CPATH=/usr/include/openmpi:/usr/include/hdf5/serial:$CPATH
ENV TRIQS_ROOT=/opt/triqs
ENV CPLUS_INCLUDE_PATH=/opt/triqs/include:$CPLUS_INCLUDE_PATH
ENV PATH=/opt/triqs/bin:$PATH
ENV LIBRARY_PATH=/opt/triqs/lib:/usr/lib/llvm-14/lib:$LIBRARY_PATH
ENV LD_LIBRARY_PATH=/opt/triqs/lib:$LD_LIBRARY_PATH 
ENV PYTHONPATH=/opt/triqs/lib/python2.7/site-packages:$PYTHONPATH
ENV CMAKE_PREFIX_PATH=/opt/triqs/lib/cmake/triqs:/opt/triqs/lib/cmake/cpp2py:$CMAKE_PREFIX_PATH

RUN git clone https://github.com/TRIQS/triqs triqs.src && \
    mkdir -p triqs.build && cd triqs.build && \
    cmake ../triqs.src -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX && \
    make  && make install

RUN git clone https://github.com/TRIQS/dft_tools dft_tools.src && \
    mkdir -p dft_tools.build && cd dft_tools.build && \
    cmake ../dft_tools.src -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX && \
    make  && make install

RUN git clone https://github.com/TRIQS/cthyb cthyb.src && \
    mkdir -p cthyb.build && cd cthyb.build && \
    cmake ../cthyb.src -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX && \
    make  && make install

RUN git clone https://github.com/TRIQS/maxent maxent.src && \
    mkdir -p maxent.build && cd maxent.build && \
    cmake ../maxent.src -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX && \
    make  && make install

RUN git clone https://github.com/TRIQS/tprf tprf.src && \
    mkdir -p tprf.build && cd tprf.build && \
    cmake ../tprf.src -DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX && \
    make  && make install

RUN rm -rf /tmp/*.build /tmp/*.src

ARG NB_USER=triqs
ARG NB_UID=1000
RUN useradd -u $NB_UID -m $NB_USER && \
    echo 'triqs ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER $NB_USER
WORKDIR /home/$NB_USER

RUN curl -L https://api.github.com/repos/TRIQS/tutorials/tarball/unstable | tar xzf - --one-top-level=tutorials --strip-components=1
WORKDIR /home/$NB_USER/tutorials/TRIQSTutorialsPython

EXPOSE 8888
CMD ["jupyter","notebook","--ip","0.0.0.0"]
