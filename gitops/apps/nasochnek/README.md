# nasochnek

Static Astro site (https://github.com/ReveekJ/NaSochnek-Group) served by nginx,
deployed to the worker node and exposed at `nasochnek.reveek-io.ru`.

## Deploying a new image

The image is built from the upstream repo and pushed to the private registry
(CI will automate this later; until then — manually):

```sh
docker login reg.reveek-io.ru
docker buildx build --platform linux/amd64 \
  -t reg.reveek-io.ru/nasochnek:latest /path/to/NaSochnek-Group --push
```

The deployment uses `imagePullPolicy: Always` with the `latest` tag, so Argo CD
picks up new images on every sync/restart. To force a rollout after pushing:

```sh
ansible k3s_master -m shell -b -a 'kubectl -n nasochnek rollout restart deploy/nasochnek'
```
