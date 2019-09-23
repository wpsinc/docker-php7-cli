##### Docker build
```shell
docker build --rm --force-rm --tag="wpsinc/docker-php7-cli" ./
```

##### Example Aliases
```shell
alias php='docker run --rm -it --network="host" -v $PWD:/usr/src/myapp -w /usr/src/myapp --user $(id -u):$(id -g) wpsinc/docker-php7-cli:master-latest php'
alias composer='docker run --rm -it --network="host" -v $PWD:/usr/src/myapp -w /usr/src/myapp -v ~/.composer:/composer --user $(id -u):$(id -g) wpsinc/docker-php7-cli:master-latest composer'
```
