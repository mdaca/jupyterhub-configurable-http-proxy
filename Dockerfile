# Define build arguments
ARG BASE_REGISTRY=201959883603.dkr.ecr.us-east-2.amazonaws.com
ARG BASE_IMAGE_PATH=mdaca/base-images/ironbank-alpine
ARG BASE_TAG=3.20.3

# Construct the full base image path
ARG BASE_IMAGE=${BASE_REGISTRY}/${BASE_IMAGE_PATH}:${BASE_TAG}

# Use the base image
FROM ${BASE_IMAGE}

# Set labels based on the Open Containers Initiative (OCI):
LABEL org.opencontainers.image.authors="Jupyter Project <jupyter@googlegroups.com>"
LABEL org.opencontainers.image.source="https://github.com/jupyterhub/configurable-http-proxy"
LABEL org.opencontainers.image.url="https://github.com/jupyterhub/configurable-http-proxy/blob/HEAD/Dockerfile"

# Add tools useful for debugging and update packages to patch known vulnerabilities if needed.
RUN apk upgrade --no-cache \
 && apk add --no-cache \
        curl \
        jq \
        nodejs \
        npm

# Copy relevant files (see .dockerignore)
RUN mkdir -p /srv/configurable-http-proxy
COPY . /srv/configurable-http-proxy/
WORKDIR /srv/configurable-http-proxy

# Install configurable-http-proxy according to package-lock.json (ci) without devDependencies (--production), then uninstall npm which isn't needed.
RUN npm ci --production \
 && npm uninstall -g npm

# Switch from the root user to the nobody user
USER 65534

# Expose the proxy for traffic to be proxied (8000) and the REST API where it can be configured (8001)
EXPOSE 8000
EXPOSE 8001

# Put configurable-http-proxy on path for chp-docker-entrypoint
ENV PATH=/srv/configurable-http-proxy/bin:$PATH
ENTRYPOINT ["/srv/configurable-http-proxy/chp-docker-entrypoint"]
