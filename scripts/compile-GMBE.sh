#! /bin/bash
if [ ! -d "./bin" ]
then
  mkdir ./bin
fi

rm ./bin/MBE_GPU
if [ ! -f "./bin/MBE_GPU" ]  
then
  cd ./src || exit
  if [ ! -d "./build" ]
  then
    mkdir ./build
  fi
  cd build || exit
  cmake .. 
  make MBE_GPU
  mv MBE_GPU* ../../bin/
  cd ../../
fi

rm ./bin/GMBEv2
if [ ! -f "./bin/GMBEv2" ]  
then
  cd ./src || exit
  if [ ! -d "./build" ]
  then
    mkdir ./build
  fi
  cd build || exit
  cmake .. 
  make GMBEv2
  mv GMBEv2 ../../bin/
  cd ../../
fi
