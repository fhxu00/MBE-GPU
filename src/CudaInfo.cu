#include <iostream>
#include <cuda_runtime.h>
#include <string>
#include <getopt.h>

void printDeviceProperties(int deviceId, bool printArch, bool printSMCount) {
    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, deviceId);

    if (printArch) {
        // Print the CMake compilation instructions
        std::cout << "-gencode;arch=compute_" << prop.major << prop.minor << ",code=sm_" << prop.major << prop.minor;
    }

    if (printSMCount) {
        // Print the number of SMs
        std::cout << prop.multiProcessorCount;
    }
}

int main(int argc, char** argv) {
    int deviceCount;
    // Get the number of available devices
    cudaGetDeviceCount(&deviceCount);

    if (deviceCount == 0) {
        std::cerr << "No CUDA devices found." << std::endl;
        return -1;
    }

    int opt;
    bool printArch = false;
    bool printSMCount = false;

    // parse command line options
    while ((opt = getopt(argc, argv, "as")) != -1) {
        switch (opt) {
            case 'a':
                printArch = true;
                break;
            case 's':
                printSMCount = true;
                break;
            default:
                std::cerr << "Usage: " << argv[0] << " [-a] [-s]" << std::endl;
                return -1;
        }
    }

    // 打印所有设备的属性
    printDeviceProperties(0, printArch, printSMCount);

    return 0;
}
