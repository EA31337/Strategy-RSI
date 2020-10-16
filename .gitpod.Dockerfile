# Gitpod's Dockerfile file.
# https://www.gitpod.io/docs/config-docker/
FROM ea31337/ea-tester:dev as ea-tester
FROM gitpod/workspace-full as gitpod
COPY --from=ea-tester --chown=gitpod:sudo /opt /opt

# Specifies environment variables.
ENV BT_DEST /opt/results
ENV PATH $PATH:/opt/scripts:/opt/scripts/py

# Runs provision script as root.
USER root
RUN provision.sh

# Uses gitpod by default.
USER gitpod

# Modifies shell startup scripts.
RUN echo source /opt/scripts/.funcs.cmds.inc.sh >> ~/.bashrc
