FROM opensearchproject/opensearch:1.0.0-beta1
RUN /usr/share/opensearch/bin/opensearch-plugin remove opensearch-security
COPY --chown=opensearch:opensearch opensearch.yml /usr/share/opensearch/config/