# Gitpod's Dockerfile file.
# https://www.gitpod.io/docs/config-docker/
FROM ea31337/ea-tester:dev as ea-tester
FROM gitpod/workspace-full as gitpod
COPY --from=ea-tester --chown=gitpod:sudo /opt /opt

# Environment variables.
ENV BT_DEST /opt/results
ENV PATH $PATH:/opt/scripts:/opt/scripts/py

# Run provision script.
RUN provision.sh

# Modify shell startup scripts.
RUN echo source /opt/scripts/.funcs.cmds.inc.sh >> ~/.bashrc
