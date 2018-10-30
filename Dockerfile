FROM ubuntu as builder

LABEL maintainer="golden finger@deepsecs.com"

COPY aliyun.list  /etc/apt/sources.list

RUN apt-get -y update \
  && apt-get install -yqq libssh-dev build-essential curl \
  && mkdir -p /opt/tpm2 \
  && curl -sq https://nchc.dl.sourceforge.net/project/ibmswtpm2/ibmtpm1332.tar.gz --output - | tar -xzvf  - -C /opt/tpm2 \
  && make -j4 -C /opt/tpm2/src 

FROM ubuntu

COPY aliyun.list  /etc/apt/sources.list

RUN DEBIAN_FRONTEND=noninteractive \
  apt-get -y update && \
  apt-get -y install --no-install-recommends tcpd xinetd libssl1.0.0 curl && \
  apt-get clean && \ 
  rm -rf /var/lib/apt/lists

COPY --from=builder /opt/tpm2/src/tpm_server /usr/local/bin/

EXPOSE 2321

ENTRYPOINT ["/usr/local/bin/tpm_server"]

