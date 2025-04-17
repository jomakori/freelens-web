# Use Ubuntu as the base image
FROM ubuntu:plucky

ARG FREELENS_VERSION

ENV DISPLAY=:0
ENV PORT=8080

# Install dependencies
RUN apt-get update && apt-get install -y \
  curl git xvfb x11vnc nodejs npm libarchive-tools wget libnss3 libgdk libgbm1 libglib2 libxss1 libgtk-3-0 libatspi2.0-0 libsecret-1-0 libasound2t64 && \
  apt-get clean

WORKDIR /opt

# Clone and install websockify-js
RUN git clone https://github.com/novnc/websockify-js.git && \
  cd websockify-js/websockify && \
  npm install

# Download and install Freelens .deb package
RUN wget https://github.com/freelensapp/freelens/releases/download/v${FREELENS_VERSION}/Freelens-${FREELENS_VERSION}-linux-amd64.deb && \
  dpkg -i Freelens-${FREELENS_VERSION}-linux-amd64.deb && \
  rm -f Freelens-${FREELENS_VERSION}-linux-amd64.deb

WORKDIR /app

# Copy application code
COPY app .

ENTRYPOINT [ "/app/entrypoint.sh" ]
