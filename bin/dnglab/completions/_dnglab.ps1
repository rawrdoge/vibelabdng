
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
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Print status for every file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('-V', '-V ', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('--version', '--version', [CompletionResultType]::ParameterName, 'Print version')
            [CompletionResult]::new('convert', 'convert', [CompletionResultType]::ParameterValue, 'Convert raw image(s) into dng format')
            [CompletionResult]::new('cameras', 'cameras', [CompletionResultType]::ParameterValue, 'List supported cameras')
            [CompletionResult]::new('lenses', 'lenses', [CompletionResultType]::ParameterValue, 'List supported lenses')
            [CompletionResult]::new('reembed', 'reembed', [CompletionResultType]::ParameterValue, 'Re-embed an edited preview JPEG into an existing DNG (preserves raw/metadata)')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'dnglab;convert' {
            [CompletionResult]::new('-c', '-c', [CompletionResultType]::ParameterName, 'Compression for raw image')
            [CompletionResult]::new('--compression', '--compression', [CompletionResultType]::ParameterName, 'Compression for raw image')
            [CompletionResult]::new('--ljpeg92-predictor', '--ljpeg92-predictor', [CompletionResultType]::ParameterName, 'LJPEG-92 predictor')
            [CompletionResult]::new('--dng-preview', '--dng-preview', [CompletionResultType]::ParameterName, 'DNG include preview image')
            [CompletionResult]::new('--dng-thumbnail', '--dng-thumbnail', [CompletionResultType]::ParameterName, 'DNG include thumbnail image')
            [CompletionResult]::new('--embed-raw', '--embed-raw', [CompletionResultType]::ParameterName, 'Embed the raw file into DNG')
            [CompletionResult]::new('--artist', '--artist', [CompletionResultType]::ParameterName, 'Set the artist tag')
            [CompletionResult]::new('--keep-mtime', '--keep-mtime', [CompletionResultType]::ParameterName, 'Keep mtime, read from EXIF with fallback to original file mtime')
            [CompletionResult]::new('--image-index', '--image-index', [CompletionResultType]::ParameterName, 'Select a specific image index (or ''all'') if file is a image container')
            [CompletionResult]::new('--crop', '--crop', [CompletionResultType]::ParameterName, 'DNG default crop')
            [CompletionResult]::new('-j', '-j', [CompletionResultType]::ParameterName, 'Number of files to convert in parallel (0 = auto)')
            [CompletionResult]::new('--jobs', '--jobs', [CompletionResultType]::ParameterName, 'Number of files to convert in parallel (0 = auto)')
            [CompletionResult]::new('--dng-version', '--dng-version', [CompletionResultType]::ParameterName, 'DNG specification version')
            [CompletionResult]::new('--preview-medium', '--preview-medium', [CompletionResultType]::ParameterName, 'Medium preview size WxH (e.g. 1024x1024)')
            [CompletionResult]::new('--preview-full', '--preview-full', [CompletionResultType]::ParameterName, 'Full preview size WxH (e.g. 4000x3000)')
            [CompletionResult]::new('--jpeg-quality', '--jpeg-quality', [CompletionResultType]::ParameterName, 'JPEG preview quality (0-100)')
            [CompletionResult]::new('--linear', '--linear', [CompletionResultType]::ParameterName, 'Write a linear (demosaiced) DNG')
            [CompletionResult]::new('--seed', '--seed', [CompletionResultType]::ParameterName, 'Deterministic seed for reproducible output')
            [CompletionResult]::new('--input', '--input', [CompletionResultType]::ParameterName, 'Input file or directory')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output file or existing directory')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--loglevel', '--loglevel', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Override existing files')
            [CompletionResult]::new('--override', '--override', [CompletionResultType]::ParameterName, 'Override existing files')
            [CompletionResult]::new('-r', '-r', [CompletionResultType]::ParameterName, 'Process input directory recursive')
            [CompletionResult]::new('--recursive', '--recursive', [CompletionResultType]::ParameterName, 'Process input directory recursive')
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Print status for every file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'dnglab;cameras' {
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--loglevel', '--loglevel', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--md', '--md', [CompletionResultType]::ParameterName, 'Markdown format output')
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Print status for every file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'dnglab;lenses' {
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--loglevel', '--loglevel', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--md', '--md', [CompletionResultType]::ParameterName, 'Markdown format output')
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Print status for every file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'dnglab;reembed' {
            [CompletionResult]::new('--dng', '--dng', [CompletionResultType]::ParameterName, 'Existing DNG file to re-embed preview into')
            [CompletionResult]::new('--preview', '--preview', [CompletionResultType]::ParameterName, 'Edited preview JPEG to embed')
            [CompletionResult]::new('--output', '--output', [CompletionResultType]::ParameterName, 'Output DNG path (defaults to overwriting --dng)')
            [CompletionResult]::new('-c', '-c', [CompletionResultType]::ParameterName, 'Compression for raw image')
            [CompletionResult]::new('--compression', '--compression', [CompletionResultType]::ParameterName, 'Compression for raw image')
            [CompletionResult]::new('--ljpeg92-predictor', '--ljpeg92-predictor', [CompletionResultType]::ParameterName, 'LJPEG-92 predictor')
            [CompletionResult]::new('--artist', '--artist', [CompletionResultType]::ParameterName, 'Set the artist tag')
            [CompletionResult]::new('--crop', '--crop', [CompletionResultType]::ParameterName, 'DNG default crop')
            [CompletionResult]::new('--dng-preview', '--dng-preview', [CompletionResultType]::ParameterName, 'DNG include preview image')
            [CompletionResult]::new('--dng-thumbnail', '--dng-thumbnail', [CompletionResultType]::ParameterName, 'DNG include thumbnail image')
            [CompletionResult]::new('--embed-raw', '--embed-raw', [CompletionResultType]::ParameterName, 'Re-embed the original raw file into DNG')
            [CompletionResult]::new('--seed', '--seed', [CompletionResultType]::ParameterName, 'Deterministic seed for reproducible output (use the same seed as the original conversion)')
            [CompletionResult]::new('-d', '-d', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--loglevel', '--loglevel', [CompletionResultType]::ParameterName, 'Log level')
            [CompletionResult]::new('--compress', '--compress', [CompletionResultType]::ParameterName, 'Enable lossless compression (equivalent to -c)')
            [CompletionResult]::new('-f', '-f', [CompletionResultType]::ParameterName, 'Override existing files')
            [CompletionResult]::new('--override', '--override', [CompletionResultType]::ParameterName, 'Override existing files')
            [CompletionResult]::new('-v', '-v', [CompletionResultType]::ParameterName, 'Print status for every file')
            [CompletionResult]::new('-h', '-h', [CompletionResultType]::ParameterName, 'Print help')
            [CompletionResult]::new('--help', '--help', [CompletionResultType]::ParameterName, 'Print help')
            break
        }
        'dnglab;help' {
            [CompletionResult]::new('convert', 'convert', [CompletionResultType]::ParameterValue, 'Convert raw image(s) into dng format')
            [CompletionResult]::new('cameras', 'cameras', [CompletionResultType]::ParameterValue, 'List supported cameras')
            [CompletionResult]::new('lenses', 'lenses', [CompletionResultType]::ParameterValue, 'List supported lenses')
            [CompletionResult]::new('reembed', 'reembed', [CompletionResultType]::ParameterValue, 'Re-embed an edited preview JPEG into an existing DNG (preserves raw/metadata)')
            [CompletionResult]::new('help', 'help', [CompletionResultType]::ParameterValue, 'Print this message or the help of the given subcommand(s)')
            break
        }
        'dnglab;help;convert' {
            break
        }
        'dnglab;help;cameras' {
            break
        }
        'dnglab;help;lenses' {
            break
        }
        'dnglab;help;reembed' {
            break
        }
        'dnglab;help;help' {
            break
        }
    })

    $completions.Where{ $_.CompletionText -like "$wordToComplete*" } |
        Sort-Object -Property ListItemText
}
