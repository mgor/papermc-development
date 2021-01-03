#!/usr/bin/env bash
# shellcheck disable=SC2164

pushd() {
    command pushd "$1" &> /dev/null || exit 1
}

popd() {
    command popd &> /dev/null || exit 1
}

fix_j2se_5_warn() {
    while IFS= read -r -d '' classpath; do
        sed -ri 's|J2SE-1.5|JavaSE-1.8|g' "${classpath}"
        git update-index --assume-unchanged "${classpath}"
    done < <(find . -type f -name '.classpath')
}

ensure_repositories() {
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

    git config --global user.email "${user_email}"
    git config --global user.name "${user_name}"

    if [[ ! -d Paper/ ]]; then
        git clone https://github.com/PaperMC/Paper.git || return $?
    else
        pushd Paper/
        if [[ -d .git/ ]]; then
            git checkout master
            git reset --hard HEAD
            git pull --rebase || return $?
        fi
        popd
    fi

    if [[ ! -d Paperclip/ ]]; then
        git clone git@github.com:mgor/Paperclip.git || return $?
    else
        pushd Paperclip/
        git stash
        git pull --rebase || return $?
        git stash pop
        popd
    fi

    fix_j2se_5_warn
}
