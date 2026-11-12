# copier-pixi-rust

A Copier template for Rust libraries with a Python interface (PyO3 + maturin + pixi-build), with an optional Polars plugin.
A generated project is a Cargo workspace with two crates: the library (root `Cargo.toml`, `src/`, published to crates.io, no PyO3) and the Python bindings (`py-<package_name>/`, `publish = false`, a `cdylib`).
`template/` (`_subdirectory`) is what gets generated.
The repo root has its own tooling that mirrors the generated projects (tbump releases, Lefthook hooks, `pixi run init`/`hooks`).
[`README.md`](README.md) is the reference for how everything works, including the "How It Works" section.
Read the relevant section before changing anything.
This is the Rust counterpart of [copier-pixi-python](https://github.com/avcopan/copier-pixi-python).
Keep the two consistent when a change applies to both, and read that repo's `CLAUDE.md` too, since its conventions and general pitfalls apply here.
Test `pixi run copier-update` and releases by hand in a real project generated from the template.

## Workflow

- Generate a scratch project, including uncommitted template changes:
  `pixi exec --spec copier copier copy --vcs-ref=HEAD --defaults -d package_name=my_pkg -d description=x -d 'keywords=[test]' -d 'categories=[science]' -d author_name=x -d author_email=x@x.x -d github_org_name=x -d prefix_channel=x/x <abs path to this repo> <dest>`.
  Add `-d polars_plugin=true` for the plugin variant.
- `pixi run test` (`tests/test_template.py`, for both variants, `plain` and `polars`; locally with a warm cache, `plain` takes about 2 min and `polars` about 12 min; in CI, where the variants run in parallel, `plain` takes about 1 min and `polars` 6.5–9 min) generates a project, runs its `pixi run init` and `pixi run pre-commit`, and checks for a clean tree.
  It also builds the docs (with rustdoc), and the conda package for `plain`.
  Use `pixi run test -k plain` for a faster loop.
- Releases work as in copier-pixi-python: CHANGELOG, then `pixi run release X.Y.Z`.
  The user does all pushes and releases: commit and prepare them, but never run `git push` or `pixi run release`.
  README-only changes are not released.

## Pitfalls

- Local dependencies (`scripts/local.sh`, `pixi run local start|stop`), checked 2026-10-30 with tetramol and a local automol:
  - The published dependency goes in `pyproject.toml` (`pixi run add`), plus a `pypi-conda-map` entry if it isn't on conda-forge under that name.
    Only the `# local:true` line is needed in `pixi.toml` `[dependencies]` (e.g. `automol = { path = "../automol" }`); a `# local:false` line is redundant.
    The exception is a PyPI-only dependency (`pypi-conda-map` → `false`, e.g. qcdata): it needs both lines in `[pypi-dependencies]`, since nothing else installs it (see the README).
  - `pixi run local start` runs in the `dev` env, so it fails when the local:false state can't solve (e.g. the bound asks for an unreleased version); `./scripts/local.sh start` works then.
  - pixi intersects the path dependency with the pyproject bound, so the local checkout's version must satisfy the bound.
    Bump the version in the dependency's repo before raising the bound.
  - Until the dependency's new code is released, `pixi run pre-commit` (which runs `local stop` and tests against the published version) fails. Use `pixi run pre-commit-local`.
  - `start` and `stop` stash and restore `.pixi/` and `pixi.lock` as `.pixi_local_{true,false}*`, seeding `true` from `false` with rsync hardlinks. This worked as designed.
- pixi-build-python + maturin:
  - `compilers = ["rust"]` must be explicit, or `.rs` edits never trigger a rebuild.
  - Set `extra-input-globs = ["Cargo.lock", "!target/**"]`.
  - The dev env uses its own `CARGO_TARGET_DIR`.
  - maturin `locked = true` deadlocks version bumps.
- The dev env sets `PYO3_BUILD_EXTENSION_MODULE=1`, because conda-forge Python 3.15 ships no `libpython3.15.so`.
  Anything that links libpython breaks (e.g. pyo3-stub-gen's binary).
- Stubs come from PyO3 `experimental-inspect` + `maturin generate-stubs`.
  A `#[pymodule_init]` makes the stub incomplete (`__getattr__ -> Incomplete`), so `__version__` uses `#[pymodule_export] const`.
  `create_exception!` types are also invisible to it and make the stub incomplete, so the exceptions are `#[pyclass(extends = PyException)]` classes.
  The template's `_core.pyi.jinja` must match what `pixi run stubs` generates for both variants, which differ because of their PyO3 versions (0.30 adds `@disjoint_base`).
- In `.rs.jinja` files, a line that contains `{{package_name}}` must format the same for any name length, or `cargo fmt` changes a fresh project and `check-clean` fails.
  Keep such lines short, and don't put `use {{package_name}}::...` in a group with other imports, since rustfmt sorts it by name.
- `pixi run test` needs several GB of temporary space: where `/tmp` is a small tmpfs, run `TMPDIR=<dir on disk> pixi run test`.
- The Polars variant needs a C compiler in the `dev` env (`c-compiler`), because a Rust dependency of Polars (`psm`) compiles C code.
- Great Docs shows types for compiled functions only from the `.pyi`.
  It shows Parameters/Returns only from Google-style `Args:`/`Returns:` in the `#[pyfunction]` doc comment.
- Clippy `pedantic` `doc_markdown` rejects bare `snake_case` names in docs (including `CRATE.md`).
  That's why the test uses `my_pkg`; the bindings crate allows it.
- PyPI: set `readme` in `pyproject.toml`, because with `[project]` and no `readme`, maturin drops Cargo.toml's readme.
- CI: `BUILD_EDITABLE_PYTHON: "false"` is set at workflow level.
  Otherwise, a restored setup-pixi cache lacks the gitignored `python/<pkg>/_core.abi3.so`, pixi skips the rebuild, and the import fails.
  Old caches must be deleted by hand.
  To reproduce locally, delete the `.so` and run `pixi install`.
- crates.io Trusted Publishing only works for an existing crate, so the 0.0.0 publish is manual (see the README).
