#!/usr/bin/env bash

# shellcheck disable=1091
source "$(dirname "${BASH_SOURCE[0]}")"/common.bash || exit

usage() (
	cat <<-...
	Usage: $0 <commit-range>|<file>
	  <commit-range>: A range of commits in the form hash..hash
	  <file>: A file containing a list of commit hashes, one per line"
	...
)

main() (
	require git head sed

	case $# in
		0) usage; exit ;;
		1) range_or_file=$1 ;;
		*) die \
				'Error: Too many arguments.' \
				'' \
				"$(usage)" ;;
	esac

	# Determine input type
	range_or_file=${1:-HEAD}
	if [[ -f $range_or_file ]]; then
		message=$(< "$range_or_file")
		validate-commit-message "$range_or_file" "$message" ||
			die "Commit message in $range_or_file is invalid."

	else
		ok=true
		commits=$(git rev-list "$range_or_file")
		for commit in $commits; do
			message=$(git log --format=%B -n 1 "$commit")
			validate-commit-message "$commit" "$message" ||
				ok=false
		done
		$ok || die 'At least one commit message is invalid.'
	fi
)

validate-commit-message() (
	commit_or_file=$1
	message=$2
	subject=$(head -n1 <<<"$message")
	length=${#subject}
	errors=()
	error_lines=()

	[[ $subject =~ ^(feat|fix|docs|style|refactor|perf|test|chore)(\(.*\))?: ]] &&
		errors+=('Line 1: Do not use conventional commit format for subject')

	# subject should not start with square brackets
	[[ $subject =~ ^\[.*\] ]] &&
		errors+=('Line 1: Subject should not start with square brackets')

	[[ $subject =~ ^[A-Z] ]] ||
		errors+=('Line 1: Subject should start with a capital letter')

	[[ $subject == *. ]] &&
		errors+=('Line 1: Subject should not end with a period')

	[[ $subject == *'  '* ]] &&
		errors+=('Line 1: Subject should not contain consecutive spaces')

	[[ $subject == *' ' ]] &&
		errors+=('Line 1: Subject should not have trailing space(s)')

	[[ $length -ge 20 ]] ||
		errors+=("Line 1: Subject should be longer than 20 characters (current: $length)")

	[[ $length -le 50 ]] ||
		errors+=("Line 1: Subject should be shorter than 50 characters (current: $length)")

	[[ ${#errors[*]} -eq 0 ]] ||
		error_lines+=(1)

	if [[ $(sed -n '2p' <<<"$message") ]]; then
		errors+=('Line 2: Subject and body should be separated by a single blank line')
		error_lines+=(2)
	fi

	body=$(sed -n '3,$p' <<<"$message")
	i=3
	while IFS= read -r line; do
		if [[ $line == *' ' ]]; then
			errors+=("Line $i: Body should not have trailing space(s)")
			# If we add more checks in this loop, we need this for multiple errors:
			[[ ${error_lines[0]} == "$i" ]] || error_lines+=("$i")
		fi

		((i++))
	done <<<"$body"

	# Return if no errors:
	[[ ${#errors[@]} -eq 0 ]] && return

	# Report errors to stderr:
	(
		echo -e "${RED}Error: '$commit_or_file' has an invalid commit message:$RESET\n"

		# read the message and add the line number in front of each line, and use
		# warn_color to display a line with an error based on line_with_errors
		i=1
		while IFS= read -r line && [[ ${#error_lines[*]} -gt 0 ]]; do
			COLOR=$RESET
			if [[ $i == "${error_lines[0]}" ]]; then
				COLOR="\e[1;33m"  # Bold yellow
				error_lines=("${error_lines[@]:1}")
			fi
			echo -e "${COLOR}Line $(printf '%2d' $i): $line$RESET"
			((i++))
		done <<<"$message"

		echo
		printf -- '* %s\n' "${errors[@]}"
		echo
	) >&2

	return 1
)

main "$@"
