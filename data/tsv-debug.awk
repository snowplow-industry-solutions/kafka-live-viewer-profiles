#!/usr/bin/awk -f
#
# Usage: ./tsv-debug.sh [--print-field-names] micro.tsv
#
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

