# Node PM2 Onbuild

This image provides pm2 watch (auto reload on change) environment for nodejs projects. It's opinioned about your nodejs project folder scructure. Expects your project specific files to be under `src`.

You should extend this image and add project specific steps into your Dockerfile.

Example Dockerfile:

```Dockerfile
FROM cakuki/node-pm2-onbuild:latest

# project specific first time steps before running app
# gulp build

CMD ["node", "src/mainfile.js"]
# default main file is src/index.js
```

If you have some private repo dependencies in your package.json, you should give PKEY as a build argument to allow containerized git to access those repos. You can provide your own private key (`~/.ssh/id_rsa`) or only an authorized deployment key.

```bash
docker build -t cakuki/my-nodejs-project \
    --build-arg PKEY="$(awk 1 ORS='\\n' ~/.ssh/id_rsa)" \
    -v src:/app/src \
    -p 8080:8080 \
    .
```

For watch (auto reload) to work you should mount src directory via volume parameters.

Ports should also be explicitly exported.

Private key must be passed through awk replacement for newlines to `\n` characters.
Given private key is not stored inside the image. Inspect Dockerfile for more info.
