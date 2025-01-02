# https://stackoverflow.com/a/72278299/130638
# Significantly modified to:
# - include all the ANSI escape codes that Dorothy is aware of
# - support tabs
# don't use l as that results in: awk: towc: multibyte conversion failure on
BEGIN {
	line_regex="[`]"
	tab_parts_regex="[`]"
	tab_replacement="````"
	ansi_regex="[[:cntrl:]][[0-9;?]*[ABCDEFGHJKSTfhlmnsu]"
}
{
	file=$0
	split(file, lines, line_regex)
	for (i=1; i<=length(lines); i++) {
		line=lines[i]
		gsub(/\t/, tab_replacement, line)
		# repeatedly strip off "option_wrap_width" characters until we have processed the entire line
		do {
			columns=option_wrap_width
			segment=""
			# repeatedly strip off color control codes and characters until we have stripped of "n" characters
			while (columns > 0) {
				match(line, ansi_regex)
				if (RSTART && RSTART <= columns) {
					# ansi code
					segment=segment substr(line, 1, RSTART + RLENGTH - 1)
					line=substr(line, RSTART + RLENGTH)
					# don't use conditionals, as that fails with awk
					if (RSTART > 1) {
						columns=columns - (RSTART - 1)
					} else {
						columns=columns - 0
					}
				}
				else {
					segment=segment substr(line, 1, columns)
					line=substr(line, columns + 1)
					columns=0
				}
			}
			printf("%d", chars)
		} while ( line != "" )
	}
}
