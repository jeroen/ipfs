#' IPNS name
#'
#' IPNS is a PKI namespace, where names are the hashes of public keys, and
#' the private key enables publishing new (signed) values. In publish, the
#' default value of <name> is your own identity public key.
#'
#' @export
#' @rdname ipns
#' @references \url{https://github.com/ipfs/examples/tree/master/examples/ipns#readme}
#' @param name the IPNS name (owner) to resolve. Defaults to your own name
#' @param recursive resolve until the result is not an IPNS name
#' @param nocache do not use cached entries
ipfs_resolve <- function(name = NULL, recursive = FALSE, nocache = FALSE){
  out <- if(is.null(name)){
    ipfs_json("name/resolve", recursive = recursive, nocache = nocache)
  } else {
    ipfs_json("name/resolve", arg = name, recursive = recursive, nocache = nocache)
  }
  out$Path
}

#' @export
#' @rdname ipns
#' @param path  IPFS path of the object to be published under your name
#' @param lifetime Time duration that the record will be valid for. This accepts
#' durations such as "300s", "1.5h" or "2h45m".
#' @examples # Default resolves your own identity:
#' ipfs_resolve()
#' ipfs_resolve("QmaCpDMGvV2BGHeYERUEnRQAwe3N8SzbUtfsmvsqQLuvuJ")
#' ipfs_resolve('ipfs.io')
ipfs_publish <- function(path, lifetime = "24h"){
  ipfs_json("name/publish", arg = path, lifetime = lifetime)
}
