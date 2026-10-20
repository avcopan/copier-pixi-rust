# Pixi Rust Copier Template

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Pixi Badge](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/prefix-dev/pixi/main/assets/badge/v0.json)](https://pixi.sh)
[![Code style: ruff](https://img.shields.io/badge/code%20style-ruff-000000.svg)](https://github.com/astral-sh/ruff)
[![Typing: ty](https://img.shields.io/badge/typing-ty-EFC621.svg)](https://github.com/astral-sh/ty)
[![Copier](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/copier-org/copier/master/img/badge/badge-grayscale-border.json)](https://github.com/copier-org/copier)

A [copier](https://copier.readthedocs.io/) template for setting up [Pixi](https://pixi.sh/) projects for Rust development with a Python interface, using [PyO3](https://pyo3.rs/) and [maturin](https://www.maturin.rs/).
It is the Rust counterpart of [copier-pixi-python](https://github.com/avcopan/copier-pixi-python), and follows the same structure and conventions.
This is primarily for my own development.

## Features

- Rust library with Python bindings via [PyO3](https://pyo3.rs/), built by [maturin](https://www.maturin.rs/)
- Usable both as a Python package and as a plain Rust library (without any Python dependency)
- Optional [Polars expression plugin](https://docs.pola.rs/user-guide/plugins/expr_plugins/) setup
- Packaging and release for Conda with [Pixi](https://prefix.dev/)
- Packaging and release for PyPI with [maturin-action](https://github.com/PyO3/maturin-action) and [UV](https://docs.astral.sh/uv/)
- Packaging and release for [crates.io](https://crates.io/) with Cargo
- Formatting and linting with [rustfmt](https://github.com/rust-lang/rustfmt), [Clippy](https://doc.rust-lang.org/clippy/), and [Ruff](https://github.com/charliermarsh/ruff)
- Static typing with [Ty](https://github.com/astral-sh/ty)
- Testing with `cargo test` and [PyTest](https://docs.pytest.org/en/latest/)
- Code coverage with [PyTest-Cov](https://pytest-cov.readthedocs.io/en/latest/)
- GitHub Actions workflow linting with [actionlint](https://github.com/rhysd/actionlint)
- Git hooks with [LeftHook](https://lefthook.dev/)
- Versioning and release triggering with [tbump](https://github.com/your-tools/tbump)
- Continuous integration with [GitHub Actions](https://github.com/features/actions), including:
  - Linting, formatting, testing, etc.
  - Publishing Conda (prefix.dev), PyPI, and crates.io packages, using Trusted Publishing
  - Creating releases

All tools, including the Rust compiler, are installed from conda-forge by Pixi, so you do not need to install Rust with `rustup`.

## Instructions

### Install

First, install Pixi using the command shown [here](https://pixi.prefix.dev/latest/installation/).
Then install Copier as follows.

```sh
pixi global install copier
```

Optionally, you can also install [direnv](https://direnv.net/docs/installation.html) to automatically load your environment for you.

### Setup

#### Create Local Repository

Use the following command to create a new project from this template.

```sh
copier copy gh:avcopan/copier-pixi-rust <repo_name>
```

Copier will prompt you for the package name and other settings.
For `prefix_channel`, enter the prefix.dev channel to publish to (see
[below](#prepare-remote-github-repository)), as `<namespace>` or
`<namespace>/<channel>`.
Answer "yes" to the Polars question if you want to set up a
[Polars expression plugin](#polars-expression-plugins).

#### Prepare Remote GitHub Repository

Follow [these instructions](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository) to create an empty remote repository on GitHub (without a README, license, or `.gitignore`), using `<repo_name>` from above as its name.
Then set up package publication as follows, which is needed by the release workflow.

**Package publication.**
The release workflow publishes packages using
[Trusted Publishing](https://docs.pypi.org/trusted-publishers/), so no API tokens or
secrets are needed.
Instead, you tell each package index once that your repository's `release.yml`
workflow is allowed to publish to it.

- **Conda (prefix.dev).**
  Create a channel on [prefix.dev](https://prefix.dev/), if you do not have one yet
  (this is the `prefix_channel` from above), and then follow
  [these instructions](https://prefix.dev/docs/prefix/channels/access#configure-repository-access)
  to add Repository Access for GitHub, using the workflow filename `release.yml` and
  the Read/write mode.
- **PyPI.**
  Follow
  [these instructions](https://docs.pypi.org/trusted-publishers/creating-a-project-through-oidc/)
  to add a pending publisher on both [PyPI](https://pypi.org/) and
  [Test PyPI](https://test.pypi.org/), using your package name as the project name
  and the workflow name `release.yml`.
- **crates.io.**
  crates.io requires the crate to exist before Trusted Publishing can be set up, so
  after [initializing your repository](#initialize-local-repository), publish its
  initial `0.0.0` version once from your computer.
  Create an API token with the `publish-new` scope under `Account Settings > API Tokens`
  on [crates.io](https://crates.io/), and run the following.
  ```sh
  pixi run -e dev cargo login     # paste the token when prompted
  pixi run publish-crates
  pixi run -e dev cargo logout
  ```
  Then follow [these instructions](https://crates.io/docs/trusted-publishing) to add a
  GitHub publisher, using the workflow filename `release.yml`, and delete the token.
  Your releases will then be published to crates.io by the release workflow.
  If you do not want to publish to crates.io, delete the `publish-crates` job from
  [`release.yml`](template/.github/workflows/release.yml) and remove it from the
  `needs` list of the `release` job.

#### Initialize Local Repository

You are now ready to initialize your local repository by running the following.
```sh
pixi run init
```
This creates a Git repository, installs all Pixi environments (which builds your
package for the first time and creates the `Cargo.lock` file), makes an initial
commit, and installs the Git hooks.
It then prints the commands to add your GitHub repository as a remote and push to it.
Pushing triggers the test workflow, which you can check under the `Actions` tab of
your GitHub repository.

The init script also offers to set Pixi's
[pinning strategy](https://pixi.prefix.dev/latest/reference/pixi_configuration/#pinning-strategy)
to `latest-up` (for all your projects), so that `pixi add` adds lower bounds only,
like `uv add`.
These lower bounds are then checked by the `test-lowest` environment (see
[below](#run-pre-commit-hooks)).

For your first release, consider doing a [test release on Test PyPI](#publish-to-test-pypi).

### Usage

#### Where Code Goes

The Rust code lives in [`src/`](template/src/), as for any Rust project:

- [`src/lib.rs`](template/src/lib.rs.jinja) defines the public Rust API.
- [`src/greet.rs`](template/src/greet.rs.jinja) is an example module, including a
  unit test and a doc test.
- [`src/python.rs`](template/src/python.rs) defines the Python bindings: a
  `#[pymodule]` named `_core` that wraps Rust functions with `#[pyfunction]`.

The Python package lives in [`python/<package_name>/`](template/python/{{package_name}}/):

- [`__init__.py`](template/python/{{package_name}}/__init__.py.jinja) re-exports the
  public functions from the compiled `_core` module.
  Any Python-only code you need can be added next to it.
- [`_core.pyi`](template/python/{{package_name}}/_core.pyi) is a hand-written type stub
  describing the compiled module, so that Ty, Ruff, and editors know its signatures.
  **Whenever you add or change a `#[pyfunction]`, update this file to match.**
- [`py.typed`](template/python/{{package_name}}/py.typed) is an empty marker telling
  type checkers that the package ships type information.

To expose a new Rust function to Python, you therefore (1) write the Rust function,
(2) wrap it in `src/python.rs`, (3) add it to `_core.pyi`, and (4) re-export it in
`__init__.py`.

#### Manage Rust Dependencies

Rust dependencies can be added or removed with Cargo, which edits
[`Cargo.toml`](template/Cargo.toml.jinja).
```sh
pixi run -e dev cargo add <dependencies...>
pixi run -e dev cargo remove <dependencies...>
```
If a dependency is only needed for the Python bindings, make it optional and add it
to the `python` feature (see [here](#the-python-cargo-feature)), so that the plain
Rust library does not depend on it:
```sh
pixi run -e dev cargo add <dependency> --optional
```
Then add `"dep:<dependency>"` to the `python = [...]` list under `[features]` in
`Cargo.toml`.

#### Manage Python Run Dependencies

Python run dependencies can be added or removed as follows.
```sh
pixi run add <dependencies...>
pixi run remove <dependencies...>
```
Under the hood, these tasks use UV to
[manage dependencies](https://docs.astral.sh/uv/guides/projects/#managing-dependencies)
in the
[`pyproject.toml` file](template/pyproject.toml.jinja).
These dependencies are then
[mapped into Conda packages](https://pixi.prefix.dev/latest/build/backends/pixi-build-python/#automatic-pypi-dependency-mapping)
by Pixi.

#### Manage Dev Dependencies

Development dependencies can be added or removed from the Pixi `dev` environment as follows.
```sh
pixi add -f dev <development dependencies...>
pixi remove -f dev <development dependencies...>
```
You can also add tasks to the development environment as described
[here](https://pixi.prefix.dev/latest/workspace/advanced_tasks/).
These configurations go in the
[`pixi.toml` file](template/pixi.toml.jinja).

#### Manage Local Dependencies

This works exactly as in
[copier-pixi-python](https://github.com/avcopan/copier-pixi-python#manage-local-dependencies),
using `# local:true/false` markers in `pixi.toml` and the following tasks.
```sh
pixi run local start    # use local dependencies
pixi run local stop     # use published dependencies
```

#### Run Pre-Commit Hooks

If you have initialized with `pixi run init`, the pre-commit hooks should run with every commit.
You can also run them directly as follows.
```sh
pixi run pre-commit         # run pre-commit hooks
pixi run pre-commit-check   # run pre-commit hooks, except the tests
pixi run pre-commit-local   # run pre-commit hooks with local dependencies
```
These pre-commit hooks are [configured and run](https://lefthook.dev/configuration/run.html) using LeftHook.
To temporarily disable them, for example to make a work-in-progress commit, run
`pixi run hooks off` (and `pixi run hooks on` to re-enable them).
They run the following Pixi tasks, which you can also run individually:

- `fmt`: format Rust code with `cargo fmt` and Python code with `ruff format`
- `lint`: lint Rust code with `cargo clippy` (with the
  [pedantic](https://doc.rust-lang.org/clippy/lints.html) lint group, configured in
  `Cargo.toml`) and Python code with `ruff check`
- `types`: type check Python code with `ty check`
- `workflows`: lint the GitHub Actions workflows with
  [actionlint](https://github.com/rhysd/actionlint)
- `test-rs`: run Rust unit tests and doc tests with `cargo test`
- `test`: run Python tests with `pytest`, with the newest compatible dependency versions
- `test-lowest`: run Python tests with `pytest`, with the lowest versions allowed by your
  dependencies' lower bounds

#### Release New Versions

The following command shows the current version number.
```sh
pixi run version
```
Once you decide the appropriate next version number according to
[SemVer](https://semver.org/)
semantics, describe your changes under the `[Unreleased]` heading in `CHANGELOG.md`,
following the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.
Then trigger a release by running this command.
```sh
pixi run release <new version number>
```
This updates the version in `Cargo.toml` and `pixi.toml`, turns the `[Unreleased]`
section of `CHANGELOG.md` into an entry for the new version, updates `Cargo.lock` and
`pixi.lock`, and creates a release commit tagged with the new
version number, then pushes both the commit and the tag to GitHub.
(The version in `Cargo.toml` is the single source of truth: maturin passes it to the
Python package metadata, and the Rust code exposes it to Python as `__version__`.)

When the tag is pushed, it triggers the
[release workflow](template/.github/workflows/release.yml)
on GitHub Actions, which runs the following jobs:

- `test`: runs the test workflow, so that nothing is published unless the tests pass

- `build-conda`: builds the Conda package with `pixi run build-conda`
  ([`pixi publish --target-dir dist`](https://pixi.prefix.dev/latest/reference/cli/pixi/publish/))
- `build-pypi`: builds the wheel and source distribution with
  [maturin-action](https://github.com/PyO3/maturin-action) (see
  [here](#building-wheels-for-pypi) for why this does not use Pixi)
- `publish`: uploads the Conda package to prefix.dev with `pixi run publish-conda`
  ([`pixi upload prefix`](https://pixi.prefix.dev/latest/reference/cli/pixi/upload/prefix/))
  and the wheel and source distribution to PyPI with `pixi run publish-pypi` (`uv publish`)
- `publish-crates`: uploads the Rust crate to crates.io with `pixi run publish-crates`
  (`cargo publish`)
- `release`: posts the new release on GitHub, with the release notes taken from `CHANGELOG.md`

#### Publish to Test PyPI

The
[`release.yml` workflow file](template/.github/workflows/release.yml)
publishes to the actual PyPI by default.
To do a test release on Test PyPI instead, swap the commented line as follows:
```sh
# pixi run publish-pypi  <-- comment out for test release
pixi run publish-test-pypi  #      <-- uncomment for test release
```
No other changes are needed, as long as you have added a pending publisher on Test PyPI
as described [above](#prepare-remote-github-repository).
Remember to swap the lines back before your first real release.

### Updating Against Template Changes

To update your project against changes to this template, run the following in a
clean working tree.
```sh
copier update
```
Copier re-applies your saved answers (stored in `.copier-answers.yml`) to the latest
[released version](#releasing-the-template) of the template and merges the changes
into your project.
See [these instructions](https://copier.readthedocs.io/en/stable/updating/) for
details, including how to resolve conflicts.

To try out template changes that have not been released yet, update against the
latest commit instead.
```sh
copier update --vcs-ref=HEAD
```
Copier then warns `No git tags found in template; using HEAD as ref`, which is
expected here.

### Testing the Template

The template itself is tested by [`tests/test_template.py`](tests/test_template.py),
which runs as follows.
```sh
pixi run test
```
This generates a project (once with and once without the Polars plugin) with
[Copier's Python API](https://copier.readthedocs.io/en/stable/reference/main/),
runs its `pixi run init` and `pixi run pre-commit`, and then checks that the
working tree is clean.
This tests the setup and all pre-commit hooks of the generated project, including
`test`, `test-lowest`, and `workflows`, which lints its GitHub Actions workflows.
For the variant without the Polars plugin, the test then builds the conda package the
same way the release workflow does.
(The build is skipped with the plugin, because the optimized release build of Polars
is slow, and the plugin's code is already built and tested by the pre-commit hooks.)
Uncommitted changes to the template are included, so you can test changes before
committing them.
The test needs network access to install the project's environments.
The [test workflow](.github/workflows/test.yml) runs this test on GitHub Actions for
every push to the template repository, with both variants in parallel.

### Checking the Template

The template repository has its own pre-commit hooks, which are configured in
[`lefthook.yaml`](lefthook.yaml).
After cloning the repository, install them once as follows.
```sh
pixi run lefthook install
```
They run the following Pixi tasks, followed by a check that the working tree is clean:

- `fmt`: format the template test with `ruff format`
- `lint`: lint the template test with `ruff check`
- `workflows`: lint the GitHub Actions workflows with
  [actionlint](https://github.com/rhysd/actionlint)

Ruff only checks `tests/`, since the Python files in `template/` are checked in the
generated project by the template test.
The hooks do not run the template test itself, because it is slow.
You can also run them directly with `pixi run pre-commit`, and temporarily disable them
with `pixi run hooks off` (and re-enable them with `pixi run hooks on`).
The [test workflow](.github/workflows/test.yml) runs them on GitHub Actions for every
push to the template repository.

### Releasing the Template

The template is versioned and released in the same way as the generated projects (see
[above](#release-new-versions)).
The following command shows the current version number.
```sh
pixi run version
```
Describe your changes under the `[Unreleased]` heading in [`CHANGELOG.md`](CHANGELOG.md),
and then trigger a release by running this command.
```sh
pixi run release <new version number>
```
This updates the version in `pixi.toml`, turns the `[Unreleased]` section of
`CHANGELOG.md` into an entry for the new version, and creates a release commit tagged
with the new version number, then pushes both the commit and the tag to GitHub.
When the tag is pushed, it triggers the [release workflow](.github/workflows/release.yml),
which runs the template test and then posts the new release on GitHub, using the
`CHANGELOG.md` entry as the release notes.
Nothing is published to a package index.

`copier update` only picks up template changes once they are released, since it
updates projects to the latest tagged version (see [above](#updating-against-template-changes)).

### How It Works

This section explains the parts of the setup that are not self-explanatory.

#### Project Layout

The project is a single Rust crate (`Cargo.toml`, `src/`) that is also a Python
package (`pyproject.toml`, `python/`), following maturin's
["mixed Rust/Python project"](https://www.maturin.rs/project_layout.html#mixed-rustpython-project)
layout.
The Python code lives in `python/` rather than in the project root, as
[recommended by maturin](https://www.maturin.rs/project_layout.html#mixed-rustpython-project),
which serves the same purpose as the `src/` layout of a pure Python project: Python
cannot accidentally import the uninstalled package from the project root.

The compiled Rust code is placed inside the Python package as a private submodule,
`<package_name>._core`, by setting `module-name` under `[tool.maturin]` in
`pyproject.toml`.
This keeps the public API in `__init__.py`, which is also where Polars plugin
functions need to live (see [below](#polars-expression-plugins)).

#### The `python` Cargo Feature

All Python-specific code and dependencies (PyO3, and pyo3-polars for Polars plugins)
are behind a [Cargo feature](https://doc.rust-lang.org/cargo/reference/features.html)
named `python`, which is off by default and enabled by maturin
(`features = ["python"]` in `pyproject.toml`).
This has two benefits:

- The crate is also a plain Rust library: other Rust crates can depend on it (from
  crates.io, Git, or a local path) and call `<package_name>::greet` without depending
  on Python at all.
  This is why `Cargo.toml` builds both a `cdylib` (the Python extension module) and
  an `rlib` (the Rust library).
- `cargo test` works.
  If PyO3 were always enabled, the Rust test executables would need to link against
  `libpython`, which the Python packages from conda-forge do not provide.
  With the feature off, `cargo test` only builds the plain Rust code, while `pytest`
  tests the Python bindings.

The `lint` task runs Clippy with `--all-features`, so the Python bindings are linted too.

#### Building with Pixi

The package is built by the
[`pixi-build-python`](https://pixi.prefix.dev/latest/build/backends/pixi-build-python/)
backend, which runs maturin (because it is the `build-backend` in `pyproject.toml`).
As in copier-pixi-python, the package is listed as a dependency of the default
environment (`{{package_name}} = { path = "." }`), so that Pixi builds and installs it
into every environment.
During development, the package is installed in editable mode: maturin compiles the
Rust code (using the fast, unoptimized `dev` profile, because of `editable-profile =
"dev"`) and places the compiled module in `python/<package_name>/`, so changes to Python
files take effect immediately.
Changes to Rust files trigger an incremental rebuild the next time you use `pixi run`.

A few settings in [`pixi.toml`](template/pixi.toml.jinja) are needed to make this work
reliably:

- `abi3 = true` builds against the
  [Python stable ABI](https://docs.python.org/3/c-api/stable.html), together with the
  `abi3-py313` feature of PyO3 in `Cargo.toml`.
  The package is then compatible with every Python version from 3.13 on, so only one
  package needs to be built per platform.
- `compilers = ["rust"]` adds the Rust compiler to the build.
  The backend would detect this from maturin anyway, but listing it explicitly is what
  makes Pixi watch the `*.rs` and `Cargo.toml` files and rebuild when they change.
  (Without it, Rust changes are silently ignored.)
- `extra-input-globs = ["Cargo.lock", "!target/**"]` also rebuilds when `Cargo.lock`
  changes, but ignores files generated by Cargo in `target/`, which would otherwise
  cause unnecessary rebuilds.
- `CARGO_TARGET_DIR` points Cargo commands in the `dev` environment (`cargo fmt`,
  `cargo clippy`, `cargo test`) to `target/dev/`.
  The `dev` environment and the Pixi package build use different Rust toolchains, and
  if they shared the same build directory each one would invalidate the other's cache,
  forcing full rebuilds.

maturin's `locked = true` option is intentionally not used.
It would make every `pixi run` fail as soon as `Cargo.lock` is out of date (for example,
right after `tbump` changes the version in `Cargo.toml`), because Pixi rebuilds the
package before running any task.
Instead, maturin keeps `Cargo.lock` up to date during development, and the CI checks
use `cargo --locked` to make sure the committed `Cargo.lock` is current.

#### Building Wheels for PyPI

Wheels uploaded to PyPI for Linux must be
[manylinux](https://github.com/pypa/manylinux)-compatible, meaning they only use
system libraries old enough to be present on most Linux systems.
The standard way to guarantee this is to build them inside a manylinux container, which
is what [maturin-action](https://github.com/PyO3/maturin-action) does.
This is why the PyPI packages are built by maturin-action rather than by Pixi.
Because of the stable ABI, a single wheel works for all supported Python versions.

### Polars Expression Plugins

[Polars expression plugins](https://docs.pola.rs/user-guide/plugins/expr_plugins/) are
Rust functions that Polars calls directly on its own data, without going through Python.
Polars loads them from the compiled library at runtime, so they do not need to be
registered in the `#[pymodule]`.

If you answered "yes" to the Polars question, the template adds:

- the [`pyo3-polars`](https://crates.io/crates/pyo3-polars) and `polars` crates as
  optional dependencies in `Cargo.toml` (part of the `python` feature), and `polars` as a
  Python dependency in `pyproject.toml`
- `src/expressions.rs` (in [`src/`](template/src/)), with an example `#[polars_expr]` function `greet_expr`
- a global memory allocator in `src/lib.rs`, which Polars plugins are required to use
- `python/<package_name>/_plugins.py` (in [`python/<package_name>/`](template/python/{{package_name}}/)), with a Python function that calls the Rust function through
  [`register_plugin_function`](https://docs.pola.rs/api/python/stable/reference/plugins.html),
  pointing Polars at the package directory (where the compiled library is)
- a test that uses the plugin in a Polars query

To add a plugin to a project that was created without one, make the same changes by
hand, using the files in this template as a reference.
For more examples, see the
[Polars plugins tutorial](https://marcogorelli.github.io/polars-plugins-tutorial/).

**Keeping versions aligned.**
`pyo3-polars` depends on specific versions of `pyo3` and `polars`, so these three
versions must be updated together in `Cargo.toml`.
For example, `pyo3-polars` 0.28 requires `pyo3` 0.29 and `polars` 0.55, which is why
this template uses `pyo3` 0.29 even though newer versions exist.

### Troubleshooting

**The compiled module is out of date.**
Due to a Cargo quirk with `cdylib` libraries, switching back to a previously built
configuration (for example, checking out an older branch with a different version or
dependencies in `Cargo.toml`) can leave the old compiled module in place.
If your Python code does not reflect your Rust code, clear the Cargo build directory and
the Pixi build cache and reinstall:
```sh
rm -rf target
pixi clean --build
pixi install --all
```

### Using Pixi on an HPC Cluster

See the corresponding section of the
[copier-pixi-python README](https://github.com/avcopan/copier-pixi-python#using-pixi-on-an-hpc-cluster).
To also move the Rust build directory to a faster filesystem, you can set
`CARGO_TARGET_DIR` in `pixi.toml` to a path on that filesystem.

## License

This project is licensed under the [MIT License](LICENSE).
