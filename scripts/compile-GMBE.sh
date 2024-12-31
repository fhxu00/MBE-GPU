#! /bin/bash
if [ ! -d "./bin" ]
then
  mkdir ./bin
fi

if [ ! -f "./bin/MBE_GPU" ]  
then
  cd ./src || exit
  if [ ! -d "./build" ]
  then
    mkdir ./build
  fi
  cd build || exit
  cmake .. 
  make
  mv MBE_GPU* ../../bin/
  cd ../../
fi

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
