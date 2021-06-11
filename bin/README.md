# Auxiliary scripts

This directory contains executables (mostly scripts) that implement
special processes, like page rendering, attribute parsing, an HTTP server, and
so on.

### [`ignore`](ignore)

Manages the `.gitignore` file. Some files and directories need to be
excluded from tracking to ensure "correct operation."

### [`markdown`](markdown)

Renders a Markdown document, writing a proper HTML document to disk.
Templating is managed by this script.

### [`server`](server)

Starts a local server for previewing. Uses Python's `http.server`.

### [`setup-deploy`](setup-deploy)

It sets up, if they aren't already, the deploy branch and work tree.

### [`title`](title)

Infers the title of a Markdown document. To this script a title is anything
at the beginning of the document (minus empty lines). In order of preference:

  - An ATX heading (of any level); e.g.

        # Title

    or

        #### Title

  - A Setext heading (of 1st or 2nd level); e.g.

        The first Setext
        heading
        ================

    or

        The first Setext
        heading
        ----------------

    Setext headings can span multiple lines because it makes sense.
    And anyway, [the CommonMark specification agrees][cmark-setext-headings].

  - A run of text (not necessarily a paragraph!) followed by a new line or EOF.

  - The empty title, "".

It trunctates very long titles.

[cmark-setext-headings]: https://spec.commonmark.org/current/#setext-headings
