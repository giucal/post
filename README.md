# Makesite

A blueprint for a simple static website.
Built with Make, pandoc, and *some* shell script.

## Directory structure

The source directory is structured as follows.

  Directory      | Description
  -------------- | --------------------------------------------------
  `Makefile`     |  *The Makefile.*
  `assets`       |  Static assets (e.g. CSS, Javascript).
  [`bin`](bin)   |  Auxiliary scripts.
  `build/local`  |  Preview build.
  `build/public` |  Deployment build.
  `content`      |  Content (e.g. posts and their static attachments).
  `templates`    |  HTML templates.

## Use

### Configuration

Customize the following variables in the [Makefile](Makefile), if you want.

  Variable        | Description
  --------------- | ----------------------------------------------------------
  `FROM`          | The content directory.
  `TO`            | The preview build directory.
  `WITH`          | The static assets directory.
  `DEPLOY_DIR`    | The deployment build directory.
  `DEPLOY_BRANCH` | The deploy branch name. To be checked out in `DEPLOY_DIR`.

### Initialization

The Makefile expects to be run in a Git repository:

    git init

After setting any of the above [configuration variables](#configuration),
and before starting to develop your site, invoke

    make init

This command ensures that the repository is correctly initialized.

### Workflow

#### Local (re)build

To build your site locally:

    make draft

or just

    make

Every time you make a change to the content, issuing `make` again should be
sufficient to compile only those files that have been affected.

Sometimes, though, it's necessary to do rebuild from the ground up:

    make clean draft

Using `make -B` (same as `make draft -B`) in this case would rebuild *on top*
of what's already there; which is not what you want.

#### Local preview

To preview the site on your machine:

    make serve

To update the build *and* preview the site:

    make draft serve

To let the server run in the background while making changes:

    make serve &

If you don't want to see the log, I recommend:

    make serve 2> server.log &

If something weird happens, you can inspect `server.log`.

### Deploy

To build the deployment version:

    make final

To commit this version as it is to the deployment branch:

    make commit

To push changes to the remote deployment branch (assumed to have the same name):

    make push

If the local version was OK and you feel intrepid, you can also deploy
the site in one step:

    make deploy

which is of course the same as `make final commit push`.

#### Note

The deployment version is always rebuild from scratch when you do `make final`.
If you're *really* intrepid, you can build it incrementally:

    make final-incrementally

### Other operations

To clean the local build without rebuilding:

    make clean

