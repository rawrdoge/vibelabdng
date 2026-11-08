# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_dnglab_global_optspecs
    string join \n d/loglevel= v profile-path= config= h/help V/version
end

function __fish_dnglab_needs_command
    # Figure out if the current invocation already has a command.
    set -l cmd (commandline -opc)
    set -e cmd[1]
    argparse -s (__fish_dnglab_global_optspecs) -- $cmd 2>/dev/null
    or return
    if set -q argv[1]
        # Also print the command, so this can be used to figure out what it is.
        echo $argv[1]
        return 1
    end
    return 0
end

function __fish_dnglab_using_subcommand
    set -l cmd (__fish_dnglab_needs_command)
    test -z "$cmd"
    and return 1
    contains -- $cmd[1] $argv
end

complete -c dnglab -n "__fish_dnglab_needs_command" -s d -l loglevel -d 'Log level' -r -f -a "error\t''
warn\t''
info\t''
debug\t''
trace\t''"
complete -c dnglab -n "__fish_dnglab_needs_command" -l profile-path -d 'Directory with profile TOML files' -r -F
complete -c dnglab -n "__fish_dnglab_needs_command" -l config -d 'dnglab configuration file' -r -F
complete -c dnglab -n "__fish_dnglab_needs_command" -s v -d 'Print status for every file'
complete -c dnglab -n "__fish_dnglab_needs_command" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c dnglab -n "__fish_dnglab_needs_command" -s V -l version -d 'Print version'
complete -c dnglab -n "__fish_dnglab_needs_command" -f -a "convert" -d 'Convert raw image(s) into dng format'
complete -c dnglab -n "__fish_dnglab_needs_command" -f -a "reembed" -d 'Re-embed edited preview into an existing DNG'
complete -c dnglab -n "__fish_dnglab_needs_command" -f -a "cameras" -d 'List supported cameras'
complete -c dnglab -n "__fish_dnglab_needs_command" -f -a "lenses" -d 'List supported lenses'
complete -c dnglab -n "__fish_dnglab_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -s p -l profile -d 'Convert profile name' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -s c -l compression -d 'Compression for raw image' -r -f -a "lossless\t''
lossy\t''
jxl\t''
deflate\t''
uncompressed\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l ljpeg92-predictor -d 'LJPEG-92 predictor' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l lossy-jpeg-quality -d 'JPEG quality for lossy compression (1-100)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l jxl-distance -d 'JPEG XL distance (0-25), 0 is lossless' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l jxl-effort -d 'JPEG XL encoder effort (1-9)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l jxl-decode-speed -d 'JPEG XL decoding speed for lossy compression (1-4)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l dng-preview -d 'DNG include preview image' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l dng-thumbnail -d 'DNG include thumbnail image' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l dng-force-preview -d 'Generate DNG preview image from raw data' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l dng-force-thumbnail -d 'Generate DNG thumbnail image from raw data' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l max-dng-backward-version -d 'Maximum DNG backward version' -r -f -a "1.0\t''
1.1\t''
1.2\t''
1.3\t''
1.4\t''
1.5\t''
1.6\t''
1.7\t''
1.7.1\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l embed-raw -d 'Embed the raw file into DNG' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l apply-dng-opcodes -d 'Apply DNG opcode lists to the image data instead of writing them to the DNG' -r -f -a "auto\t''
list1\t''
list2\t''
list3\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l remove-dng-opcodes -d 'Remove DNG opcodes, as comma separated [<list>:]<opcode> (e.g. WarpRectilinear,2:GainMap)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l artist -d 'Set the artist tag' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l copyright -d 'Set the copyright tag' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l keep-mtime -d 'Keep mtime, read from EXIF with fallback to original file mtime' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l image-index -d 'Select a specific image index (or \'all\') if file is a image container' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l crop -d 'DNG default crop' -r -f -a "best\t''
activearea\t''
none\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l colorspace -d 'Colorspace of resulting DNG image' -r -f -a "srgb\t''
adobergb\t''
prophoto\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l render-steps -d 'Render pipeline steps' -r -f -a "rescale\t''
demosaic\t''
fujirotate\t''
cropactivearea\t''
baselineexposure\t''
whitebalance\t''
autowhitebalance\t''
calibrate\t''
profilerender\t''
tonecurve\t''
cropdefault\t''
denoise\t''
defaultscale\t''
exposure\t''
autoexposure\t''
sharpen\t''
transferfunction\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l hide-steps -d 'Hide render pipeline steps' -r -f -a "rescale\t''
demosaic\t''
fujirotate\t''
cropactivearea\t''
baselineexposure\t''
whitebalance\t''
autowhitebalance\t''
calibrate\t''
profilerender\t''
tonecurve\t''
cropdefault\t''
denoise\t''
defaultscale\t''
exposure\t''
autoexposure\t''
sharpen\t''
transferfunction\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l denoise -d 'Amount of denoising applied to rendered image (0.00..=4.00)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l sharpen -d 'Amount of sharpening applied to rendered image (0.00..=2.00)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l sharpness-radius -d 'Radius in px of sharpening mask' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l saturation -d 'Change hue and saturation of the rendered image' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l contrast -d 'Change the exposure (+EV) and contrast of the rendered image' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l highlight -d 'Recover highlights (0.00..=1.00)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l blackpoint -d 'Adjust blackpoint (0.0..=1.0)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l gradient -d 'Tint the gradient along a certain axis (x y)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l tint -d 'Set white balance via temperature/tint' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l whitebalance-rgb -d 'Manual whitebalance RGB values' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l exposure -d 'Additional manual exposure adjustment in EV' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l chromatic-aberration -d 'Correct chromatic aberration (0.00..=1.00)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l vignetting -d 'Correct vignetting (0.00..=1.00)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l distorting -d 'Correct distortion (0.00..=1.00)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l camera-profile -d 'Set custom camera profile' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -s t -l linearization -d 'Linearization table' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l wb -d 'Whitebalance as-shot' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l white-xy -d 'Whitebalance as-shot encoded as xy chromaticity coordinates' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -s d -l loglevel -d 'Log level' -r -f -a "error\t''
warn\t''
info\t''
debug\t''
trace\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l profile-path -d 'Directory with profile TOML files' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -l config -d 'dnglab configuration file' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -s f -l override -d 'Override existing files'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -s f -l override -d 'Override existing files'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -s v -d 'Print status for every file'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -a "raw" -d 'Convert raw images to DNG (deprecated: same as convert)'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -a "r" -d 'Convert raw images to DNG (deprecated: same as convert)'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and not __fish_seen_subcommand_from raw r help" -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and __fish_seen_subcommand_from raw" -s d -l loglevel -d 'Log level' -r -f -a "error\t''
warn\t''
info\t''
debug\t''
trace\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and __fish_seen_subcommand_from raw" -l profile-path -d 'Directory with profile TOML files' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and __fish_seen_subcommand_from raw" -l config -d 'dnglab configuration file' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and __fish_seen_subcommand_from raw" -s v -d 'Print status for every file'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and __fish_seen_subcommand_from raw" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and __fish_seen_subcommand_from r" -s d -l loglevel -d 'Log level' -r -f -a "error\t''
warn\t''
info\t''
debug\t''
trace\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and __fish_seen_subcommand_from r" -l profile-path -d 'Directory with profile TOML files' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and __fish_seen_subcommand_from r" -l config -d 'dnglab configuration file' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and __fish_seen_subcommand_from r" -s v -d 'Print status for every file'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and __fish_seen_subcommand_from r" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and __fish_seen_subcommand_from help" -f -a "raw" -d 'Convert raw images to DNG (deprecated: same as convert)'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l dng -d 'Input DNG file' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l preview -d 'Edited preview JPEG' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l output -d 'Output DNG (default: overwrite input)' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l embed-raw -d 'Embed original raw file' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l compression -d 'Compression method for raw image' -r -f -a "lossless\t''
lossy\t''
jxl\t''
deflate\t''
uncompressed\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l crop -d 'Crop mode: best, activearea, none' -r -f -a "best\t''
activearea\t''
none\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l predictor -d 'LJPEG92 predictor (1-7)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l preview-enabled -d 'Include preview in output DNG' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l thumbnail-enabled -d 'Include thumbnail in output DNG' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l artist -d 'Set artist tag' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l seed -d 'Deterministic seed for output bytes' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -s d -l loglevel -d 'Log level' -r -f -a "error\t''
warn\t''
info\t''
debug\t''
trace\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l profile-path -d 'Directory with profile TOML files' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l config -d 'dnglab configuration file' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l compress -d 'Use lossless compression'
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -s v -d 'Print status for every file'
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c dnglab -n "__fish_dnglab_using_subcommand cameras" -s d -l loglevel -d 'Log level' -r -f -a "error\t''
warn\t''
info\t''
debug\t''
trace\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand cameras" -l profile-path -d 'Directory with profile TOML files' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand cameras" -l config -d 'dnglab configuration file' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand cameras" -l md -d 'Markdown format output'
complete -c dnglab -n "__fish_dnglab_using_subcommand cameras" -s v -d 'Print status for every file'
complete -c dnglab -n "__fish_dnglab_using_subcommand cameras" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c dnglab -n "__fish_dnglab_using_subcommand lenses" -s d -l loglevel -d 'Log level' -r -f -a "error\t''
warn\t''
info\t''
debug\t''
trace\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand lenses" -l profile-path -d 'Directory with profile TOML files' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand lenses" -l config -d 'dnglab configuration file' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand lenses" -l md -d 'Markdown format output'
complete -c dnglab -n "__fish_dnglab_using_subcommand lenses" -s v -d 'Print status for every file'
complete -c dnglab -n "__fish_dnglab_using_subcommand lenses" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c dnglab -n "__fish_dnglab_using_subcommand help; and not __fish_seen_subcommand_from convert reembed cameras lenses help" -f -a "convert" -d 'Convert raw image(s) into dng format'
complete -c dnglab -n "__fish_dnglab_using_subcommand help; and not __fish_seen_subcommand_from convert reembed cameras lenses help" -f -a "reembed" -d 'Re-embed edited preview into an existing DNG'
complete -c dnglab -n "__fish_dnglab_using_subcommand help; and not __fish_seen_subcommand_from convert reembed cameras lenses help" -f -a "cameras" -d 'List supported cameras'
complete -c dnglab -n "__fish_dnglab_using_subcommand help; and not __fish_seen_subcommand_from convert reembed cameras lenses help" -f -a "lenses" -d 'List supported lenses'
complete -c dnglab -n "__fish_dnglab_using_subcommand help; and not __fish_seen_subcommand_from convert reembed cameras lenses help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c dnglab -n "__fish_dnglab_using_subcommand help; and __fish_seen_subcommand_from convert" -f -a "raw" -d 'Convert raw images to DNG (deprecated: same as convert)'
