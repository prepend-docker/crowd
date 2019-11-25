FROM adoptopenjdk/openjdk8:slim

ENV RUN_USER                                        crowd
ENV RUN_GROUP                                       crowd
ENV RUN_UID                                         2000
ENV RUN_GID                                         2000

# https://confluence.atlassian.com/crowd/important-directories-and-files-78676537.html
ENV CROWD_HOME                                      /var/atlassian/application-data/crowd
ENV CROWD_INSTALL_DIR                               /opt/atlassian/crowd

WORKDIR $CROWD_HOME

# Expose HTTP port
EXPOSE 8095

CMD ["/entrypoint.py", "-fg"]
ENTRYPOINT ["/tini", "--"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends fontconfig python3 python3-jinja2 \
    && apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

ARG TINI_VERSION=v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ARG CROWD_VERSION
ARG DOWNLOAD_URL=https://www.atlassian.com/software/crowd/downloads/binary/atlassian-crowd-3.7.0.tar.gz

RUN groupadd --gid ${RUN_GID} ${RUN_GROUP} \
    && useradd --uid ${RUN_UID} --gid ${RUN_GID} --home-dir ${CROWD_HOME} ${RUN_USER} \
    \
    && mkdir -p                                     ${CROWD_INSTALL_DIR} \
    && curl -L --silent                             ${DOWNLOAD_URL} | tar -xz --strip-components=1 -C "${CROWD_INSTALL_DIR}" \
    && chmod -R "u=rwX,g=rX,o=rX"                   ${CROWD_INSTALL_DIR}/ \
    && chown -R root.                               ${CROWD_INSTALL_DIR}/ \
    && chown -R ${RUN_USER}:${RUN_GROUP}            ${CROWD_INSTALL_DIR}/apache-tomcat/logs \
    && chown -R ${RUN_USER}:${RUN_GROUP}            ${CROWD_INSTALL_DIR}/apache-tomcat/temp \
    && chown -R ${RUN_USER}:${RUN_GROUP}            ${CROWD_INSTALL_DIR}/apache-tomcat/work \
    && chown -R ${RUN_USER}:${RUN_GROUP}            ${CROWD_HOME} \
    \
    && sed -i -e 's/-Xms\([0-9]\+[kmg]\) -Xmx\([0-9]\+[kmg]\)/-Xms\${JVM_MINIMUM_MEMORY:=\1} -Xmx\${JVM_MAXIMUM_MEMORY:=\2} \${JVM_SUPPORT_RECOMMENDED_ARGS} -Dcrowd.home=\${CROWD_HOME}/g' ${CROWD_INSTALL_DIR}/apache-tomcat/bin/setenv.sh

VOLUME ["${CROWD_HOME}"] # Must be declared after setting perms

COPY entrypoint.py					/entrypoint.py
COPY config/*                                       /opt/atlassian/etc/
