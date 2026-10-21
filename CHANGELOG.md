# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [0.1.5] - 2026-10-21

### Fixed

- Rerunning a release that failed partway failed again on the packages that were already uploaded; the publish tasks now skip existing files (`pixi upload prefix --skip-existing`, `uv publish --check-url`)

### Added

- `docs.yml` lets a running Pages deployment finish before starting the next one (`concurrency: pages`)
- A Troubleshooting entry for `ModuleNotFoundError: No module named '<package_name>._core'` in local environments

## [0.1.4] - 2026-10-21

### Fixed

- PyPI showed no license; `license = "MIT"` and `license-files = ["LICENSE"]` are now set in `pyproject.toml`
- The GitHub link printed by `pixi run release` used the package name instead of the repository name

### Removed

- The Rust cache from the `test` jobs of `test.yml`; Pixi builds the package in its own build directory, so the cache was never used

## [0.1.3] - 2026-10-20

### Fixed

- The tests failed on GitHub Actions with `ModuleNotFoundError: No module named '<package_name>._core'` whenever the Pixi environments were restored from the cache, since the compiled module of the editable install is not part of the cache; the workflows now install the package in non-editable mode (`BUILD_EDITABLE_PYTHON: "false"`), and caches created before this change must be deleted once

## [0.1.2] - 2026-10-20

### Fixed

- Clippy's pedantic `doc_markdown` lint failed the pre-commit hooks for package names with underscores, since the `CRATE.md` heading (the crate's documentation) named the package without backticks

## [0.1.1] - 2026-10-20

### Added

- The Rust API reference (`cargo doc`) in the documentation site, under "Rust API" in the navigation bar; `pixi run docs-rust` builds it on its own, and fails on rustdoc warnings
- `CRATE.md`, a short description of the Rust library, used as its crates.io page and as the landing page of its API reference (on docs.rs and the documentation site), with Rust code blocks run as doc tests
- The documentation site as the crate's `homepage` in `Cargo.toml`

### Fixed

- The PyPI page had no description, since maturin ignores Cargo.toml's readme when `pyproject.toml` has a `[project]` table; `readme = "README.md"` is now set in `pyproject.toml`

## [0.1.0] - 2026-10-20

### Added

- Documentation with Great Docs: `pixi run docs-build` and `pixi run docs-preview` build and preview the site, configured in `great-docs.yml`, and a docs workflow deploys it to GitHub Pages on every push to `main`
- The Great Docs agent skills (from great-docs v0.17.0) in `.claude/skills/`
- A `repo_name` question, used for `[project.urls]` in `pyproject.toml` (which adds links to the GitHub repository in the documentation site) and for `repository` in `Cargo.toml`
- A `pixi run copier-update` task, which runs `copier update` and commits the update if there are no conflicts, or else prints the conflicted files, the commands to commit, and a vimdiff cheat sheet
- `pixi run init` offers to set Git's merge tool to vimdiff, and ends with a reminder to link the documentation site under "About" on GitHub
- A pre-commit hook that fails on unresolved merge conflict markers and lists where they are (also for the template repository)
- A `pixi run stubs` task and pre-commit hook that generate the type stub of the compiled module (`_core.pyi`) from the Rust code, with PyO3's `experimental-inspect` feature and `maturin generate-stubs`

### Changed

- `_core.pyi` is now generated instead of hand-written, and includes docstrings (from the doc comments in `src/python.rs`, which are now in Google docstring style)
- `__version__` is exported with `#[pymodule_export]` instead of a `#[pymodule_init]` function, so that the generated stub is complete

## [0.0.2] - 2026-10-20

### Added

- Pre-commit hooks for the template repository (Ruff for the template test and actionlint for its workflows), and a `pixi run init` task to set up a clone

## [0.0.1] - 2026-10-20

### Added

- Initial release of the template, generating Pixi projects for Rust development with a Python interface, with:
  - A Rust library with Python bindings via PyO3, built by maturin, that is also usable as a plain Rust library
  - Optional Polars expression plugin setup
  - Packaging and release for Conda (prefix.dev) with Pixi, for PyPI with maturin-action and UV, and for crates.io with Cargo
  - Formatting and linting with rustfmt, Clippy, and Ruff, and static typing with Ty
  - Testing with `cargo test` and PyTest, with the newest and with the lowest compatible dependency versions
  - GitHub Actions workflow linting with actionlint
  - Git hooks with LeftHook
  - Versioning and release triggering with tbump
  - GitHub Actions workflows for testing and for publishing packages and GitHub releases
