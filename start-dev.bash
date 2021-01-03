#!/usr/bin/env bash
# shellcheck disable=SC2164

pushd() {
    command pushd "$1" &> /dev/null || exit 1
}

popd() {
    command popd &> /dev/null || exit 1
}

main() {
    local user_name user_email
    user_name="$(git config user.name)"
    user_email="$(git config user.email)"

    if [[ -z "${user_name}" || -z "${user_email}" ]]; then
        cat <<EOF
Please tell me who you are.

Run

    git config user.email "you@example.com"
    git config user.name "Your Name"
EOF
    fi

    if [[ ! -d Paper/ ]]; then
        git clone https://github.com/PaperMC/Paper.git || return $?
        pushd Paper/
        git config user.email "${user_email}"
        git config user.name "${user_name}"
        popd
    else
        pushd Paper/
        git pull --rebase
        popd
    fi

    if [[ ! -d Paperclip/ ]]; then
        git clone git@github.com:mgor/Paperclip.git || return $?
        pushd Paperclip/
        git config user.email "${user_email}"
        git config user.name "${user_name}"
        popd
    else
        pushd Paper/
        git pull --rebase
        popd
    fi

    code papermc.code-workspace

    return $?
}

main "$@"
exit $?
