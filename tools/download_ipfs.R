# Downloads the 'ipfs' utility from: https://ipfs.io/docs/install
# Supports Linux, OSX and Windows
if(file.exists("inst/bin/go-ipfs/ipfs") || file.exists("inst/bin/go-ipfs/ipfs.exe")){
  quit("no")
}

# Find binaries for your system
platform <- sessionInfo()$platform

# Case of Windows
if(grepl("mingw", platform, ignore.case = TRUE)){
  if(getRversion() < "3.3.0") setInternet2()
  download.file("https://dist.ipfs.io/go-ipfs/v0.4.4/go-ipfs_v0.4.4_windows-386.zip", "ipfs.zip")
  dir.create("inst/bin", showWarnings = FALSE, recursive = TRUE)
  unzip("ipfs.zip",files = "go-ipfs/ipfs.exe", exdir = "inst/bin")
  unlink("ipfs.zip")
  quit("no")
}

url <- if(grepl("x86_64.*darwin", platform, ignore.case = TRUE)){
  "https://dist.ipfs.io/go-ipfs/v0.4.4/go-ipfs_v0.4.4_darwin-amd64.tar.gz"
} else if(grepl("x86_64.*linux", platform, ignore.case = TRUE)){
  "https://dist.ipfs.io/go-ipfs/v0.4.4/go-ipfs_v0.4.4_linux-amd64.tar.gz"
} else if(grepl("freebsd", platform, ignore.case = TRUE)){
  "https://dist.ipfs.io/go-ipfs/v0.4.4/go-ipfs_v0.4.4_freebsd-amd64.tar.gz"
} else {
  cat("Unknown platform!")
  quit("no")
}

download.file(url, "ipfs.tar.gz")
dir.create("inst/bin", showWarnings = FALSE, recursive = TRUE)
untar("ipfs.tar.gz", files = "go-ipfs/ipfs", exdir = "inst/bin")
unlink("ipfs.tar.gz")
