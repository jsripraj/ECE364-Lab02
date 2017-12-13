#! /bin/bash

# $Author: ee364a05 $
# $Date: 2017-09-05 10:47:24 -0400 (Tue, 05 Sep 2017) $

function array 
{
    Arr=(a.txt b.txt c.txt d.txt e.txt)
    length=${#Arr[*]}
    (( randNum=$RANDOM%$length ))
    echo "printing ${Arr[$randNum]}"
    head -n 9 ${Arr[$randNum]} | tail -n 3
    return

}


#
# To test your function, you can call it below like this:
#
#array
#
array
