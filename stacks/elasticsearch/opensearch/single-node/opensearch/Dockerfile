FROM opensearchproject/opensearch:1.0.0-rc1
RUN /usr/share/opensearch/bin/opensearch-plugin list
RUN /usr/share/opensearch/bin/opensearch-plugin remove opensearch-security
RUN /usr/share/opensearch/bin/opensearch-plugin list
COPY --chown=opensearch:opensearch opensearch.yml /usr/share/opensearch/config/