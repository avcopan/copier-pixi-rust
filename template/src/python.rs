use pyo3::prelude::*;

/// The compiled Python module, imported as `<package_name>._core`.
#[pymodule]
mod _core {
    use pyo3::prelude::*;

    #[pymodule_init]
    fn init(m: &Bound<'_, PyModule>) -> PyResult<()> {
        m.add("__version__", env!("CARGO_PKG_VERSION"))
    }

    /// Greet a person by their name.
    #[pyfunction]
    fn greet(name: &str) -> String {
        crate::greet(name)
    }
}
