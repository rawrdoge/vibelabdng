
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
            cand -v 'Print status for every file'
            cand -h 'Print help'
            cand --help 'Print help'
            cand -V 'Print version'
            cand --version 'Print version'
            cand convert 'Convert raw image(s) into dng format'
            cand reembed 'Re-embed an edited preview JPEG into an existing DNG (preserves raw/metadata)'
            cand help 'Print this message or the help of the given subcommand(s)'
        }
        &'dnglab;convert'= {
            cand -c 'Compression for raw image'
            cand --compression 'Compression for raw image'
            cand --ljpeg92-predictor 'LJPEG-92 predictor'
            cand --dng-preview 'DNG include preview image'
            cand --dng-thumbnail 'DNG include thumbnail image'
            cand --embed-raw 'Embed the raw file into DNG'
            cand --artist 'Set the artist tag'
            cand --keep-mtime 'Keep mtime, read from EXIF with fallback to original file mtime'
            cand --image-index 'Select a specific image index (or ''all'') if file is a image container'
            cand --crop 'DNG default crop'
            cand -j 'Number of files to convert in parallel (0 = auto)'
            cand --jobs 'Number of files to convert in parallel (0 = auto)'
            cand --dng-version 'DNG specification version'
            cand --preview-medium 'Medium preview size WxH (e.g. 1024x1024)'
            cand --preview-full 'Full preview size WxH (e.g. 4000x3000)'
            cand --jpeg-quality 'JPEG preview quality (0-100)'
            cand --linear 'Write a linear (demosaiced) DNG'
            cand --seed 'Deterministic seed for reproducible output'
            cand --input 'Input file or directory'
            cand --output 'Output file or existing directory'
            cand -d 'Log level'
            cand --loglevel 'Log level'
            cand -f 'Override existing files'
            cand --override 'Override existing files'
            cand -r 'Process input directory recursive'
            cand --recursive 'Process input directory recursive'
            cand -v 'Print status for every file'
            cand -h 'Print help'
            cand --help 'Print help'
        }
        &'dnglab;reembed'= {
            cand --dng 'Existing DNG file to re-embed preview into'
            cand --preview 'Edited preview JPEG to embed'
            cand --output 'Output DNG path (defaults to overwriting --dng)'
            cand -c 'Compression for raw image'
            cand --compression 'Compression for raw image'
            cand --ljpeg92-predictor 'LJPEG-92 predictor'
            cand --artist 'Set the artist tag'
            cand --crop 'DNG default crop'
            cand --dng-preview 'DNG include preview image'
            cand --dng-thumbnail 'DNG include thumbnail image'
            cand --embed-raw 'Re-embed the original raw file into DNG'
            cand --seed 'Deterministic seed for reproducible output (use the same seed as the original conversion)'
            cand -d 'Log level'
            cand --loglevel 'Log level'
            cand --compress 'Enable lossless compression (equivalent to -c)'
            cand -f 'Override existing files'
            cand --override 'Override existing files'
            cand -v 'Print status for every file'
            cand -h 'Print help'
            cand --help 'Print help'
        }
        &'dnglab;help'= {
            cand convert 'Convert raw image(s) into dng format'
            cand reembed 'Re-embed an edited preview JPEG into an existing DNG (preserves raw/metadata)'
            cand help 'Print this message or the help of the given subcommand(s)'
        }
        &'dnglab;help;convert'= {
        }
        &'dnglab;help;reembed'= {
        }
        &'dnglab;help;help'= {
        }
    ]
    $completions[$command]
}
