Continuous Integration
===========

We are currently using Jenkins to run our CI with the aim to eventually switch to Travis when it adds Xcode 6 support. The vast majority of the CI work is done in our Makefile. Here's the commands being ran inside Jenkins itself:

``` shell
#!/bin/bash

source ~/.bash_profile
rm -rf /Users/joe/Library/Developer/Xcode/DerivedData
security unlock-keychain -p [username] /Users/joe/Library/Keychains/jenkins.keychain

make prepare_ci
make ci

```

Under the hood we set the Xcode to the beta, run a build setup task, then a run task and switch back to the Xcode stable release. The reason for differentiating between building and testing in our steps is to reduce verbosity in reading the log in travis. 