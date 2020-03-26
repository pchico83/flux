#!/usr/bin/env bash

set -o errexit

# This script runs the bats tests

# Directory paths we need to be aware of
FLUX_ROOT_DIR="$(git rev-parse --show-toplevel)"
E2E_DIR="${FLUX_ROOT_DIR}/test/e2e"
CACHE_DIR="${FLUX_ROOT_DIR}/cache/$CURRENT_OS_ARCH"

KIND_VERSION=v0.7.0
KUBE_VERSION=v1.14.10
GITSRV_VERSION=v1.0.0
KIND_CACHE_PATH="${CACHE_DIR}/kind-$KIND_VERSION"
KIND_CLUSTER_PREFIX=flux-e2e
BATS_EXTRA_ARGS=""

sudo mv "$(go env GOPATH)/bin/fluxctl" "/usr/local/bin/fluxctl"

# shellcheck disable=SC1090
source "${E2E_DIR}/lib/defer.bash"
trap run_deferred EXIT

mkdir -p "${FLUX_ROOT_DIR}/cache"
curl -sL "https://github.com/fluxcd/gitsrv/releases/download/${GITSRV_VERSION}/known_hosts.txt" > "${FLUX_ROOT_DIR}/cache/known_hosts"

kind load docker-image 'docker.io/fluxcd/flux:latest'

echo '>>> Running the tests'
# Run all tests by default but let users specify which ones to run, e.g. with E2E_TESTS='11_*' make e2e
E2E_TESTS=${E2E_TESTS:-.}
(
  cd "${E2E_DIR}"
  # shellcheck disable=SC2086
  "${E2E_DIR}/bats/bin/bats" -t ${BATS_EXTRA_ARGS} ${E2E_TESTS}
)
