#!/usr/bin/env bash
# shellcheck disable=SC2164,SC1091

. ./PaperDevelopment/common.bash

main() {
    ensure_repositories

    local paperclip_input_jars
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

    local mcver vanillajar paperjar
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

    mvn -Dpaperjar="$(realpath "${paperjar}")" -Dvanillajar="$(realpath "${vanillajar}")" -Dmcver="${mcver}" clean package
    popd

    cp "assembly/target/paperclip-${mcver}.jar" server.jar

    return $?
}

main "$@"
exit $?
