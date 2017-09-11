FROM debian:jessie

LABEL maintainer "opsxcq@strm.sh"

RUN apt-get update && \
    # Set the environment to non interactive (no input required)
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential \
    ruby \
    valgrind && \
    # Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./ntp-4.2.8p8 /src/
COPY ./ntp.conf /

RUN cd /src && \
    chmod +x configure && \
    sync && \
    ./configure && \
    make

EXPOSE 123/udp

CMD ["valgrind", "/src/ntpd/ntpd","-n","-c","/ntp.conf"]
