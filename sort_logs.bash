#! /bin/bash

#---------------------------------------
# $Author: ee364a05 $
# $Date: 2017-09-03 22:05:23 -0400 (Sun, 03 Sep 2017) $
#---------------------------------------

# Do not modify above this line.
if (( $# != 1 ))
then
    echo "Usage: sort_logs.bash <input file>"
    echo ""
    exit 1
elif [[ ! -r $1 ]]
then
    echo "Error: $1 is not a readable file."
    echo ""
    exit 2
else
    # If either output file already exists attempt to remove
    if [[ -e $1.unsorted ]]
    then
        rm -f $1.unsorted
        if (( $? == 0 ))
        then
            echo "Note: Removed existing file $1.unsorted."
        else
            echo "Error: Could not remove $1.unsorted"
            echo ""
            exit 3
        fi
    fi
    if [[ -e $1.sorted ]]
    then
        rm -f $1.sorted
        if (( $? == 0 ))
        then
            echo "Note: Removed existing file $1.sorted."
        else
            echo "Error: Could not remove $1.sorted"
            echo ""
            exit 3
        fi
    fi
    if [[ -e $1.out ]]
    then
        rm -f $1.out
        if (( $? != 0 ))
        then
            exit 3
        fi
    fi
    # Get dimensions of input
    words=$(wc -w < $1)
    rows=$(wc -l < $1)
    (( cols=$words/$rows ))
    # Concatenate input into array
    i=0
    while read Input
    do
        Input=($Input)
        for col in ${Input[*]}
        do
            Data[i]=$col
            (( i++ ))
        done
    done < $1
    # Generate <input filename>.unsorted (machine_name, time, temperature)
    for (( i=$cols; $i < ${#Data[*]}; i++, machineIndex++ ))
    do
        if (( $i%$cols==0 ))
        then
            t=${Data[$i]}
            (( i++ ))
            machineIndex=1
        fi
        temp=${Data[$i]}
        machine=${Data[$machineIndex]}
        echo "$machine,$t,$temp" >> $1.unsorted
    done
    # Generate <input filename>.sorted (same format as unsorted file)
    sort -k3,3 -r -s -k1b -t "," $1.unsorted >> $1.sorted 
    # Printing average and median temperatures for time and machine categories
    for (( i=$cols, j=0, avgSum=0; i < ${#Data[*]}; i++ ))
    do
        # Record and then skip over time entries
        if (( $i%$cols==0 ))
        then
            t=${Data[i]}
            (( i++ ))
        fi
        # Load separate array for calculating median temperature
        (( avgSum=avgSum+Data[i] ))
        medianArray[j]=${Data[i]}
        (( j++ ))
        # For each time entry...
        if (( ($i+1)%$cols==0 ))
        then
            # Calculate the average temperature
            avg=$(echo "scale=2; $avgSum/($cols-1)" | bc )
            # Sort the separate array
            for (( a=1; a < $cols-1; a++ ))
            do
                for (( b=a; $b > 0; b-- ))
                do
                    if (( ${medianArray[$b]} < ${medianArray[$b-1]} ))
                    then
                        temp=${medianArray[$b]}
                        medianArray[$b]=${medianArray[$b-1]}
                        medianArray[$b-1]=$temp
                    fi
                done
            done
            # Calculate the median temperature
            (( medIndex=($cols-1)/2 ))
            if (( (( $cols-1 ))%2==0 ))
            then
                median=$(echo "scale=2; (${medianArray[$medIndex]}+${medianArray[$medIndex-1]})/2" | bc)
            else
                median=$(echo "scale=2; ${medianArray[$medIndex]}/1" | bc)
            fi
            # Save average and median temperatures to <input file>.out
            echo "Average temperature for time $t was $avg C." >> $1.out
            echo "Median temperature for time $t was $median C." >> $1.out
            echo "" >> $1.out
            avgSum=0
            j=0
        fi
    done
    # Calculate the average and median temperatures for each machine
    avgSum=0
    j=0
    for (( machine=1; machine < $cols ; machine++ ))
    do
        # For each machine entry...
        for (( i=$machine+$cols; i < ${#Data[*]}; i=$i+$cols ))
        do
            # Get sum and load median array
            (( avgSum=$avgSum+${Data[$i]} ))
            medArr[j]=${Data[$i]}
            (( j++ ))
        done
        # Calculate machine average
        avg=$(echo "scale=2; $avgSum/($rows-1)" | bc)
        # Sort median array
        for (( a=1; $a < $rows-1; a++ ))
        do
            for (( b=a; $b > 0; b-- ))
            do
                if (( ${medArr[$b]} < ${medArr[$b-1]} ))
                then
                    temp=${medArr[$b]}
                    medArr[$b]=${medArr[$b-1]}
                    medArr[$b-1]=$temp
                fi
            done
        done
        # Calculate the median
        (( medInd=($rows-1)/2 ))
        if (( ($rows-1)%2==0 ))
        then
            median=$(echo "scale=2; (${medArr[$medInd]}+${medArr[$medInd-1]})/2" | bc)
        else
            median=$(echo "scale=2; ${medArr[$medInd]}/1" | bc)
        fi
        # Save average and median temperatures to <input file>.out
        echo "Average temperature for ${Data[$machine]} was $avg C." >> $1.out
        echo "Median temperature for ${Data[$machine]} was $median C." >> $1.out
        echo "" >> $1.out
        avgSum=0
        j=0
    done
    echo ""
    exit 0
fi
