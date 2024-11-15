#!/usr/bin/awk -f

# HELP-BEGIN
# Usage examples:

# Print field numbers for each line:
# $ ./tsv-debug.awk samples/micro.1.tsv
# $ ./tsv-debug.awk < samples/micro.1.tsv

# Use header.tsv to print field names instead of field numbers:
# $ ./tsv-debug.awk --print-field-names samples/micro.1.tsv

# Print only 3 lines (10,11,12) from the specified file:
# $ sed -n '10,12p' samples/micro.1.tsv | ./tsv-debug.awk --print-field-names 

# Put all unstruct_event in a events variable:
# $ events=$(./tsv-debug.awk --print-field-names samples/micro.1.tsv | grep -n unstruct_event) 

# $ echo "$events" # <- Show the events
# $ grep -E '(error_event|play_event)' <<< "$events" # <- Show all error_event or play_event
# $ grep -m 1 play_event <<< "$events" # <- Get the first occurence of a play_event
# $ !! | cut -d: -f3- | jq # <- Print the last line in JSON format

# Show the order of ocurrence of events in time:
# $ echo "$events" | grep -v 'unstruct_event:$' | sed 's,.*media/\(.*event\)/\(.*\),\1,g' 

# HELP-END

BEGIN {
    FS = "\t"
    print_fields = 0
    field_file = "header.tsv"

    while (ARGV[1] == "--print-field-names") {
        print_fields = 1
        for (i = 1; i < ARGC; i++) {
            ARGV[i] = ARGV[i + 1]
        }
        ARGC--
    }

    if (print_fields) {
        if ((getline line < field_file) > 0) {
            num_fields = split(line, fields, FS)
            for (i = 1; i <= num_fields; i++) {
                field_names[i] = fields[i]
            }
        } else {
            print "Error: Could not read the field names file." > "/dev/stderr"
            exit 1
        }
        close(field_file)
    }
}

{
    print NR "-BEGIN"

    for (i = 1; i <= NF; i++) {
        if (print_fields && field_names[i] != "") {
            label = field_names[i]
        } else {
            label = i - 1
        }
        printf "%s:%s\n", label, $i
    }

    print NR "-END"
}

