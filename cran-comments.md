# Resubmission


Please add \value to .Rd files regarding exported methods and explain
the functions results in the documentation. Please write about the
structure of the output (class) and also what the output means. (If a
function does not return a value, please document that too, e.g.
\value{No return value, called for side effects} or similar)
Missing Rd-tags:
      parcats-shiny.Rd: \value
      parcats_demo.Rd: \value

\dontrun{} should only be used if the example really cannot be executed
(e.g. because of missing additional software, missing API keys, ...) by
the user. That's why wrapping examples in \dontrun{} adds the comment
("# Not run:") as a warning for the user. Does not seem necessary.
Please replace \dontrun with \donttest.
Please unwrap the examples if they are executable in < 5 sec, or replace
dontrun{} with \donttest{}.
-> man/parcats.Rd

- return value was added
- switched to donttest
- conditional execution of parcats example that requires suggested package

# parcats 0.0.5
Resubmit to CRAN after being archived.
Dependency 'easyalluvial' on CRAN again

## revdepcheck results
no reverse dependencies

## Test Environments
* local macOS M1 R 4.3.2
* github actions macos-latest R 4.3.2
* Rhub Windows Server 2022, R-devel, 64 bit
* WinBuilder R 4.3.2
* WinBuilder R devel

## Test Results

Maintainer: ‘Bjoern Koneswarakantha <datistics@gmail.com>’

New submission

Package was archived on CRAN

## Reverse Dependencies

no reverse dependencies
