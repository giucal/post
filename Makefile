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

# Sources

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
final: clean-deploy-directory
	# Building deployable version...
	BASE_URL=$(DEPLOY_URL) TO=$(DEPLOY_DIR) make

# Prepare the deployable version of the site in $(DEPLOY_DIR)
# taking advantage of Make's incremental-compilation capabilities.
final-incrementally:
	# Build deployable version incrementally...
	BASE_URL=$(DEPLOY_URL) TO=$(DEPLOY_DIR) make

commit:
	# Committing changes to the branch $(DEPLOY_BRANCH)...
	cd $(DEPLOY_DIR) && \
	git add --all && \
	git commit -m "Refresh" || true

push:
	# Pushing changes to the remote branch $(DEPLOY_BRANCH)...
	git push origin $(DEPLOY_BRANCH)

init:
	# Creating missing directories...
	mkdir -p $(FROM) $(TO) $(WITH)
	# Telling git to ignore the build directory...
	bin/ignore $(TO)
	# Setting things up for deployment...
	bin/setup-deploy $(DEPLOY_BRANCH) $(DEPLOY_DIR)

clean:
	# Cleaning $(TO)...
	rm -rf -- $(TO)

clean-deploy-directory:
	# Cleaning $(DEPLOY_DIR)...
	git worktree remove --force $(DEPLOY_DIR)
	git worktree add --no-checkout $(DEPLOY_DIR) $(DEPLOY_BRANCH)

# Local server.
PORT = 8080
HOST = "http://localhost:$(PORT)"

serve:
	# Serving $(TO) on port $(PORT)...
	bin/server $(PORT) $(TO)

# Rules

# Copy an asset as-is.
$(TO)/%: $(WITH)/%
	@ mkdir -p $(@D)
	cp $< $@

$(TO)/%: $(FROM)/%
	@ mkdir -p $(@D)
	cp $< $@

# Markdown

MARKDOWN_DEPS = templates/html.html bin/markdown bin/title

# Render a Markdown node.
$(TO)/%/index.html: $(FROM)/%.md $(MARKDOWN_DEPS)
	@ mkdir -p $(@D)
	bin/markdown $< $@

# Render a Markdown leaf.
$(TO)/%.html: $(FROM)/%.md $(MARKDOWN_DEPS)
	@ mkdir -p $(@D)
	bin/markdown $< $@
