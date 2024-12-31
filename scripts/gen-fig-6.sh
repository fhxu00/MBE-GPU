#! /bin/bash
if [ ! -d "./bin" ]
then
  mkdir ./bin
fi

if [ ! -f "./bin/MBE_GPU" ]  
then
  cd ./src || exit
  mkdir build
  cd build || exit
  cmake .. 
  make
  mv MBE_GPU* ../../bin/
  cd ../../
fi

if [ ! -f "./bin/MBE" ]
then
  cd ./baselines || exit
  if [ ! -d "./MBE" ]
  then
    unzip -q MBE.zip
  fi
  cd MBE || exit
  mkdir build
  cd build || exit
  cmake ..
  make 
  mv MBE ../../../bin/
  cd ../../../
fi

if [ ! -f "./bin/mbbp" ]
then
  cd ./baselines || exit
  if [ ! -d "./cohesive_subgraph_bipartite" ]
  then
    unzip -q cohesive_subgraph_bipartite.zip
  fi
  cd cohesive_subgraph_bipartite || exit
  mkdir build
  cd build || exit
  cmake ..
  make 
  mv mbbp ../../../bin/
  cd ../../../
fi

if [ ! -f "./bin/mbe_test" ]
then
  cd ./baselines || exit
  if [ ! -d "./parallel-mbe" ]
  then
    unzip -q parallel-mbe.zip
  fi
  cd parallel-mbe || exit
  mkdir build
  cd build || exit
  cmake ..
  make
  mv mbe_test ../../../bin/
  cd ../../../
fi
dataset_names=(MovieLens Amazon Teams ActorMovies Wikipedia YouTube StackOverflow DBLP IMDB EuAll BookCrossing Github)
dataset_abbs=(Mti WA TM AM WC YG SO Pa IM EE BX GH)
dataset_num=${#dataset_names[@]}


# figure 6: running on a machine with 96-core CPUs and a GPU
result_file="./scripts/results.txt"
progress_file="./scripts/progress.txt"
cur_time=$(date "+%Y-%m-%d %H:%M:%S")
echo $cur_time "Generating fig-6. The expected time is 350000s." | tee -a $progress_file
data_file=./fig/fig-6/fig-6.data
rm $data_file
echo "# Serie mbea imbea pmbe oombe parmbe gmbe" >> $data_file
for ((i=0;i<dataset_num;i++)) 
do
  dataset_name=${dataset_names[i]}
  dataset_abb=${dataset_abbs[i]}
  printf "%s " "$dataset_abb" >> $data_file
  cur_time=$(date "+%Y-%m-%d %H:%M:%S")
  echo $cur_time "Running MBEA on dataset" ${dataset_name} | tee -a $progress_file
  ./bin/MBE -i ./datasets/${dataset_name}.adj -s 0 | tee -a ${result_file} | grep "Total processing time" | grep "[0-9.]*" -o | awk 'NR<=1 {printf "%s ", $0 }' >>$data_file 
  cur_time=$(date "+%Y-%m-%d %H:%M:%S")
  echo $cur_time "Running iMBEA on dataset" ${dataset_name} | tee -a $progress_file
  ./bin/MBE -i ./datasets/${dataset_name}.adj -s 1 | tee -a ${result_file} | grep "Total processing time" | grep "[0-9.]*" -o | awk 'NR<=1 {printf "%s ", $0 }' >>$data_file 
  cur_time=$(date "+%Y-%m-%d %H:%M:%S")
  echo $cur_time "Running PMBE on dataset" ${dataset_name} | tee -a $progress_file
  ./bin/MBE -i ./datasets/${dataset_name}.adj -s 2 | tee -a ${result_file} | grep "Total processing time" | grep "[0-9.]*" -o | awk 'NR<=1 {printf "%s ", $0 }' >>$data_file 
  cur_time=$(date "+%Y-%m-%d %H:%M:%S")
  echo $cur_time "Running ooMBEA on dataset" ${dataset_name} | tee -a $progress_file
  ./bin/mbbp "./datasets/${dataset_name}.graph" | tee -a ${result_file} | grep "Total processing time" | grep '[0-9.]*' -o | awk 'NR<=1 {printf "%s ", $0 }' >> $data_file 
  cur_time=$(date "+%Y-%m-%d %H:%M:%S")
  echo $cur_time "Running PARMBE on dataset" ${dataset_name} | tee -a $progress_file
  ./bin/mbe_test "./datasets/${dataset_name}.graph" 96 | tee -a ${result_file} | grep "Total processing time" | grep '[0-9.]*' -o | awk 'NR<=1 {printf "%s ", $0}' >> $data_file 
  cur_time=$(date "+%Y-%m-%d %H:%M:%S")
  echo $cur_time "Running GMBE on dataset" ${dataset_name} | tee -a $progress_file
  ./bin/MBE_GPU -i "./datasets/${dataset_name}.adj" -s 2 -t 1 -o 1 -f | tee -a ${result_file} | grep "Total processing time" | grep '[0-9.]*' -o | awk  'NR<=1 {printf "%s ", $0}'  >> $data_file
  echo >> $data_file
done
