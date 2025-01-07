//
/*******************************************************************************

 File name:     main.cpp
 Author:        FeiYehua

 Description:   Created for ApnounceDecrypt-Metal in 2025

 History:
 2025/1/4: File created.

 ********************************************************************************/

#define NS_PRIVATE_IMPLEMENTATION
#define CA_PRIVATE_IMPLEMENTATION
#define MTL_PRIVATE_IMPLEMENTATION
#include <Foundation/Foundation.hpp>
#include <Metal/Metal.hpp>
#include <QuartzCore/QuartzCore.hpp>

#include "metalComputeWrapper.hpp"
#include <chrono>
#include <iostream>

uint64_t start, hostResult;
int main(int argc, const char *argv[]) {
    //    NS::AutoreleasePool* pPool   = NS::AutoreleasePool::alloc()->init();
    MTL::Device *pDevice = MTL::CreateSystemDefaultDevice();

    // Create the custom object used to encapsulate the Metal code.
    // Initializes objects to communicate with the GPU.
    metalComputeWrapper *computer = new metalComputeWrapper();
    computer->initWithDevice(pDevice);

    // Create buffers to hold data
    computer->prepareData();
    std::cout << argv[0] << std::endl;
    auto fp = fopen("CurrentProgress.txt", "r+");
    if (fp == NULL)
    {
        fp = fopen("CurrentProgress.txt", "w+");
    }
    if (fscanf(fp, "%llu", &start) != 1) {
        start = 0;
    }
    for (uint64_t i = start; i <= start + 10000; i++) {
        // Time the compute phase.
        auto start = std::chrono::steady_clock::now();

        // Send a command to the GPU to perform the calculation.
        computer->sendComputeCommand(0);

        // End of compute phase.
        auto end = std::chrono::steady_clock::now();
        auto delta_time = end - start;
        hostResult = computer->getReasult();
        //        pPool->release();

        std::cout
            << "Computation completed in "
            << std::chrono::duration<double, std::milli>(delta_time).count()
            << " ms for sha1 of count " << (1 << 30) << ".\n";
        if (hostResult != 0) {
            auto fpResult = fopen("Result.txt", "w");
            fprintf(fpResult, "%llu\n", hostResult);
            // return 0;
        }
        fseek(fp, 0L, SEEK_SET);
        fprintf(fp, "%llu\n", i);
    }

    return 0;
}
