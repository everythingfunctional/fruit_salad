FRUIT Salad
===========

This repository is intended as a starting point for Fortran projects, to make
it very easy to include testing as part of the project. The only requirements
are that gfortran, Ruby and Rake be installed in the development environment.

`rake -T` can be used to see the provided tasks, and `rake -P` can be used
to see how the system has detected the dependencies of your project.

Additionally, some scripts are provided as convenient way to run subsets of
tests or test suites. These scripts accept a regular expression to match
against the test names, and only these test suites or specific tests will be
executed.
