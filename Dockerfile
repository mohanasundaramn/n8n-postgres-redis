# We use a specific node version, as this is what n8n is tested against
FROM node:18-alpine

# Set a custom user to run the application, instead of root
# This is a security best practice
ARG PUID=1000
ARG PGID=1000
RUN deluser node &&\
    addgroup -g $PGID n8n &&\
    adduser -G n8n -u $PUID -h /home/n8n -s /bin/sh -D n8n

# The n8n source code is copied to the /data directory
WORKDIR /data

# Healthcheck to make sure the container is running
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s \
    CMD wget -q --spider http://localhost:5678/healthz || exit 1

# The n8n packages are installed, and the application is built
# This is a multi-stage build, so the final image is as small as possible
COPY --chown=n8n:n8n packages/cli/package.json packages/cli/
COPY --chown=n8n:n8n packages/core/package.json packages/core/
COPY --chown=n8n:n8n packages/design-system/package.json packages/design-system/
COPY --chown=n8n:n8n packages/editor-ui/package.json packages/editor-ui/
COPY --chown=n8n:n8n packages/nodes-base/package.json packages/nodes-base/
COPY --chown=n8n:n8n packages/workflow/package.json packages/workflow/
COPY --chown=n8n:n8n package.json lerna.json .npmrc ./
RUN npm install -g lerna &&\
    lerna bootstrap --hoist
COPY --chown=n8n:n8n packages packages
RUN lerna run build

USER n8n

# The command to start n8n
CMD ["n8n"]
