shim_system_file <- function(package) {
  imports <- parent.env(asNamespace(package))
  pkgload:::unlock_environment(imports)
  imports$system.file <- pkgload:::shim_system.file
}

shim_system_file("htmlwidgets")
shim_system_file("htmltools")

# After the code above has been run, you can load an in-development package
# that uses htmlwidgets (like dygraphs or leaflet). After being loaded this way,
# When the JS or CSS resources of the package are edited, they'll immediately
# be available, without having to build and install the package.
devtools::load_all()

