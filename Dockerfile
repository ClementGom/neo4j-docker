FROM openjdk:8-jre-alpine

ENV VERSION "3.2.3"

LABEL maintainer.name="Clément GOMME"
LABEL maintainer.email="gomme.clementext@matmut.fr"
LABEL version="${VERSION}"
LABEL description="Neo4J v${VERSION}"

RUN apk add --no-cache --quiet \
    bash \
    curl

ENV NEO4J_SHA256=65e1de8a025eae4ba42ad3947b7ecbf758a11cf41f266e8e47a83cd93c1d83d2 \
    NEO4J_TARBALL=neo4j-community-${VERSION}-unix.tar.gz
ARG NEO4J_URI=http://dist.neo4j.org/neo4j-community-${VERSION}-unix.tar.gz

RUN curl --fail --silent --show-error --location --remote-name ${NEO4J_URI} \
    && echo "${NEO4J_SHA256}  ${NEO4J_TARBALL}" | sha256sum -csw - \
    && tar --extract --file ${NEO4J_TARBALL} --directory /var/lib \
    && mv /var/lib/neo4j-* /var/lib/neo4j \
    && rm ${NEO4J_TARBALL} \
    && mv /var/lib/neo4j/data /data \
    && ln -s /data /var/lib/neo4j/data \
    && apk del curl

# Configure neo4j
RUN sed -i '/^#dbms.connectors.default_listen_address/s/^#//' /var/lib/neo4j/conf/neo4j.conf && \
    sed -i '/^#dbms.connector.bolt.listen_address/s/^#//' /var/lib/neo4j/conf/neo4j.conf

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /var/lib/neo4j

VOLUME /data

EXPOSE 7474 7473 7687

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["neo4j"]
