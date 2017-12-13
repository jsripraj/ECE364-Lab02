#! /bin/bash

#---------------------------------------
# $Author: ee364a05 $
# $Date: 2017-09-03 22:59:29 -0400 (Sun, 03 Sep 2017) $
#---------------------------------------

# Do not modify above this line.

for file in $(ls c-files)
do
    echo -n "Compiling file $file... "
    gcc -Wall -Werror "c-files"/$file 2>/dev/null
    if (( $? != 0 ))
    then
        echo "Error: Compilation failed."
    else
        echo "Compilation succeeded."
        ./a.out >${file//.c/.out}
    fi
done
echo ""
exit 0
