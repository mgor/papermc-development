#!/usr/bin/env bash
# shellcheck disable=SC2164,SC1091

. ./PaperDevelopment/common.bash

main() {
    ensure_repositories

    code papermc.code-workspace

    return $?
}

main "$@"
exit $?
