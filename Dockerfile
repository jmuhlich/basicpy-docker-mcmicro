# modified from https://hub.docker.com/layers/condaforge/miniforge3/latest/images/sha256-1a4710bbb61c9de8b9293c3f9cbc1223bb8ede21e74942a71a6c1c7d5eb54b2e?context=explore
ARG MINIFORGE_NAME="Miniforge3"
ARG MINIFORGE_VERSION="22.9.0-3"
#ARG TARGETPLATFORM

# FROM nvidia/cuda:11.5.2-cudnn8-devel-ubuntu20.04
FROM ubuntu:20.04
#https://stackoverflow.com/questions/44438637/arg-substitution-in-run-command-not-working-for-dockerfile
ARG MINIFORGE_NAME
ARG MINIFORGE_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV CONDA_DIR=/opt/conda
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN sed -i.bak -e 's%http://[^ ]\+%mirror://mirrors.ubuntu.com/mirrors.txt%g' /etc/apt/sources.list
RUN apt-get update \
      && apt-get install -y ca-certificates\
      && apt-get install -y tzdata\
      && apt-get install --no-install-recommends -y wget bzip2 git tini\
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/*

RUN wget --no-hsts --quiet https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/${MINIFORGE_NAME}-${MINIFORGE_VERSION}-Linux-$(uname -m).sh -O /tmp/miniforge.sh \
    && /bin/bash /tmp/miniforge.sh -b -p ${CONDA_DIR} \
    && rm /tmp/miniforge.sh \
    && conda clean --tarballs --index-cache --packages --yes \
    && find ${CONDA_DIR} -follow -type f -name '*.a' -delete \
    && find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete \
    && conda clean --force-pkgs-dirs --all --yes  \
    && echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> /etc/skel/.bashrc \
    && echo ". ${CONDA_DIR}/etc/profile.d/conda.sh && conda activate base" >> ~/.bashrc # buildkit

RUN pip --no-cache-dir install --upgrade pip \
    && pip --no-cache-dir install "jax[cpu]==0.3.20"\
    && pip --no-cache-dir install basicpy aicsimageio[bfio] bfio[bioformats] scikit-image
    #&& pip --no-cache-dir install "jax[cuda11_cudnn82]==0.3.20" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html \
COPY ./main.py /opt/
RUN mkdir /data
COPY ./testdata/exemplar-001-cycle-06.ome.tiff /data/
RUN /opt/main.py --cpu /data/exemplar-001-cycle-06.ome.tiff /data/
RUN rm -r /data
ENTRYPOINT ["/opt/main.py"]
