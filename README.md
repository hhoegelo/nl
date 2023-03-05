# playground for experiments with the build system for Nonlinear Labs software

The c15 repo ist quite messed up regarding different aproaches of cross building, integration of docker, caching of sources etc. 
This repo exists to try out different ways of integrating the NL software projects into a build system layed out on a clean slate.

The build system should solve:
- cross builds for epc, beaglebone, raspi, playcontroller and supervisor
- caching of online resources for faster builds
- building iso images, update and binaries for development pc
- integration of build-system-time configuration


Todos:
- pi4
- develop environments
- package update and attach scripts