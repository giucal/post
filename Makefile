# Directories.
FROM ?= content
TO   ?= build/local
WITH ?= assets

# Deployment.
DEPLOY_URL = "https://giucal.it/makesite"
DEPLOY_DIR = build/public
DEPLOY_BRANCH ?= $(shell basename $(DEPLOY_DIR))

# Base URL.
# This is set to $(DEPLOY_URL) when building.
BASE_URL ?= $(HOST)

# Sources.

# Markdown sources.
MARKDOWN_LEAFS = $(shell find -L $(FROM) -type f -name 'index.md')
MARKDOWN_NODES = $(shell find -L $(FROM) -type f -name '*.md' -not -name 'index.md')

# Assets.
ATTACHMENTS = $(shell find -L $(FROM) -type f -not -name '*.md' -not -name '.*')
SITE_ASSETS = $(shell find -L $(WITH) -type f -not -name '.*')

# Targets

# Files to copy over.
VERBATIM  = $(patsubst $(FROM)/%,$(TO)/%,$(ATTACHMENTS))
VERBATIM += $(patsubst $(WITH)/%,$(TO)/%,$(SITE_ASSETS))

# HTML pages.
PAGES  = $(patsubst $(FROM)/%.md,$(TO)/%.html,$(MARKDOWN_LEAFS))
PAGES += $(patsubst $(FROM)/%.md,$(TO)/%/index.html,$(MARKDOWN_NODES))

# Recipes

all: draft

# Build targets incrementally.
draft: $(PAGES) $(VERBATIM)

# Preview the site.
preview: draft serve

# Deploy the site to the remote branch $(DEPLOY_BRANCH).
deploy: final commit push

# Prepare the deployable version of the site in $(DEPLOY_DIR).
final:
	# Cleaning $(DEPLOY_DIR)...
	git worktree remove --force $(DEPLOY_DIR)
	git worktree add --no-checkout $(DEPLOY_DIR) $(DEPLOY_BRANCH)
	# Building deployable version...
	BASE_URL=$(DEPLOY_URL) TO=$(DEPLOY_DIR) make

# Put everything in place.
init:
	# Creating missing directories...
	mkdir -p $(FROM) $(TO) $(WITH)
	# Setting things up for deployment...
	bin/setup-deploy $(DEPLOY_BRANCH) $(DEPLOY_DIR)

commit:
	# Committing changes to the branch $(DEPLOY_BRANCH)...
	cd $(DEPLOY_DIR) && \
	git add --all && \
	git commit -m "Refresh" || true

push:
	# Pushing changes to the remote branch $(DEPLOY_BRANCH)...
	git push origin $(DEPLOY_BRANCH)

clean:
	# Cleaning $(TO)...
	rm -rf -- $(TO)

# Local server.
PORT = 8080
HOST = "http://localhost:$(PORT)"

serve:
	# Serving $(TO) locally on port $(PORT)...
	bin/server $(PORT) $(TO)

# Rules

# Copy an asset as-is.
$(TO)/%: $(WITH)/%
	@ mkdir -p $(@D)
	cp $< $@

# Render a Markdown page.
$(TO)/%/index.html: $(FROM)/%.md templates/html.html
	@ mkdir -p $(@D)
	bin/markdown $< $@

# Special case for Markdown pages named "index.*".
$(TO)/%.html: $(FROM)/%.md templates/html.html
	@ mkdir -p $(@D)
	bin/markdown $< $@
