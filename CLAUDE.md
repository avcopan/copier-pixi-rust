# copier-pixi-rust

A Copier template for Rust libraries with a Python interface (PyO3 + maturin + pixi-build), with an optional Polars plugin.
`template/` (`_subdirectory`) is what gets generated.
The repo root has its own tooling that mirrors the generated projects (tbump releases, Lefthook hooks, `pixi run init`/`hooks`).
[`README.md`](README.md) is the reference for how everything works, including the "How It Works" section.
Read the relevant section before changing anything.
This is the Rust counterpart of `../copier-pixi-python`.
Keep the two consistent when a change applies to both, and read that repo's `CLAUDE.md` too, since its conventions and general pitfalls apply here.
Open and deferred items for both templates are in `../TODO.md`, which is not in git.
Update it when you finish an item or find a new one.
`../trials/avcopan_trialrs` is a real project generated from this template, with a GitHub repo and releases.
Use it to test `pixi run copier-update` and releases by hand.

## Workflow

- Generate a scratch project, including uncommitted template changes:
  `pixi exec --spec copier copier copy --vcs-ref=HEAD --defaults -d package_name=my_pkg -d description=x -d 'keywords=[test]' -d 'categories=[science]' -d author_name=x -d author_email=x@x.x -d github_org_name=x -d prefix_channel=x <abs path to this repo> <dest>`.
  Add `-d polars_plugin=true` for the plugin variant.
- `pixi run test` (`tests/test_template.py`, about 9 min for both variants, `plain` and `polars`) generates a project, runs its `pixi run init` and `pixi run pre-commit`, and checks for a clean tree.
  It also builds the docs (with rustdoc), and the conda package for `plain`.
  Use `pixi run test -k plain` for a faster loop.
- Releases work as in copier-pixi-python: CHANGELOG, then `pixi run release X.Y.Z`.
  README-only changes are not released.

## Pitfalls

- pixi-build-python + maturin:
  - `compilers = ["rust"]` must be explicit, or `.rs` edits never trigger a rebuild.
  - Set `extra-input-globs = ["Cargo.lock", "!target/**"]`.
  - The dev env uses its own `CARGO_TARGET_DIR`.
  - maturin `locked = true` deadlocks version bumps.
- The dev env sets `PYO3_BUILD_EXTENSION_MODULE=1`, because conda-forge Python 3.15 ships no `libpython3.15.so`.
  Anything that links libpython breaks (e.g. pyo3-stub-gen's binary).
- Stubs come from PyO3 `experimental-inspect` + `maturin generate-stubs`.
  A `#[pymodule_init]` makes the stub incomplete (`__getattr__ -> Incomplete`), so `__version__` uses `#[pymodule_export] const`.
- Great Docs shows types for compiled functions only from the `.pyi`.
  It shows Parameters/Returns only from Google-style `Args:`/`Returns:` in the `#[pyfunction]` doc comment.
- Clippy `pedantic` `doc_markdown` rejects bare `snake_case` names in docs (including `CRATE.md`).
  That's why the test uses `my_pkg`; `src/python.rs` allows it.
- PyPI: set `readme` in `pyproject.toml`, because with `[project]` and no `readme`, maturin drops Cargo.toml's readme.
- CI: `BUILD_EDITABLE_PYTHON: "false"` is set at workflow level.
  Otherwise, a restored setup-pixi cache lacks the gitignored `python/<pkg>/_core.abi3.so`, pixi skips the rebuild, and the import fails.
  Old caches must be deleted by hand.
  To reproduce locally, delete the `.so` and run `pixi install`.
- crates.io Trusted Publishing only works for an existing crate, so the 0.0.0 publish is manual (see the README).
