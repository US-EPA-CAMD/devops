#!/bin/bash
function print_unapproved () {
    gawk '
    BEGIN {
        FPAT = "([^,]+)|(\"[^\"]+\")"
        count = 1
    }
    NR > 1{
        gsub(/"/, "")
        print "\033[1;31m"count " \033[0m"$1 " (\033[34m"$3"\033[0m): \033[1;31m"$2"\033[0m"
        count++
    }
    END {
    }
    ' unapproved.csv
}
echo -e "Validating package dependecy licenses against approved list...\n"

approved=$(gawk '
BEGIN {
    FPAT = "([^,]+)|(\"[^\"]+\")"
}
NR > 1{
    printf("%s,", $1)
}
END {
}
' devops/approved_licenses.csv)

echo -e "\033[32mApproved licenses:\033[0m $approved \n"

npx --ignore-existing license-checker --direct --production --excludePrivatePackages --exclude $approved --start . --csv --out unapproved.csv

lines=$(cat unapproved.csv | wc -l)

if [ $lines > 1 ]
then
    echo -e "The following \033[1;31m $lines packages \033[0m have licenses that are not in the approved list. Please investigate their licenses and add them to the approved list if compatible with MIT or remove the dependency\n"
    print_unapproved
    exit 1
else
    echo "All direct dependencies have approved licenses"
    exit 0
fi

