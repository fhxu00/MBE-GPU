#! /bin/bash
dataset_names=(MovieLens Amazon Teams ActorMovies Wikipedia YouTube StackOverflow DBLP IMDB EuAll BookCrossing Github)
dataset_abbs=(Mti WA TM AM WC YG SO Pa IM EE BX GH)
dataset_num=${#dataset_names[@]}
data_file="./scripts/results.txt"

for ((i=0;i<dataset_num;i++)) 
do
  # echo "${dataset_abbs[i]}" >> $data_file
  ./bin/GMBEv2 -i "./datasets/${dataset_names[i]}.adj" -s 2 -t 1 -o 1 -f >> $data_file
done
