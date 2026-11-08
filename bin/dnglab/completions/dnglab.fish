# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_dnglab_global_optspecs
	string join \n d/loglevel= v h/help V/version
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
complete -c dnglab -n "__fish_dnglab_needs_command" -s v -d 'Print status for every file'
complete -c dnglab -n "__fish_dnglab_needs_command" -s h -l help -d 'Print help'
complete -c dnglab -n "__fish_dnglab_needs_command" -s V -l version -d 'Print version'
complete -c dnglab -n "__fish_dnglab_needs_command" -f -a "convert" -d 'Convert raw image(s) into dng format'
complete -c dnglab -n "__fish_dnglab_needs_command" -f -a "cameras" -d 'List supported cameras'
complete -c dnglab -n "__fish_dnglab_needs_command" -f -a "lenses" -d 'List supported lenses'
complete -c dnglab -n "__fish_dnglab_needs_command" -f -a "reembed" -d 'Re-embed an edited preview JPEG into an existing DNG (preserves raw/metadata)'
complete -c dnglab -n "__fish_dnglab_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -s c -l compression -d 'Compression for raw image' -r -f -a "lossless\t''
uncompressed\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l ljpeg92-predictor -d 'LJPEG-92 predictor' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l dng-preview -d 'DNG include preview image' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l dng-thumbnail -d 'DNG include thumbnail image' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l embed-raw -d 'Embed the raw file into DNG' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l artist -d 'Set the artist tag' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l keep-mtime -d 'Keep mtime, read from EXIF with fallback to original file mtime' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l image-index -d 'Select a specific image index (or \'all\') if file is a image container' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l crop -d 'DNG default crop' -r -f -a "best\t''
activearea\t''
none\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -s j -l jobs -d 'Number of files to convert in parallel (0 = auto)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l dng-version -d 'DNG specification version' -r -f -a "1.4\t''
1.5\t''
1.6\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l preview-medium -d 'Medium preview size WxH (e.g. 1024x1024)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l preview-full -d 'Full preview size WxH (e.g. 4000x3000)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l jpeg-quality -d 'JPEG preview quality (0-100)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l linear -d 'Write a linear (demosaiced) DNG' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l seed -d 'Deterministic seed for reproducible output' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l input -d 'Input file or directory' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -l output -d 'Output file or existing directory' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -s d -l loglevel -d 'Log level' -r -f -a "error\t''
warn\t''
info\t''
debug\t''
trace\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -s f -l override -d 'Override existing files'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -s r -l recursive -d 'Process input directory recursive'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -s v -d 'Print status for every file'
complete -c dnglab -n "__fish_dnglab_using_subcommand convert" -s h -l help -d 'Print help'
complete -c dnglab -n "__fish_dnglab_using_subcommand cameras" -s d -l loglevel -d 'Log level' -r -f -a "error\t''
warn\t''
info\t''
debug\t''
trace\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand cameras" -l md -d 'Markdown format output'
complete -c dnglab -n "__fish_dnglab_using_subcommand cameras" -s v -d 'Print status for every file'
complete -c dnglab -n "__fish_dnglab_using_subcommand cameras" -s h -l help -d 'Print help'
complete -c dnglab -n "__fish_dnglab_using_subcommand lenses" -s d -l loglevel -d 'Log level' -r -f -a "error\t''
warn\t''
info\t''
debug\t''
trace\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand lenses" -l md -d 'Markdown format output'
complete -c dnglab -n "__fish_dnglab_using_subcommand lenses" -s v -d 'Print status for every file'
complete -c dnglab -n "__fish_dnglab_using_subcommand lenses" -s h -l help -d 'Print help'
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l dng -d 'Existing DNG file to re-embed preview into' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l preview -d 'Edited preview JPEG to embed' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l output -d 'Output DNG path (defaults to overwriting --dng)' -r -F
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -s c -l compression -d 'Compression for raw image' -r -f -a "lossless\t''
uncompressed\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l ljpeg92-predictor -d 'LJPEG-92 predictor' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l artist -d 'Set the artist tag' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l crop -d 'DNG default crop' -r -f -a "best\t''
activearea\t''
none\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l dng-preview -d 'DNG include preview image' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l dng-thumbnail -d 'DNG include thumbnail image' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l embed-raw -d 'Re-embed the original raw file into DNG' -r -f -a "true\t''
false\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l seed -d 'Deterministic seed for reproducible output (use the same seed as the original conversion)' -r
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -s d -l loglevel -d 'Log level' -r -f -a "error\t''
warn\t''
info\t''
debug\t''
trace\t''"
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -l compress -d 'Enable lossless compression (equivalent to -c)'
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -s f -l override -d 'Override existing files'
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -s v -d 'Print status for every file'
complete -c dnglab -n "__fish_dnglab_using_subcommand reembed" -s h -l help -d 'Print help'
complete -c dnglab -n "__fish_dnglab_using_subcommand help; and not __fish_seen_subcommand_from convert cameras lenses reembed help" -f -a "convert" -d 'Convert raw image(s) into dng format'
complete -c dnglab -n "__fish_dnglab_using_subcommand help; and not __fish_seen_subcommand_from convert cameras lenses reembed help" -f -a "cameras" -d 'List supported cameras'
complete -c dnglab -n "__fish_dnglab_using_subcommand help; and not __fish_seen_subcommand_from convert cameras lenses reembed help" -f -a "lenses" -d 'List supported lenses'
complete -c dnglab -n "__fish_dnglab_using_subcommand help; and not __fish_seen_subcommand_from convert cameras lenses reembed help" -f -a "reembed" -d 'Re-embed an edited preview JPEG into an existing DNG (preserves raw/metadata)'
complete -c dnglab -n "__fish_dnglab_using_subcommand help; and not __fish_seen_subcommand_from convert cameras lenses reembed help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
