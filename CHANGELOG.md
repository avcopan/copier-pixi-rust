# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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
