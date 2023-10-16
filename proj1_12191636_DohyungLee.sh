#!/bin/bash

getMovieData() {
    read -p "Please enter 'movie id'(1-1682): " movie_id
    result=$(awk -F '|' -v mid="$movie_id" '$1 == mid {print}' u.item)
    if [ -n "$result" ]; then
        echo "$result"
    else
        echo "Movie ID not found!"
    fi
}

getActionGenreMovies() {
    read -p "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n): " confirm

    if [ "$confirm" = "y" ]; then
        grep "Action" u.item | sort -n -t'|' -k1 | head -10 | awk -F'|' '{print $1 " " $2}'
    fi
}

getAverageRating() {
    read -p "Please enter the 'movie id'(1-1682): " id

    avg=$(awk -v id="$id" '$2==id { sum+=$3; count++ } END { printf "%.6f", sum/count }' u.data)

    rounded_avg=$(echo "$avg" | awk '{printf "%.5f\n", $1}')

    echo "average rating of $id: $rounded_avg"
}


deleteImdbUrl() {
    read -p "Do you want to delete the 'IMDb URL' from 'u.item'? (y/n): " decision

    if [ "$decision" == "y" ]; then
        cp u.item u.item.bak

        awk -F'|' '{print $1 "|" $2 "|" $3 "|" $4}' u.item > u.item.temp
        mv u.item.temp u.item

        head -10 u.item
    fi
}

getUserData() {
    read -p "Do you want to get the data about users from 'u.user'? (y/n): " decision

    if [ "$decision" == "y" ]; then
        awk -F'|' 'NR <= 10 {print "user", $1, "is", $2, "years old", $3, $4}' u.user
    fi
}

modifyReleaseDate() {
    read -p "Do you want to Modify the format of ‘release date’ in ‘u.item’? (y/n): " decision

    if [ "$decision" == "y" ]; then
        awk -F'|' '{ 
            split($3, date, "-"); 
            monthList["Jan"]=01; monthList["Feb"]=02; monthList["Mar"]=03;
            monthList["Apr"]=04; monthList["May"]=05; monthList["Jun"]=06;
            monthList["Jul"]=07; monthList["Aug"]=08; monthList["Sep"]=09;
            monthList["Oct"]=10; monthList["Nov"]=11; monthList["Dec"]=12;
            $3 = date[3] monthList[date[2]] date[1];
            print $0 
        }' u.item | tail -10
    fi
}

getDataByUserId() {
    read -p "Please enter the 'user id' (1-943): " user_id

    if [ "$user_id" -lt 1 ] || [ "$user_id" -gt 943 ]; then
        echo "Invalid user id."
        exit 1
    fi

    movie_ids=$(awk -F '\t' -v uid="$user_id" '$1 == uid {print $2}' u.data | sort -n)

    counter=0
    for movie_id in $movie_ids; do
        echo -n "$movie_id "
        counter=$((counter + 1))
        if [ "$counter" -ge 10 ]; then
            break
        fi
    done
    echo

    counter=0
    for movie_id in $movie_ids; do
        movie_title=$(awk -F '|' -v mid="$movie_id" '$1 == mid {print $2 " (" $3 ")"}' u.item)
        echo "$movie_id|$movie_title"
        counter=$((counter + 1))
        if [ "$counter" -ge 10 ]; then
            break
        fi
    done
}

getAverageRating2() {
    read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n) " confirm

    if [ "$confirm" = "y" ]; then
        user_ids=$(awk -F '|' -v minAge=20 -v maxAge=29 -v occupation="programmer" \
                   '$3 >= minAge && $3 <= maxAge && $4 == occupation {print $1}' u.user)

        for user_id in $user_ids; do
            awk -F '\t' -v uid="$user_id" '$1 == uid {print $2 " " $3}' u.data
        done > temp_ratings.txt

        if [[ ! -s temp_ratings.txt ]]; then
            echo "No ratings found for specified criteria."
            return
        fi

        awk '{ sum[$1] += $2; count[$1]++ } \
             END { for (i in sum) printf "%s %.6f\n", i, sum[i]/count[i] }' temp_ratings.txt \
        | sort -k1,1n -k2,2rn \
        | awk '{ printf "%s %.5f\n", $1, $2 }' > temp_avg_ratings.txt

        head -10 temp_avg_ratings.txt

        rm temp_ratings.txt temp_avg_ratings.txt
    fi
}

exitScript() {
    echo "Bye"
    exit 0
}

mainMenu() {
    echo "--------------------------
User Name: Dohyung Lee
Student Number: 12191636
[ MENU ]
1. Get the data of the movie identified by a specific
'movie id' from 'u.item'
2. Get the data of action genre movies from 'u.item’
3. Get the average 'rating’ of the movie identified by
specific 'movie id' from 'u.data’
4. Delete the ‘IMDb URL’ from ‘u.item
5. Get the data about users from 'u.user’
6. Modify the format of 'release date' in 'u.item’
7. Get the data of movies rated by a specific 'user id'
from 'u.data'
8. Get the average 'rating' of movies rated by users with
'age' between 20 and 29 and 'occupation' as 'programmer'
9. Exit
----------------------------"
    while true; do
        read -p "Enter your choice [1-9] " choice

        case $choice in
            1)
                getMovieData
                ;;
            2)
                getActionGenreMovies
                ;;
            3)
                getAverageRating
                ;;
            4)
                deleteImdbUrl
                ;;
            5)
                getUserData
                ;;
            6)
                modifyReleaseDate
                ;;
            7)
                getDataByUserId
                ;;
            8)
                getAverageRating2
                ;;
            9)
                exitScript
                ;;
        esac
    done
}

mainMenu