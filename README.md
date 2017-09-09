# Hubot

This is a version of GitHub's Campfire bot, hubot. He's pretty cool.

## Setup

Follow this [instruction](https://github.com/mooz/node-icu-charset-detector#installing-icu) to install the ICU package.

Make sure Redis server is installed and running at 6379 port in your local.

```shell
$ npm install
```

Start Hubot in Toolbox server:

```shell
$ npm start
```

Start Hubot in local dev:

```shell
$ npm run hubot
```

You should be in the Hubot console now, to call Hubot please always add the `hubot` prefix, like:

```shell
hubot> hubot deploy ec-admin staging

## Deploying a repository

```
[hubot ]deploy REPOSITORY ENVIRONMENT [[REMOTE/]BRANCH]
```
deploy ec-admin staging Jiangwangbao/test
```

To check the latest deployment for a repository, you can run:

```
status [REPOSITORY]
```
