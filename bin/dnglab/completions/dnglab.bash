_dnglab() {
    local i cur prev opts cmd
    COMPREPLY=()
    if [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
        cur="$2"
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
    fi
    prev="$3"
    cmd=""
    opts=""

    for i in "${COMP_WORDS[@]:0:COMP_CWORD}"
    do
        case "${cmd},${i}" in
            ",$1")
                cmd="dnglab"
                ;;
            dnglab,convert)
                cmd="dnglab__convert"
                ;;
            dnglab,help)
                cmd="dnglab__help"
                ;;
            dnglab,reembed)
                cmd="dnglab__reembed"
                ;;
            dnglab__help,convert)
                cmd="dnglab__help__convert"
                ;;
            dnglab__help,help)
                cmd="dnglab__help__help"
                ;;
            dnglab__help,reembed)
                cmd="dnglab__help__reembed"
                ;;
            *)
                ;;
        esac
    done

    case "${cmd}" in
        dnglab)
            opts="-d -v -h -V --loglevel --help --version convert reembed help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --loglevel)
                    COMPREPLY=($(compgen -W "error warn info debug trace" -- "${cur}"))
                    return 0
                    ;;
                -d)
                    COMPREPLY=($(compgen -W "error warn info debug trace" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        dnglab__convert)
            opts="-c -f -r -j -d -v -h --compression --ljpeg92-predictor --dng-preview --dng-thumbnail --embed-raw --artist --keep-mtime --image-index --crop --override --recursive --jobs --dng-version --preview-medium --preview-full --jpeg-quality --linear --seed --input --output --loglevel --help [INPUT] [OUTPUT]"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --compression)
                    COMPREPLY=($(compgen -W "lossless uncompressed" -- "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -W "lossless uncompressed" -- "${cur}"))
                    return 0
                    ;;
                --ljpeg92-predictor)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --dng-preview)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --dng-thumbnail)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --embed-raw)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --artist)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --keep-mtime)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --image-index)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --crop)
                    COMPREPLY=($(compgen -W "best activearea none" -- "${cur}"))
                    return 0
                    ;;
                --jobs)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -j)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --dng-version)
                    COMPREPLY=($(compgen -W "v1-4 v1-5 v1-6" -- "${cur}"))
                    return 0
                    ;;
                --preview-medium)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --preview-full)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --jpeg-quality)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --linear)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --seed)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --input)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --output)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --loglevel)
                    COMPREPLY=($(compgen -W "error warn info debug trace" -- "${cur}"))
                    return 0
                    ;;
                -d)
                    COMPREPLY=($(compgen -W "error warn info debug trace" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        dnglab__help)
            opts="convert reembed help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        dnglab__help__convert)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        dnglab__help__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        dnglab__help__reembed)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        dnglab__reembed)
            opts="-c -f -d -v -h --dng --preview --output --compression --ljpeg92-predictor --artist --crop --dng-preview --dng-thumbnail --embed-raw --compress --override --seed --loglevel --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --dng)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --preview)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --output)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --compression)
                    COMPREPLY=($(compgen -W "lossless uncompressed" -- "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -W "lossless uncompressed" -- "${cur}"))
                    return 0
                    ;;
                --ljpeg92-predictor)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --artist)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --crop)
                    COMPREPLY=($(compgen -W "best activearea none" -- "${cur}"))
                    return 0
                    ;;
                --dng-preview)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --dng-thumbnail)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --embed-raw)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --seed)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --loglevel)
                    COMPREPLY=($(compgen -W "error warn info debug trace" -- "${cur}"))
                    return 0
                    ;;
                -d)
                    COMPREPLY=($(compgen -W "error warn info debug trace" -- "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
    esac
}

if [[ "${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -ge 4 || "${BASH_VERSINFO[0]}" -gt 4 ]]; then
    complete -F _dnglab -o nosort -o bashdefault -o default dnglab
else
    complete -F _dnglab -o bashdefault -o default dnglab
fi
