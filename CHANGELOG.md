# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added

- The release workflow first checks that the version tag is on `main`, and stops otherwise, so that a tag on another branch can't publish a release.

### Changed

- The `prefix_channel` question also accepts a prefix.dev primary channel, which has no owner part: `<channel>` instead of `<owner>/<channel>`.

## [0.1.16] - 2026-11-09

### Changed

- `pixi run init` also sets up a clone of an existing project: in a directory that is already a Git repository, it skips `git init` and the initial commit (which used to commit any uncommitted changes) and doesn't print the commands for adding a remote

## [0.1.15] - 2026-11-09

### Added

- Floors in the `lowest` feature for old transitive packages that break `test-lowest` on Python 3.13 (`typing-extensions >=4.12`, `libstdcxx-ng >=13`), and PyPI wheels only (`no-build = true`), so that unbounded transitive PyPI dependencies don't resolve to ancient source releases.
- `.claude/rules/dependencies.md`, which tells Claude Code how to bound dependency versions: [SPEC 0](https://scientific-python.org/specs/spec-0000/) lower bounds for run dependencies, no upper bounds without a specific reason, and the newest versions of dev and test tools.

## [0.1.14] - 2026-11-02

### Added

- `.zed/settings.json`, which sets up Zed to match the pre-commit hooks: format on save with rustfmt and Ruff (which also sorts imports), Clippy checks with all features in rust-analyzer, and ty instead of basedpyright (see "Set Up Zed" in the README)

## [0.1.13] - 2026-10-30
### Changed
- The `prefix_channel` question asks for the full channel path, `<owner>/<channel>`, and rejects other values. A bare `<owner>` is not a channel, so publishing to it failed with `HTTP 403: Not authorized`.

## [0.1.12] - 2026-10-30

### Added

- A `conflicts` task (`pixi run conflicts`), which checks for unresolved merge conflict markers on its own, e.g. after a merge; the check is now in `scripts/conflicts.sh`, which the pre-commit hook and the `copier-update` instructions run directly, so that it also works when `pixi.toml` itself has conflicts

### Fixed

- The pre-commit hooks failed on a new project, because maturin 1.16 adds `__all__` to the generated type stub; the template's `_core.pyi` now includes it, and the `dev` environment requires `maturin >= 1.16`

## [0.1.11] - 2026-10-27

## [0.1.10] - 2026-10-22

### Fixed

- Rust tests failed to link with `unable to find library -lpython3.x` when run with the `python` feature, as rust-analyzer's Run/Debug buttons in VS Code do; the dev environment now sets `PYO3_BUILD_EXTENSION_MODULE`, so PyO3 no longer links libpython

## [0.1.9] - 2026-10-22

### Fixed

- Tombi warned that `pixi.toml` defines tables out of order; `[environments]` now comes before the `[feature.*]` tables, and `[feature.test.tasks]` follows `[feature.test.dependencies]`
- Clippy's `doc_markdown` lint failed on Google-style Python docstrings in `src/python.rs` whenever a parameter name contained an underscore; it is now allowed in that file
- Ruff's `PLR2004` (magic value) failed on literal expected values in tests; it is now ignored in `tests/`

## [0.1.8] - 2026-10-22

## [0.1.7] - 2026-10-22

### Added

- `.vscode/extensions.json`, which recommends rust-analyzer, the direnv extension, and Tombi (for TOML schemas), so that VS Code loads the Pixi `dev` environment from `.envrc` (see "Set Up VS Code" in the README), plus the Python (Ruff, ty), GitHub Actions, and YAML extensions
- `.vscode/settings.json`: format on save (rustfmt, Ruff), Clippy as rust-analyzer's checker, all Cargo features enabled so that `src/python.rs` is analyzed, ty instead of Pylance, and pytest in the Testing view (`test` environment)
- `rust-src` in the `dev` environment, which rust-analyzer needs to resolve the standard library

## [0.1.6] - 2026-10-22

### Added

- Lints from the [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/) in `Cargo.toml`: `missing_docs` (C-CRATE-DOC, C-EXAMPLE), `missing_debug_implementations` (C-DEBUG), and `clippy::cargo_common_metadata` (C-METADATA)
- A `rust-review` agent skill in `.claude/skills/`, which reviews Rust code against the Rust API Guidelines and the Rust Book's conventions for `use` paths and public APIs (the judgment calls that the lints can't make)
- `keywords` and `categories` questions, which fill in the crates.io metadata that `cargo_common_metadata` requires; `copier update` asks them once for existing projects

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
