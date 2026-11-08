
use builtin;
use str;

set edit:completion:arg-completer[dnglab] = {|@words|
    fn spaces {|n|
        builtin:repeat $n ' ' | str:join ''
    }
    fn cand {|text desc|
        edit:complex-candidate $text &display=$text' '(spaces (- 14 (wcswidth $text)))$desc
    }
    var command = 'dnglab'
    for word $words[1..-1] {
        if (str:has-prefix $word '-') {
            break
        }
        set command = $command';'$word
    }
    var completions = [
        &'dnglab'= {
            cand -d 'Log level'
            cand --loglevel 'Log level'
            cand --profile-path 'Directory with profile TOML files'
            cand --config 'dnglab configuration file'
            cand -v 'Print status for every file'
            cand -h 'Print help (see more with ''--help'')'
            cand --help 'Print help (see more with ''--help'')'
            cand -V 'Print version'
            cand --version 'Print version'
            cand convert 'Convert raw image(s) into dng format'
            cand reembed 'Re-embed edited preview into an existing DNG'
            cand cameras 'List supported cameras'
            cand lenses 'List supported lenses'
            cand help 'Print this message or the help of the given subcommand(s)'
        }
        &'dnglab;convert'= {
            cand -p 'Convert profile name'
            cand --profile 'Convert profile name'
            cand -c 'Compression for raw image'
            cand --compression 'Compression for raw image'
            cand --ljpeg92-predictor 'LJPEG-92 predictor'
            cand --lossy-jpeg-quality 'JPEG quality for lossy compression (1-100)'
            cand --jxl-distance 'JPEG XL distance (0-25), 0 is lossless'
            cand --jxl-effort 'JPEG XL encoder effort (1-9)'
            cand --jxl-decode-speed 'JPEG XL decoding speed for lossy compression (1-4)'
            cand --dng-preview 'DNG include preview image'
            cand --dng-thumbnail 'DNG include thumbnail image'
            cand --dng-force-preview 'Generate DNG preview image from raw data'
            cand --dng-force-thumbnail 'Generate DNG thumbnail image from raw data'
            cand --max-dng-backward-version 'Maximum DNG backward version'
            cand --embed-raw 'Embed the raw file into DNG'
            cand --apply-dng-opcodes 'Apply DNG opcode lists to the image data instead of writing them to the DNG'
            cand --remove-dng-opcodes 'Remove DNG opcodes, as comma separated [<list>:]<opcode> (e.g. WarpRectilinear,2:GainMap)'
            cand --artist 'Set the artist tag'
            cand --copyright 'Set the copyright tag'
            cand --keep-mtime 'Keep mtime, read from EXIF with fallback to original file mtime'
            cand --image-index 'Select a specific image index (or ''all'') if file is a image container'
            cand --crop 'DNG default crop'
            cand --colorspace 'Colorspace of resulting DNG image'
            cand --render-steps 'Render pipeline steps'
            cand --hide-steps 'Hide render pipeline steps'
            cand --denoise 'Amount of denoising applied to rendered image (0.00..=4.00)'
            cand --sharpen 'Amount of sharpening applied to rendered image (0.00..=2.00)'
            cand --sharpness-radius 'Radius in px of sharpening mask'
            cand --saturation 'Change hue and saturation of the rendered image'
            cand --contrast 'Change the exposure (+EV) and contrast of the rendered image'
            cand --highlight 'Recover highlights (0.00..=1.00)'
            cand --blackpoint 'Adjust blackpoint (0.0..=1.0)'
            cand --gradient 'Tint the gradient along a certain axis (x y)'
            cand --tint 'Set white balance via temperature/tint'
            cand --whitebalance-rgb 'Manual whitebalance RGB values'
            cand --exposure 'Additional manual exposure adjustment in EV'
            cand --chromatic-aberration 'Correct chromatic aberration (0.00..=1.00)'
            cand --vignetting 'Correct vignetting (0.00..=1.00)'
            cand --distorting 'Correct distortion (0.00..=1.00)'
            cand --camera-profile 'Set custom camera profile'
            cand -t 'Linearization table'
            cand --linearization 'Linearization table'
            cand --wb 'Whitebalance as-shot'
            cand --white-xy 'Whitebalance as-shot encoded as xy chromaticity coordinates'
            cand -d 'Log level'
            cand --loglevel 'Log level'
            cand --profile-path 'Directory with profile TOML files'
            cand --config 'dnglab configuration file'
            cand -f 'Override existing files'
            cand --override 'Override existing files'
            cand -f 'Override existing files'
            cand --override 'Override existing files'
            cand -v 'Print status for every file'
            cand -h 'Print help (see more with ''--help'')'
            cand --help 'Print help (see more with ''--help'')'
            cand raw 'Convert raw images to DNG (deprecated: same as convert)'
            cand r 'Convert raw images to DNG (deprecated: same as convert)'
            cand help 'Print this message or the help of the given subcommand(s)'
        }
        &'dnglab;convert;raw'= {
            cand -d 'Log level'
            cand --loglevel 'Log level'
            cand --profile-path 'Directory with profile TOML files'
            cand --config 'dnglab configuration file'
            cand -v 'Print status for every file'
            cand -h 'Print help (see more with ''--help'')'
            cand --help 'Print help (see more with ''--help'')'
        }
        &'dnglab;convert;r'= {
            cand -d 'Log level'
            cand --loglevel 'Log level'
            cand --profile-path 'Directory with profile TOML files'
            cand --config 'dnglab configuration file'
            cand -v 'Print status for every file'
            cand -h 'Print help (see more with ''--help'')'
            cand --help 'Print help (see more with ''--help'')'
        }
        &'dnglab;convert;help'= {
            cand raw 'Convert raw images to DNG (deprecated: same as convert)'
            cand help 'Print this message or the help of the given subcommand(s)'
        }
        &'dnglab;convert;help;raw'= {
        }
        &'dnglab;convert;help;help'= {
        }
        &'dnglab;reembed'= {
            cand --dng 'Input DNG file'
            cand --preview 'Edited preview JPEG'
            cand --output 'Output DNG (default: overwrite input)'
            cand --embed-raw 'Embed original raw file'
            cand --compression 'Compression method for raw image'
            cand --crop 'Crop mode: best, activearea, none'
            cand --predictor 'LJPEG92 predictor (1-7)'
            cand --preview-enabled 'Include preview in output DNG'
            cand --thumbnail-enabled 'Include thumbnail in output DNG'
            cand --artist 'Set artist tag'
            cand --seed 'Deterministic seed for output bytes'
            cand -d 'Log level'
            cand --loglevel 'Log level'
            cand --profile-path 'Directory with profile TOML files'
            cand --config 'dnglab configuration file'
            cand --compress 'Use lossless compression'
            cand -v 'Print status for every file'
            cand -h 'Print help (see more with ''--help'')'
            cand --help 'Print help (see more with ''--help'')'
        }
        &'dnglab;cameras'= {
            cand -d 'Log level'
            cand --loglevel 'Log level'
            cand --profile-path 'Directory with profile TOML files'
            cand --config 'dnglab configuration file'
            cand --md 'Markdown format output'
            cand -v 'Print status for every file'
            cand -h 'Print help (see more with ''--help'')'
            cand --help 'Print help (see more with ''--help'')'
        }
        &'dnglab;lenses'= {
            cand -d 'Log level'
            cand --loglevel 'Log level'
            cand --profile-path 'Directory with profile TOML files'
            cand --config 'dnglab configuration file'
            cand --md 'Markdown format output'
            cand -v 'Print status for every file'
            cand -h 'Print help (see more with ''--help'')'
            cand --help 'Print help (see more with ''--help'')'
        }
        &'dnglab;help'= {
            cand convert 'Convert raw image(s) into dng format'
            cand reembed 'Re-embed edited preview into an existing DNG'
            cand cameras 'List supported cameras'
            cand lenses 'List supported lenses'
            cand help 'Print this message or the help of the given subcommand(s)'
        }
        &'dnglab;help;convert'= {
            cand raw 'Convert raw images to DNG (deprecated: same as convert)'
        }
        &'dnglab;help;convert;raw'= {
        }
        &'dnglab;help;reembed'= {
        }
        &'dnglab;help;cameras'= {
        }
        &'dnglab;help;lenses'= {
        }
        &'dnglab;help;help'= {
        }
    ]
    $completions[$command]
}
