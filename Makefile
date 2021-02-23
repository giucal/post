# Directories.
FROM ?= src
TO   ?= local
WITH ?= assets

# Deployment.
DEPLOY_URL = "https://giucal.it/makesite"
DEPLOY_DIR = www
DEPLOY_BRANCH ?= $(DEPLOY_DIR)

# Base URL.
# This is set to $(DEPLOY_URL) when building.
BASE_URL ?= $(HOST)

# Targets

# Site static assets.
STATIC = $(patsubst $(WITH)/%,$(TO)/%,$(shell find $(WITH) -type f))

# Markdown pages' targets.
PAGES  = $(patsubst $(FROM)/%.md,$(TO)/%.html,$(shell find $(FROM) -type f -name 'index.md'))
PAGES += $(patsubst $(FROM)/%.md,$(TO)/%/index.html,$(shell find $(FROM) -type f -name '*.md' -not -name 'index.md'))

# Recipes

all: $(PAGES) $(STATIC)

preview: all serve

again: clean all

deploy: final commit push

final:
	# Cleaning $(DEPLOY_DIR)...
	git worktree remove --force $(DEPLOY_DIR)
	git worktree add --no-checkout $(DEPLOY_DIR) $(DEPLOY_BRANCH)
	# Building deployable version...
	BASE_URL=$(DEPLOY_URL) TO=$(DEPLOY_DIR) make all

commit:
	# Committing changes to the $(DEPLOY_BRANCH) branch...
	cd $(DEPLOY_DIR) && \
	git add --all && \
	git commit -m "Refresh" || true

push:
	# Pushing changes to the $(DEPLOY_BRANCH) branch...
	git push origin $(DEPLOY_BRANCH)

clean:
	# Cleaning $(TO)...
	rm -rf -- $(TO)

# Local server.
PORT = 8080
HOST = "http://localhost:$(PORT)"

serve:
	# Serving $(TO) locally on port $(PORT)...
	@ bin/server $(PORT) $(TO)

# Rules

# Copy asset as-is.
$(TO)/%: $(WITH)/%
	@ echo $< '->' '$@'
	@ mkdir -p $(@D)
	@ cp $< $@

# Render a Markdown page.
$(TO)/%/index.html: $(FROM)/%.md templates/html.html
	@ echo $< '->' '$@'
	@ mkdir -p $(@D)
	@ bin/markdown $< $@

# Special case for Markdown pages named "index.*".
$(TO)/%.html: $(FROM)/%.md templates/html.html
	@ echo $< '->' '$@'
	@ mkdir -p $(@D)
	@ bin/markdown $< $@
