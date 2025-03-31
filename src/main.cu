﻿#include <stdio.h>

#include <unistd.h>

#include <cub/block/block_load.cuh>
#include <cub/block/block_radix_sort.cuh>
#include <cub/block/block_store.cuh>
#include <cub/config.cuh>
#include <set>
#include <sys/time.h>

#include "BiGraph.h"
#include "BicliqueFinder.h"
#include "IterFinderGpu.h"
#include "Utility.h"
#include "unistd.h"
#include "signal.h"

BicliqueFinder *finder_global = nullptr;

void FinderTest(BicliqueFinder *finder = nullptr, char *fn = nullptr)
{
  if (finder == nullptr)
    return;
  finder->Execute();
  finder->PrintResult(fn);
  delete finder;
}

bool printSMTime = false;

void GpuTest()
{
  std::vector<int> array;
  int size = 1 << 10;
  for (int i = 0; i < size; i++)
  {
    array.emplace_back(rand() & 0x3ff);
    printf("%d ", array[i]);
  }
  printf("\n");
  int *dev_array;
  gpuErrchk(cudaSetDevice(0));
  gpuErrchk(cudaMalloc((void **)&dev_array, size * sizeof(int)));
  gpuErrchk(cudaMemcpy(dev_array, &array[0], size * sizeof(int),
                       cudaMemcpyHostToDevice));
  // BitonicSortPassWarp<<<1, 32>>>(dev_array, size);
  gpuErrchk(cudaGetLastError());
  gpuErrchk(cudaDeviceSynchronize());
  gpuErrchk(cudaMemcpy(&array[0], dev_array, size * sizeof(int),
                       cudaMemcpyDeviceToHost));
  gpuErrchk(cudaFree(dev_array));
  for (int i = 0; i < size; i++)
  {
    printf("%d ", array[i]);
  }
  printf("\n");
}

void PrintGpuProp()
{
  struct cudaDeviceProp dev_prop;
  cudaGetDeviceProperties(&dev_prop, 0);

  std::cout << "shared memory per block:" << dev_prop.sharedMemPerBlock
            << std::endl;
  std::cout << "maxGridSize:" << dev_prop.maxGridSize[0] << std::endl;
  std::cout << "sm counts:" << dev_prop.multiProcessorCount << std::endl;
  std::cout << "maxThreadsPerMultiProcessor:"
            << dev_prop.maxThreadsPerMultiProcessor << std::endl;
  std::cout << "totalGlobalMem:" << dev_prop.totalGlobalMem << std::endl;
  std::cout << "l2CacheSize:" << dev_prop.l2CacheSize << std::endl;
  std::cout << "maxThreadsPerBlock:" << dev_prop.maxThreadsPerBlock
            << std::endl;
  std::cout << "regsPerMultiprocessor:" << dev_prop.regsPerMultiprocessor
            << std::endl;
  std::cout << std::endl;
}

void sigProcessFor19(int sigNum)
{
  printf("Total processing time is more than 7200s\n");
  finder_global->PrintResult(nullptr);
  exit(0);
}

void timerProcess(int signo)
{
  static int count = 0;
  printf("tick counts: %d\n", count++);
  dynamic_cast<IterFinderGpu *>(finder_global)->SyncMB();
  finder_global->PrintResult(nullptr);
}

int main(int argc, char *argv[])
{

  signal(SIGTERM, sigProcessFor19);
  signal(SIGALRM, timerProcess);

  struct cudaDeviceProp dev_prop;
  cudaGetDeviceProperties(&dev_prop, 0);
  if (MAX_SM != dev_prop.multiProcessorCount)
  {
    printf("Warning: the SMs in GPUs is %d node %d\n",
           dev_prop.multiProcessorCount, MAX_SM);
  }

  int ngpus = 1;
  int op;
  Option opt;
  int sel = 0;
  int bound_height = 20;
  int bound_size = 1500;
  char graph_name[80] = "db/Writers.adj";
  int limit = 0;
  int alpha = 1;

  while ((op = getopt(argc, argv, "l:h:x:i:s:m:n:t:o:fpa:")) != -1)
  {
    switch (op)
    {
    case 'i':
      memcpy(graph_name, optarg, strlen(optarg) + 1);
      break;
    case 't':
      opt.uvtrans = atoi(optarg);
      break;
    case 's':
      sel = atoi(optarg);
      break;
    case 'o':
      opt.order = atoi(optarg);
      break;
    case 'f':
      opt.fast_mode = 1;
      break;
    case 'm':
      bound_height = atoi(optarg);
      break;
    case 'n':
      bound_size = atoi(optarg);
      break;
    case 'x':
      ngpus = atoi(optarg);
      break;
    case 'p':
      printSMTime = true;
      break;
    case 'l':
      limit = atoi(optarg);
      break;
    case 'a':
      alpha = atoi(optarg);
      break;
    }
  }
  if (limit != 0)
  {
    itimerval tick;
    tick.it_value.tv_sec = limit;
    tick.it_value.tv_usec = 0;
    tick.it_interval.tv_sec = limit;
    tick.it_interval.tv_usec = 0;
    setitimer(ITIMER_REAL, &tick, NULL);
  }
  double start_t = get_cur_time();
  CSRBiGraph *graph = new CSRBiGraph();
  graph->Read(graph_name, opt);
  //printf("Max blocks:%u Warps per block:%u Max1d:0x%x Max2d:0x%x\n", MAX_BLOCKS,
  //       WARP_PER_BLOCK, MAX_DEGREE_BOUND, MAX_2_H_DEGREE_BOUND);
  //printf("trans:%d sel:%d order:%d fast_mode:%d\n", opt.uvtrans, sel, opt.order,
  //       opt.fast_mode);

  printf("%s, %d, %s, %u, %u, %d, %d", argv[0], sel, graph_name, MAX_BLOCKS, WARP_PER_BLOCK, bound_height, bound_size);
#ifdef NN
  printf(", %u", NN);
#endif
  //printf("trans:%d sel:%d order:%d fast_mode:%d\n", opt.uvtrans, sel, opt.order,
  //       opt.fast_mode);

  //printf("Graph load time: %lf s\n", get_cur_time() - start_t);
  switch (sel)
  {
  case 0:
    finder_global = new IterFinderGpu(graph);
    break;
  case 1:
    finder_global = new IterFinderGpu2(graph);
    break;
  case 2:
    finder_global = new IterFinderGpu6(graph, bound_height, bound_size);
    break;
  case 3:
    finder_global = new IterFinderGpu7(graph, ngpus);
    break;
  case 4:
    finder_global = new IterFinderGpu8(graph, ngpus, alpha);
    break;
  case 5:
    finder_global = new IterFinderGpu9(graph, ngpus);
    break;
  case 6:
    finder_global = new IterFinderGpu10(graph, ngpus);
    break;
  }
  FinderTest(finder_global);
}
