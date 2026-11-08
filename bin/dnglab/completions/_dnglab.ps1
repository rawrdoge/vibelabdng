
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Register-ArgumentCompleter -Native -CommandName 'dnglab' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)

    $commandElements = $commandAst.CommandElements
    $command = @(
        'dnglab'
        for ($i = 1; $i -lt $commandElements.Count; $i++) {
            $element = $commandElements[$i]
            if ($element -isnot [StringConstantExpressionAst] -or
                $element.StringConstantType -ne [StringConstantType]::BareWord -or
                $element.Value.StartsWith('-') -or
                $element.Value -eq $wordToComplete) {
                break
        }
        $element.Value
    }) -join ';'

    $completions = @(switch ($command) {
        'dnglab' {
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--loglevel', '--loglevel', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--profile-path', '--profile-path', [CompletionResultType]::ParameterName, 'Directory with profile TOML files')
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'dnglab configuration file')
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Print status for every file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('convert', 'convert', [CompletionResultType]::ParameterValue, 'Convert raw image(s) into dng format')
            [CompletionResult]::new('reembed', 'reembed', [CompletionResultType]::ParameterValue, 'Re-embed edited preview into an existing DNG')
            [CompletionResult]::new('cameras', 'cameras', [CompletionResultType]::ParameterValue, 'List supported cameras')
            [CompletionResult]::new('lenses', 'lenses', [CompletionResultType]::ParameterValue, 'List supported lenses')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'dnglab;convert' {
            [CompletionResult]::new('-p', '-p', [CompletionResultType]::ParameterName, 'Convert profile name')
            [CompletionResult]::new('--profile', '--profile', [CompletionResultType]::ParameterName, 'Convert profile name')
            [CompletionResult]::new('-c', '-c', [CompletionResultType]::ParameterName, 'Compression for raw image')
            [CompletionResult]::new('--compression', '--compression', [CompletionResultType]::ParameterName, 'Compression for raw image')
            [CompletionResult]::new('--ljpeg92-predictor', '--ljpeg92-predictor', [CompletionResultType]::ParameterName, 'LJPEG-92 predictor')
            [CompletionResult]::new('--lossy-jpeg-quality', '--lossy-jpeg-quality', [CompletionResultType]::ParameterName, 'JPEG quality for lossy compression (1-100)')
            [CompletionResult]::new('--jxl-distance', '--jxl-distance', [CompletionResultType]::ParameterName, 'JPEG XL distance (0-25), 0 is lossless')
            [CompletionResult]::new('--jxl-effort', '--jxl-effort', [CompletionResultType]::ParameterName, 'JPEG XL encoder effort (1-9)')
            [CompletionResult]::new('--jxl-decode-speed', '--jxl-decode-speed', [CompletionResultType]::ParameterName, 'JPEG XL decoding speed for lossy compression (1-4)')
            [CompletionResult]::new('--dng-preview', '--dng-preview', [CompletionResultType]::ParameterName, 'DNG include preview image')
            [CompletionResult]::new('--dng-thumbnail', '--dng-thumbnail', [CompletionResultType]::ParameterName, 'DNG include thumbnail image')
            [CompletionResult]::new('--dng-force-preview', '--dng-force-preview', [CompletionResultType]::ParameterName, 'Generate DNG preview image from raw data')
            [CompletionResult]::new('--dng-force-thumbnail', '--dng-force-thumbnail', [CompletionResultType]::ParameterName, 'Generate DNG thumbnail image from raw data')
            [CompletionResult]::new('--max-dng-backward-version', '--max-dng-backward-version', [CompletionResultType]::ParameterName, 'Maximum DNG backward version')
            [CompletionResult]::new('--embed-raw', '--embed-raw', [CompletionResultType]::ParameterName, 'Embed the raw file into DNG')
            [CompletionResult]::new('--apply-dng-opcodes', '--apply-dng-opcodes', [CompletionResultType]::ParameterName, 'Apply DNG opcode lists to the image data instead of writing them to the DNG')
            [CompletionResult]::new('--remove-dng-opcodes', '--remove-dng-opcodes', [CompletionResultType]::ParameterName, 'Remove DNG opcodes, as comma separated [<list>:]<opcode> (e.g. WarpRectilinear,2:GainMap)')
            [CompletionResult]::new('--artist', '--artist', [CompletionResultType]::ParameterName, 'Set the artist tag')
            [CompletionResult]::new('--copyright', '--copyright', [CompletionResultType]::ParameterName, 'Set the copyright tag')
            [CompletionResult]::new('--keep-mtime', '--keep-mtime', [CompletionResultType]::ParameterName, 'Keep mtime, read from EXIF with fallback to original file mtime')
            [CompletionResult]::new('--image-index', '--image-index', [CompletionResultType]::ParameterName, 'Select a specific image index (or ''all'') if file is a image container')
            [CompletionResult]::new('--crop', '--crop', [CompletionResultType]::ParameterName, 'DNG default crop')
            [CompletionResult]::new('--colorspace', '--colorspace', [CompletionResultType]::ParameterName, 'Colorspace of resulting DNG image')
            [CompletionResult]::new('--render-steps', '--render-steps', [CompletionResultType]::ParameterName, 'Render pipeline steps')
            [CompletionResult]::new('--hide-steps', '--hide-steps', [CompletionResultType]::ParameterName, 'Hide render pipeline steps')
            [CompletionResult]::new('--denoise', '--denoise', [CompletionResultType]::ParameterName, 'Amount of denoising applied to rendered image (0.00..=4.00)')
            [CompletionResult]::new('--sharpen', '--sharpen', [CompletionResultType]::ParameterName, 'Amount of sharpening applied to rendered image (0.00..=2.00)')
            [CompletionResult]::new('--sharpness-radius', '--sharpness-radius', [CompletionResultType]::ParameterName, 'Radius in px of sharpening mask')
            [CompletionResult]::new('--saturation', '--saturation', [CompletionResultType]::ParameterName, 'Change hue and saturation of the rendered image')
            [CompletionResult]::new('--contrast', '--contrast', [CompletionResultType]::ParameterName, 'Change the exposure (+EV) and contrast of the rendered image')
            [CompletionResult]::new('--highlight', '--highlight', [CompletionResultType]::ParameterName, 'Recover highlights (0.00..=1.00)')
            [CompletionResult]::new('--blackpoint', '--blackpoint', [CompletionResultType]::ParameterName, 'Adjust blackpoint (0.0..=1.0)')
            [CompletionResult]::new('--gradient', '--gradient', [CompletionResultType]::ParameterName, 'Tint the gradient along a certain axis (x y)')
            [CompletionResult]::new('--tint', '--tint', [CompletionResultType]::ParameterName, 'Set white balance via temperature/tint')
            [CompletionResult]::new('--whitebalance-rgb', '--whitebalance-rgb', [CompletionResultType]::ParameterName, 'Manual whitebalance RGB values')
            [CompletionResult]::new('--exposure', '--exposure', [CompletionResultType]::ParameterName, 'Additional manual exposure adjustment in EV')
            [CompletionResult]::new('--chromatic-aberration', '--chromatic-aberration', [CompletionResultType]::ParameterName, 'Correct chromatic aberration (0.00..=1.00)')
            [CompletionResult]::new('--vignetting', '--vignetting', [CompletionResultType]::ParameterName, 'Correct vignetting (0.00..=1.00)')
            [CompletionResult]::new('--distorting', '--distorting', [CompletionResultType]::ParameterName, 'Correct distortion (0.00..=1.00)')
            [CompletionResult]::new('--camera-profile', '--camera-profile', [CompletionResultType]::ParameterName, 'Set custom camera profile')
            [CompletionResult]::new('-t', '-t', [CompletionResultType]::ParameterName, 'Linearization table')
            [CompletionResult]::new('--linearization', '--linearization', [CompletionResultType]::ParameterName, 'Linearization table')
            [CompletionResult]::new('--wb', '--wb', [CompletionResultType]::ParameterName, 'Whitebalance as-shot')
            [CompletionResult]::new('--white-xy', '--white-xy', [CompletionResultType]::ParameterName, 'Whitebalance as-shot encoded as xy chromaticity coordinates')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--loglevel', '--loglevel', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--profile-path', '--profile-path', [CompletionResultType]::ParameterName, 'Directory with profile TOML files')
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'dnglab configuration file')
            [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Override existing files')
            [CompletionResult]::new('--override', '--override', [CompletionResultType]::ParameterName, 'Override existing files')
            [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Override existing files')
            [CompletionResult]::new('--override', '--override', [CompletionResultType]::ParameterName, 'Override existing files')
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Print status for every file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('raw', 'raw', [CompletionResultType]::ParameterValue, 'Convert raw images to DNG (deprecated: same as convert)')
            [CompletionResult]::new('r', 'r', [CompletionResultType]::ParameterValue, 'Convert raw images to DNG (deprecated: same as convert)')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'dnglab;convert;raw' {
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--loglevel', '--loglevel', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--profile-path', '--profile-path', [CompletionResultType]::ParameterName, 'Directory with profile TOML files')
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'dnglab configuration file')
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Print status for every file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'dnglab;convert;r' {
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--loglevel', '--loglevel', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--profile-path', '--profile-path', [CompletionResultType]::ParameterName, 'Directory with profile TOML files')
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'dnglab configuration file')
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Print status for every file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'dnglab;convert;help' {
            [CompletionResult]::new('raw', 'raw', [CompletionResultType]::ParameterValue, 'Convert raw images to DNG (deprecated: same as convert)')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'dnglab;convert;help;raw' {
            break
        }
        'dnglab;convert;help;help' {
            break
        }
        'dnglab;reembed' {
            [CompletionResult]::new('--dng', '--dng', [CompletionResultType]::ParameterName, 'Input DNG file')
            [CompletionResult]::new('--preview', '--preview', [CompletionResultType]::ParameterName, 'Edited preview JPEG')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output DNG (default: overwrite input)')
            [CompletionResult]::new('--embed-raw', '--embed-raw', [CompletionResultType]::ParameterName, 'Embed original raw file')
            [CompletionResult]::new('--compression', '--compression', [CompletionResultType]::ParameterName, 'Compression method for raw image')
            [CompletionResult]::new('--crop', '--crop', [CompletionResultType]::ParameterName, 'Crop mode: best, activearea, none')
            [CompletionResult]::new('--predictor', '--predictor', [CompletionResultType]::ParameterName, 'LJPEG92 predictor (1-7)')
            [CompletionResult]::new('--preview-enabled', '--preview-enabled', [CompletionResultType]::ParameterName, 'Include preview in output DNG')
            [CompletionResult]::new('--thumbnail-enabled', '--thumbnail-enabled', [CompletionResultType]::ParameterName, 'Include thumbnail in output DNG')
            [CompletionResult]::new('--artist', '--artist', [CompletionResultType]::ParameterName, 'Set artist tag')
            [CompletionResult]::new('--seed', '--seed', [CompletionResultType]::ParameterName, 'Deterministic seed for output bytes')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--loglevel', '--loglevel', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--profile-path', '--profile-path', [CompletionResultType]::ParameterName, 'Directory with profile TOML files')
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'dnglab configuration file')
            [CompletionResult]::new('--compress', '--compress', [CompletionResultType]::ParameterName, 'Use lossless compression')
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Print status for every file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'dnglab;cameras' {
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--loglevel', '--loglevel', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--profile-path', '--profile-path', [CompletionResultType]::ParameterName, 'Directory with profile TOML files')
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'dnglab configuration file')
            [CompletionResult]::new('--md', '--md', [CompletionResultType]::ParameterName, 'Markdown format output')
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Print status for every file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'dnglab;lenses' {
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--loglevel', '--loglevel', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--profile-path', '--profile-path', [CompletionResultType]::ParameterName, 'Directory with profile TOML files')
            [CompletionResult]::new('--config', '--config', [CompletionResultType]::ParameterName, 'dnglab configuration file')
            [CompletionResult]::new('--md', '--md', [CompletionResultType]::ParameterName, 'Markdown format output')
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Print status for every file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help (see more with ''--help'')')
            break
        }
        'dnglab;help' {
            [CompletionResult]::new('convert', 'convert', [CompletionResultType]::ParameterValue, 'Convert raw image(s) into dng format')
            [CompletionResult]::new('reembed', 'reembed', [CompletionResultType]::ParameterValue, 'Re-embed edited preview into an existing DNG')
            [CompletionResult]::new('cameras', 'cameras', [CompletionResultType]::ParameterValue, 'List supported cameras')
            [CompletionResult]::new('lenses', 'lenses', [CompletionResultType]::ParameterValue, 'List supported lenses')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'dnglab;help;convert' {
            [CompletionResult]::new('raw', 'raw', [CompletionResultType]::ParameterValue, 'Convert raw images to DNG (deprecated: same as convert)')
            break
        }
        'dnglab;help;convert;raw' {
            break
        }
        'dnglab;help;reembed' {
            break
        }
        'dnglab;help;cameras' {
            break
        }
        'dnglab;help;lenses' {
            break
        }
        'dnglab;help;help' {
            break
        }
    })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}
