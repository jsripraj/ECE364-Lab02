#! /bin/bash

#---------------------------------------
# $Author: ee364a05 $
# $Date: 2017-09-05 10:52:19 -0400 (Tue, 05 Sep 2017) $
#---------------------------------------

# Do not modify above this line.

if (( $# != 1 )) 
then
    echo "Usage: ./sorting_data.bash <input file>"
    exit 1
elif [[ ! -r $1 ]]
then
    echo "Error: $1 is not a readable file."
    exit 2
else
    echo "Your choices are:"
    echo "1) First 10 people"
    echo "2) Last 5 names by highest zipcode"
    echo "3) Address of 6th-10th by reverse e-mail"
    echo "4) First 12 companies"
    echo "5) Pick a number of people"
    echo "6) Exit"
    while (( 1 ))
    do
        read -p "Your choice: " input
        lines=$(wc -l < $1)
        (( lines=$lines-1 ))
        if (( $input == 1 ))
        then
            tail -n $lines $1 | sort -k7,7 -k5,5 -k2,2 -k1,1 -t "," | head -n 10
        elif (( $input == 2 ))
        then
            tail -n $lines $1 | sort -k8,8 -n -t "," | tail -n 5 | cut -f 1,2 -d ","

        elif (( $input == 3 ))
        then
            tail -n $lines $1 | sort -k 11,11 -t "," -r | head -n 10 | tail -n 5 | cut -f 4,4 -d ","
        elif (( $input == 4 ))
        then
            tail -n $lines $1 | sort -k 3,3 -t "," | head -n 12 | cut -f 3,3 -d ","
        elif (( $input == 5 ))
        then
            read -p "Enter a number: " num
            tail -n $lines $1 | sort -k 2,2 -k 1,1 -t "," | head -n $num
        elif (( $input == 6 ))
        then
            echo "Have a nice day!"
            echo ""
            exit 0
        else
            echo "Error! Invalid Selection"
        fi
    done
fi
