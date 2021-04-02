# Makesite

A blueprint for a simple static website.
Built with Make, pandoc, and *some* shell script.

## Directory structure

The source directory is structured as follows.

  Directory      | Description
  -------------- | --------------------------------------------------
  `assets`       |  static assets (e.g. CSS, Javascript)
  `bin`          |  auxiliary scripts
  `build/local`  |  preview build
  `build/public` |  deployment build
  `content`      |  content (e.g. posts and their static attachments)
  `templates`    |  HTML templates
  `Makefile`     |  the makefile

## Use

Customize the following variables in the [Makefile](Makefile), if you want.

  Variable        | Description
  --------------- | ----------------------------------------------------------
  `FROM`          | The content directory.
  `TO`            | The preview build directory.
  `WITH`          | The static assets directory.
  `DEPLOY_DIR`    | The deployment build directory.
  `DEPLOY_BRANCH` | The deploy branch name. To be checked out in `DEPLOY_DIR`.

Any of these will be created by `make init` if they don't exist.

    make init
