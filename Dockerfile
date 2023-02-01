FROM golang:1.18.8-buster AS builder_hyperspace

RUN apt update
RUN apt upgrade -y
RUN apt install mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl clang build-essential hwloc libhwloc-dev -y
RUN apt install -y git ssh wget

WORKDIR /build

RUN git clone --branch v1.20.0-hyperspace-0131 -v --progress https://github.com/filecoin-project/lotus.git .

RUN wget https://sh.rustup.rs
RUN mv index.html rustup-init
RUN chmod +x rustup-init
RUN ./rustup-init -y
RUN make clean hyperspacenet
RUN make install


FROM golang:1.18.8-buster

COPY --from=builder_hyperspace /usr/local/bin /usr/local/bin
RUN adduser --disabled-password --gecos "" --uid 1000 service
WORKDIR /home/service
RUN apt update && apt install libhwloc-dev -y
USER service

ENTRYPOINT ["lotus", "daemon"]
