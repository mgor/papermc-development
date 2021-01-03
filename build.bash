#!/usr/bin/env bash
# shellcheck disable=SC2164,SC1091

. ./PaperDevelopment/common.bash

main() {
    local mcver vanillajar paperjar
    local paperclip_input_jars

    if [[ -d Paper/ || -d Paperclip/ ]]; then
        ensure_repositories
    fi

    paperclip_input_jars="$(find Paperclip/ -maxdepth 1 -name '*.jar' | wc -l)"

    if (( paperclip_input_jars < 2 )); then
        pushd Paper/

        for module in work/*; do
            pushd "${module}"
            git checkout master
            if git branch | grep -q 'patched' &> /dev/null; then
                git branch -D patched
            fi
            git reset --hard HEAD
            popd
        done

        ./paper jar
        popd

        find Paper/Paper-Server/target -maxdepth 1 -follow -type f -name 'paper*.jar' -exec cp {} Paperclip/ \;
        find Paper/work/Minecraft/current -maxdepth 1 -follow -type f -name '*.jar' -and -not -name '*-*.jar' -exec cp {} Paperclip/ \;
    fi

    fix_j2se_5_warn

    pushd Paperclip/
    for jar in *.jar; do
        if [[ "${jar}" == "paper-"*".jar" ]]; then
            paperjar="${jar}"
        else
            vanillajar="${jar}"
        fi
    done
    mcver="${vanillajar%.jar}"

    echo "paperjar = ${paperjar}"
    echo "vanillajar = ${vanillajar}"
    echo "mcver = ${mcver}"

    mvn -Dpaperjar="$(realpath "${paperjar}")" -Dvanillajar="$(realpath "${vanillajar}")" -Dmcver="${mcver}" clean package || { >&2 echo "failed to build paperclip"; return 1; }
    popd

    cp "Paperclip/assembly/target/paperclip-${mcver}.jar" server.jar

    return $?
}

main "$@"
exit $?
