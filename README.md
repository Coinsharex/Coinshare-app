# Coinshare App

Web Application for Coinshare system that allows users to loan others funds based on their help requests.

Please also note the Web API that it uses: https://github.com/Coinsharex/Coinshare

## Install

Install this application by cloning the _relevant branch_ and use bundler to install specified gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

This web app does not contain any tests yet :(

## Execute

Launch the application using:

```shell
rake run:dev
```

The application expects the API application to also be running (see `config/app.yml` for specifying its URL)
