# abraflexi-api-doc

A standalone, Sphinx-built reference guide for the **AbraFlexi (FlexiBee)
REST API** itself — not any particular client library. Compiled and
translated from the official documentation at
[podpora.flexibee.eu](https://podpora.flexibee.eu/cs/collections/2592813-dokumentace-rest-api)
and cross-checked against the reference PHP AbraFlexi library. Examples
throughout use JSON.

Available in two languages, each producing its own Debian package:

- `cs/` → `abraflexi-api-doc-cs` (Czech)
- `en/` → `abraflexi-api-doc-en` (English)

## Building the HTML docs

```bash
pip install sphinx shibuya   # or: apt install python3-sphinx python3-shibuya-sphinx-theme
sphinx-build -b html cs cs/_build
sphinx-build -b html en en/_build
```

## Building the Debian packages

```bash
dpkg-buildpackage -us -uc -b
```

Produces `abraflexi-api-doc-cs` and `abraflexi-api-doc-en`, each installing
its HTML output to `/usr/share/doc/abraflexi-api-doc-{cs,en}/html`, with an
Apache2 config snippet enabled automatically and an Nginx snippet provided
for reference.

## License

MIT — see [LICENSE](LICENSE). Note the underlying factual API description
originates from ABRA Software's own FlexiBee documentation; this project is
an independent compiled/translated reference, not an official ABRA Software
publication.
