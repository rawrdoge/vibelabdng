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
            dnglab,cameras)
                cmd="dnglab__subcmd__cameras"
                ;;
            dnglab,convert)
                cmd="dnglab__subcmd__convert"
                ;;
            dnglab,help)
                cmd="dnglab__subcmd__help"
                ;;
            dnglab,lenses)
                cmd="dnglab__subcmd__lenses"
                ;;
            dnglab,reembed)
                cmd="dnglab__subcmd__reembed"
                ;;
            dnglab__subcmd__convert,help)
                cmd="dnglab__subcmd__convert__subcmd__help"
                ;;
            dnglab__subcmd__convert,r)
                cmd="dnglab__subcmd__convert__subcmd__raw"
                ;;
            dnglab__subcmd__convert,raw)
                cmd="dnglab__subcmd__convert__subcmd__raw"
                ;;
            dnglab__subcmd__convert__subcmd__help,help)
                cmd="dnglab__subcmd__convert__subcmd__help__subcmd__help"
                ;;
            dnglab__subcmd__convert__subcmd__help,raw)
                cmd="dnglab__subcmd__convert__subcmd__help__subcmd__raw"
                ;;
            dnglab__subcmd__help,cameras)
                cmd="dnglab__subcmd__help__subcmd__cameras"
                ;;
            dnglab__subcmd__help,convert)
                cmd="dnglab__subcmd__help__subcmd__convert"
                ;;
            dnglab__subcmd__help,help)
                cmd="dnglab__subcmd__help__subcmd__help"
                ;;
            dnglab__subcmd__help,lenses)
                cmd="dnglab__subcmd__help__subcmd__lenses"
                ;;
            dnglab__subcmd__help,reembed)
                cmd="dnglab__subcmd__help__subcmd__reembed"
                ;;
            dnglab__subcmd__help__subcmd__convert,raw)
                cmd="dnglab__subcmd__help__subcmd__convert__subcmd__raw"
                ;;
            *)
                ;;
        esac
    done

    case "${cmd}" in
        dnglab)
            opts="-d -v -h -V --loglevel --profile-path --config --help --version convert reembed cameras lenses help"
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
                --profile-path)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        dnglab__subcmd__cameras)
            opts="-d -v -h --md --loglevel --profile-path --config --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
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
                --profile-path)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        dnglab__subcmd__convert)
            opts="-p -c -f -t -f -d -v -h --profile --compression --ljpeg92-predictor --lossy-jpeg-quality --jxl-distance --jxl-effort --jxl-decode-speed --dng-preview --dng-thumbnail --dng-force-preview --dng-force-thumbnail --max-dng-backward-version --embed-raw --apply-dng-opcodes --remove-dng-opcodes --artist --copyright --keep-mtime --image-index --crop --override --colorspace --render-steps --hide-steps --denoise --sharpen --sharpness-radius --saturation --contrast --highlight --blackpoint --gradient --tint --whitebalance-rgb --exposure --chromatic-aberration --vignetting --distorting --camera-profile --linearization --wb --white-xy --override --loglevel --profile-path --config --help raw r help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                --profile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -p)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --compression)
                    COMPREPLY=($(compgen -W "lossless lossy jxl deflate uncompressed" -- "${cur}"))
                    return 0
                    ;;
                -c)
                    COMPREPLY=($(compgen -W "lossless lossy jxl deflate uncompressed" -- "${cur}"))
                    return 0
                    ;;
                --ljpeg92-predictor)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --lossy-jpeg-quality)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --jxl-distance)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --jxl-effort)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --jxl-decode-speed)
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
                --dng-force-preview)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --dng-force-thumbnail)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --max-dng-backward-version)
                    COMPREPLY=($(compgen -W "1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.7.1" -- "${cur}"))
                    return 0
                    ;;
                --embed-raw)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --apply-dng-opcodes)
                    COMPREPLY=($(compgen -W "auto list1 list2 list3" -- "${cur}"))
                    return 0
                    ;;
                --remove-dng-opcodes)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --artist)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --copyright)
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
                --colorspace)
                    COMPREPLY=($(compgen -W "srgb adobergb prophoto" -- "${cur}"))
                    return 0
                    ;;
                --render-steps)
                    COMPREPLY=($(compgen -W "rescale demosaic fujirotate cropactivearea baselineexposure whitebalance autowhitebalance calibrate profilerender tonecurve cropdefault denoise defaultscale exposure autoexposure sharpen transferfunction" -- "${cur}"))
                    return 0
                    ;;
                --hide-steps)
                    COMPREPLY=($(compgen -W "rescale demosaic fujirotate cropactivearea baselineexposure whitebalance autowhitebalance calibrate profilerender tonecurve cropdefault denoise defaultscale exposure autoexposure sharpen transferfunction" -- "${cur}"))
                    return 0
                    ;;
                --denoise)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sharpen)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --sharpness-radius)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --saturation)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --contrast)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --highlight)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --blackpoint)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --gradient)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --tint)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --whitebalance-rgb)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --exposure)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --chromatic-aberration)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --vignetting)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --distorting)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --camera-profile)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --linearization)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                -t)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --wb)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --white-xy)
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
                --profile-path)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        dnglab__subcmd__convert__subcmd__help)
            opts="raw help"
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
        dnglab__subcmd__convert__subcmd__help__subcmd__help)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
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
        dnglab__subcmd__convert__subcmd__help__subcmd__raw)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
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
        dnglab__subcmd__convert__subcmd__raw)
            opts="-d -v -h --loglevel --profile-path --config --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
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
                --profile-path)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        dnglab__subcmd__help)
            opts="convert reembed cameras lenses help"
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
        dnglab__subcmd__help__subcmd__cameras)
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
        dnglab__subcmd__help__subcmd__convert)
            opts="raw"
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
        dnglab__subcmd__help__subcmd__convert__subcmd__raw)
            opts=""
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]] ; then
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
        dnglab__subcmd__help__subcmd__help)
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
        dnglab__subcmd__help__subcmd__lenses)
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
        dnglab__subcmd__help__subcmd__reembed)
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
        dnglab__subcmd__lenses)
            opts="-d -v -h --md --loglevel --profile-path --config --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
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
                --profile-path)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        dnglab__subcmd__reembed)
            opts="-d -v -h --dng --preview --output --embed-raw --compress --compression --crop --predictor --preview-enabled --thumbnail-enabled --artist --seed --loglevel --profile-path --config --help"
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
                --embed-raw)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --compression)
                    COMPREPLY=($(compgen -W "lossless lossy jxl deflate uncompressed" -- "${cur}"))
                    return 0
                    ;;
                --crop)
                    COMPREPLY=($(compgen -W "best activearea none" -- "${cur}"))
                    return 0
                    ;;
                --predictor)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --preview-enabled)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --thumbnail-enabled)
                    COMPREPLY=($(compgen -W "true false" -- "${cur}"))
                    return 0
                    ;;
                --artist)
                    COMPREPLY=($(compgen -f "${cur}"))
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
                --profile-path)
                    COMPREPLY=($(compgen -f "${cur}"))
                    return 0
                    ;;
                --config)
                    COMPREPLY=($(compgen -f "${cur}"))
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
