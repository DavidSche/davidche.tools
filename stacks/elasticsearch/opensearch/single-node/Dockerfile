FROM opensearchproject/opensearch-dashboards:1.0.0-beta1

LABEL maintainer ="Davidche <davidche@outlook.com>"

RUN /usr/share/opensearch-dashboards/bin/opensearch-dashboards-plugin remove securityDashboards

COPY --chown=opensearch-dashboards:opensearch-dashboards opensearch_dashboards.yml /usr/share/opensearch-dashboards/config/
