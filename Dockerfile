FROM node:17.9.1-alpine AS nodejs
ARG ARCHIVEBOX_VER
ARG GUNICORN_VER

RUN apk add --no-cache \
    git \
    openssh-client

RUN git clone -b $ARCHIVEBOX_VER https://github.com/ArchiveBox/ArchiveBox.git /app \
    && rm -rf /app/.git
WORKDIR /app
RUN npm ci --omit=dev

FROM python:3.10-alpine AS python
ARG GUNICORN_VER
ARG ARCHIVEBOX_VER

WORKDIR /app

# Add User/Group for Archivebox
RUN apk add --no-cache musl-dev gcc \
    && python -m venv /app/venv \
    && /app/venv/bin/python -m pip install --upgrade pip wheel setuptools \
    && /app/venv/bin/pip install --upgrade youtube-dl yt-dlp gunicorn==$GUNICORN_VER archivebox==$ARCHIVEBOX_VER

# Add wsgi.py for Gunicorn
COPY files/wsgi.py /app/venv/lib/python3.10/site-packages/archivebox/wsgi.py

FROM python:3.10-alpine
ENV NODE_DIR="/app/"
ENV IN_DOCKER=True 
ENV CHROME_SANDBOX=False 
ENV CHROME_BINARY="/usr/bin/chromium-browser" 
ENV USE_SINGLEFILE=True 
ENV SINGLEFILE_BINARY="$NODE_DIR/node_modules/.bin/single-file" 
ENV USE_READABILITY=True 
ENV READABILITY_BINARY="$NODE_DIR/node_modules/.bin/readability-extractor" 
ENV USE_MERCURY=True
ENV MERCURY_BINARY="$NODE_DIR/node_modules/.bin/mercury-parser"
ENV YOUTUBEDL_BINARY="yt-dlp"

RUN apk add --no-cache libstdc++ chromium wget

# Node Requirements
COPY --from=nodejs /usr/local/bin/node /usr/local/bin/node
COPY --from=nodejs /app/node_modules /app/node_modules

# Python Requirements
COPY --from=python /app/venv /app/venv

## Create User
RUN addgroup --gid 1000 archivebox \
    && adduser -S -h /app -u 1000 -G archivebox archivebox \
    && addgroup archivebox video \
    && addgroup archivebox audio

## Create Entrypoint
COPY files/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

## Create data dir
RUN mkdir /app/data \
    && chown -R archivebox:archivebox /app/data \
    && id archivebox 
WORKDIR /app/data

# Set user
USER archivebox

# Set path
ENV PATH="/app/venv/bin:/app/node_modules/.bin:$PATH"

CMD ["/entrypoint.sh"]
