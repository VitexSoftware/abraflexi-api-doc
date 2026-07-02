"""Sphinx configuration for the standalone AbraFlexi REST API reference (Czech)."""

project = "Dokumentace REST API AbraFlexi"
copyright = "2026, obsah převzat a přeložen z podpora.flexibee.eu, sestaveno VitexSoftware"
author = "VitexSoftware"

version = "1.0"
release = "1.0"

extensions = []

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

html_theme = "alabaster"
html_static_path = ["_static"]
html_logo = "_static/abraflexi.svg"
html_favicon = "_static/abraflexi.svg"

# Compatibility shim: the installed shibuya theme hardcodes pygments style
# names ("github-light-default"/"github-dark-default") that only exist in
# newer pygments releases than the one available here. Fall back to
# built-in styles so `-D html_theme=shibuya` builds don't crash.
try:
    from pygments.styles import get_style_by_name

    get_style_by_name("github-light-default")
except Exception:
    try:
        import shibuya._pygments as _shibuya_pygments

        _shibuya_pygments.ShibuyaPygmentsBridge.light_style_name = "default"
        _shibuya_pygments.ShibuyaPygmentsBridge.dark_style_name = "github-dark"
    except ImportError:
        pass
