FROM dashersw/nodejs-build-tools:1.3.0-hotfix

MAINTAINER Can Kutlu Kinay <can@unumotors.com>
# Copied mostly from https://github.com/ficusio/docker-nodejs/blob/5.6/onbuild/Dockerfile

WORKDIR /app

RUN npm install --global pm2

ONBUILD ARG PKEY=none
ONBUILD COPY package.json yarn.lock* /app/

ONBUILD RUN \
  echo '  ==> Injecting private key...' && \
  mkdir -m 700 -p ~/.ssh && \
  echo -e "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
  echo -e $PKEY > ~/.ssh/id_rsa && \
  chmod 700 ~/.ssh/id_rsa && \
  echo '  ==> Installing NPM modules...' && \
  npm install && \
  # Rename node_modules to node_modules_new before copy all,
  # prevent possible not dockerignored node_modules override
  echo '  ==> Rename node_modules...' && \
  mv node_modules node_modules_new && \
  echo '  ==> Clean npm cache...' && \
  npm cache clean && \
  echo '  ==> Remove [~/.ssh ~/.node-gyp /tmp/*]...' && \
  rm -rf ~/.ssh ~/.node-gyp /tmp/*

# Copy app files to the target directory.
ONBUILD COPY . /app/

# Rename node_modules_new back to node_modules.
ONBUILD RUN rm -rf node_modules && \
  mv node_modules_new node_modules

ENTRYPOINT ["pm2", "start", "--no-daemon", "--watch"]
CMD ["node", "src/index.js"]

VOLUME /app/src
