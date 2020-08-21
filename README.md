# rCTF

[rCTF][rctf] is redpwnCTF's CTF platform.

This chart bootstraps an rCTF deployment on a [Kubernetes][k8s] Cluster using
the [Helm][helm] package manager. It requires both a [PostgreSQL][postgres]
server and a [Redis][redis] server to connect to; connection parameters are set
in the `postgres` and `redis` values, respectively.

Since rCTF is currently under active development and does not yet have tagged
versions, this chart also does not have version numbers. The tag of the image in
the chart `image.tag` will be updated on breaking changes only, and `master` of
this repository will be in sync with `master` of rCTF.

[rctf]: https://github.com/redpwn/rctf
[k8s]: https://kubernetes.io
[helm]: https://helm.sh
[postgres]: https://www.postgresql.org
[redis]: https://redis.io
