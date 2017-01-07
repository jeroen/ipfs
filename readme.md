# IPFS

> Connect to the Inter Planetary File System

[![Build Status](https://travis-ci.org/jeroenooms/ipfs.svg?branch=master)](https://travis-ci.org/jeroenooms/ipfs)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/jeroenooms/ipfs?branch=master&svg=true)](https://ci.appveyor.com/project/jeroenooms/ipfs)
[![Coverage Status](https://codecov.io/github/jeroenooms/ipfs/coverage.svg?branch=master)](https://codecov.io/github/jeroenooms/ipfs?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/ipfs)](http://cran.r-project.org/package=ipfs)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/ipfs)](http://cran.r-project.org/web/packages/ipfs/index.html)
[![Github Stars](https://img.shields.io/github/stars/jeroenooms/ipfs.svg?style=social&label=Github)](https://github.com/jeroenooms/ipfs)

## Installation

Install from Github:

```r
devtools::install_github("jeroenooms/ipfs")
```

The installer should automatically download the `ipfs` program.

## Getting Started

First start the `ipfs` server daemon 

```r
# Start the server in the background
ipfs_daemon()

# Check server status:
ipfs_info()
```

You are now connected to the inter-planetary file system! Download some files:

```r
ipfs_get('QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG')
ipfs_data('QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme')
ipfs_download('QmR7GSQM93Cx5eAg6a6yRzNde1FQv7uL6X1o4k7zrJa3LX/ipfs.draft3.pdf')
utils::browseURL('ipfs.draft3.pdf')
```

Or publish a file of your own!

```r
# Publish a file!
writeLines("Hi there!", tmp <- tempfile())
out <- ipfs_add(tmp)
ipfs_browse(out$hash)
```

See the `?ipfs` and `?ipns` help pages for more information.
