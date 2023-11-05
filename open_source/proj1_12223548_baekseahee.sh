#! /bin/bash


u_item=$1
u_user=$3
u_data=$2

echo "--------------------------"
echo "User Name: Baek_Sea_Hee"
echo "Student Number : 12223548"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and
'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"

while true; do

	echo " "
	read -p "Enter your choice [ 1-9 ] " choice
	case $choice in 
		1)	
			echo " " 
			read -p "Please enter the 'movie id' (1~1682): " movie_id
			echo " "
			cat "$u_item" | awk -v movie_id="$movie_id" -F "|" '$1==movie_id {print $0}'
			;;
		2)
			echo " "
			read -p "Do you want to get the data of 'action' genre movies from 'u.item'? (y/n) " y_n
			echo " "
			if [ "$y_n" == 'y' ]; then 
				cat "$u_item" | awk -F "|" '$7=="1"{print $1, $2}' | sort -n | head -n 10 
			fi
			;;

		3)
			echo " "
			read -p "Please enter the 'movie id' (1~1682): " movie_id
			sum=0
			counter=0
			average=$(cat "$u_data" | awk -v movie_id="$movie_id" -F "\t" \
				'$2==movie_id {sum+=$3; counter++} END {printf "%.5f", sum/counter}')
			printf "\naverage rating of $movie_id : $average"
			echo " "
			;;

		4)
			echo " "
			read -p "Do you want to delete the 'IMDb URL' from 'u.item'? (y/n) : " y_n
			echo " "
			if [ "$y_n" == 'y' ]; then
				cat "$u_item" | sed -E 's/http[^|]*//g' | head -n 10
			fi
			;;
		5)
			echo " "
			read -p "Do you want to get the data about users from 'u.user'? (y/n) : " y_n
			echo " "
			if [ "$y_n" == 'y' ]; then 
				cat "$u_user" \
					| sed -E 's/^([0-9]+)\|([0-9]+)\|([MF]?)\|([a-z]+)\|([0-9]+)$/user \1 is \2 years old \3 \4/g' \
					| sed -E 's/M/male/g;s/F/female/g' | head -n 10
			fi
			;;

		6)
			echo " "
			read -p "Do you want to Modify the format of 'release data' in 'u.item'? (y/n) : " y_n
			echo " "
			if [ "$y_n" == 'y' ]; then
				cat "$u_item" | sed -E 's/Jan/01/g;s/Feb/02/g;s/Mar/03/g;s/Apr/04/g;
					s/May/05/g;s/Jun/06/g;s/Jul/07/g;s/Aug/08/g;s/Sep/09/g;
					s/Oct/10/g;s/Nov/11/g;s/Dec/12/g' \
					| sed -E 's/([0-9]{2})\-([0-9]{2})\-([0-9]{4})/\3\2\1/g' \
					| sed -n '1673,1682p'
			fi
			;;

		7)
			echo " "
			read -p "Please enter the 'user id' (1~943) : " user_id
			echo " "

			movie_list=$( cat "$u_data" | awk -v user_id="$user_id" -F "\t" '$1==user_id {print $2}'\
				| sort -n | tr "\n" "|" | sed 's/|$//') 

			echo "$movie_list"
			echo " "
	
			m_list=$(echo $movie_list | tr "|" "\n")
			counter=0

			for num in $m_list; do

				counter=$((counter + 1))
				cat "$u_item" | awk -v num=$num -F "|" '$1==num {print $1"|"$2}'
				if [ $counter == 10 ]; then
					break
				fi
			done
			
			;;
		
		8)
			read -p "Do you want to get the average 'rating' of movies rated by users with 'age'\
				between 20 and 29 and 'occupation' as 'programmer'? (y/n): " y_n
			echo " "
			if [ $y_n == 'y' ]; then
				user_list=$( cat "$u_user" | awk -F "|" '$4=="programmer" && $2>=20 && $2<=29 {print $1}' | sort -n ) 

				u_list=$(echo $user_list | tr " " "\n")

				for user in $u_list; do
					cat "$u_data" | awk -v user=$user -F "\t" '$1==user {print $2"|"$3}' \
						| sort -n >> movie_rate.txt
				done
				
				movie_rate="movie_rate.txt"
				declare -A total
				declare -A count

				cat $movie_rate | awk -F "|" '{
					total[$1] += $2
					count[$1]++
				}
				END {
					for (movie_id in total){
						avg = total[movie_id] / count[movie_id]
						avg2 = (avg == int(avg) || length(avg) <= 6) ? avg : sprintf("%.5f", avg)
						printf "%s %s\n", movie_id, avg2
					}
				}' | sort -n

			fi
			;;
		9)
			echo " "
			echo "Exiting the program."
			exit
			;;

		*)
			
			echo " "
			echo "Invalid number! Please enter valid number(1-9)"
	esac
done
