FROM opensearchproject/opensearch-dashboards:1.0.0

LABEL maintainer ="Davidche <davidche@outlook.com>"

#RUN /usr/share/opensearch-dashboards/bin/opensearch-dashboards-plugin remove securityDashboards
RUN /usr/share/opensearch-dashboards/bin/opensearch-dashboards-plugin list
#RUN /usr/share/opensearch-dashboards/bin/opensearch-dashboards-plugin remove security-dashboards
RUN /usr/share/opensearch-dashboards/bin/opensearch-dashboards-plugin remove securityDashboards
RUN /usr/share/opensearch-dashboards/bin/opensearch-dashboards-plugin list

COPY --chown=opensearch-dashboards:opensearch-dashboards opensearch_dashboards.yml /usr/share/opensearch-dashboards/config/
