# Directories.
FROM ?= src
TO   ?= www
WITH ?= assets

# Deployment URL.
DEPLOY_URL = "https://giucal.it/makesite"

# Markdown converter.
MARKDOWN = pandoc --from=commonmark+smart \
                  --standalone \
                  --template=templates/html.html \
                  --css=$(BASE_URL)/style.css \
                  --mathjax

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

deploy: commit push

rebuild: clean
	# Re-building site for deployment...
	BASE_URL=$(DEPLOY_URL) make all

commit: rebuild
	# Committing changes to $(TO) branch...
	cd $(TO) && \
	git add --all && \
	git commit -m "Refresh" || true

push:
	# Pushing changes to $(TO) branch...
	git push origin $(TO)

clean:
	# Cleaning $(TO)...
	git worktree remove --force $(TO)
	git worktree add --no-checkout $(TO)

# Local server.
PORT = 8080
HOST = "http://localhost:$(PORT)"
LOCK = .server.lock

serve:
	# Serving site locally on port $(PORT)...
	@ if [ -f $(LOCK) ]; then \
	      echo >&2 "Error: A server is already running!"; \
	      exit 1; \
	  fi
	@ touch -- $(LOCK)
	@ python3 -m http.server --directory=$(TO) $(PORT); rm -- $(LOCK)

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
	@ $(MARKDOWN) --metadata title="$(shell scripts/title $<)" < $< > $@

# Special case for Markdown pages named "index.*".
$(TO)/%.html: $(FROM)/%.md templates/html.html
	@ echo $< '->' '$@'
	@ mkdir -p $(@D)
	@ $(MARKDOWN) --metadata title="$(shell scripts/title $<)" < $< > $@

