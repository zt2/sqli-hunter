FROM ruby:2.7.1

WORKDIR /root

RUN apt-get update && \
    apt-get install -y --no-install-recommends python-pip && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/sqlmapproject/sqlmap/archive/1.3.12.tar.gz && \
    tar -zxf 1.3.12.tar.gz && \
    rm -rf 1.3.12.tar.gz && \
    mv sqlmap-1.3.12 sqlmap

RUN wget https://github.com/zt2/sqli-hunter/archive/1.2.2.tar.gz && \
    tar -zxf 1.2.2.tar.gz && \
    rm -rf 1.2.2.tar.gz && \
    mv sqli-hunter-1.2.2 sqli-hunter && \
    cd sqli-hunter && \
    gem install bundler && \
    bundler install

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME /tmp

ENTRYPOINT ["/docker-entrypoint.sh"]
