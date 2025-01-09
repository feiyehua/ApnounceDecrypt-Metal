//
//  metalAddWrapper.cpp
//  metal-test
//
//  Created by Sayan on 29/12/21.
//

#include "metalComputeWrapper.hpp"
#include <iostream>

void metalComputeWrapper::initWithDevice(MTL::Device *device) {
    mDevice = device;
    NS::Error *error;

    auto defaultLibrary = mDevice->newDefaultLibrary();

    if (!defaultLibrary) {
        std::cerr << "Failed to find the default library.\n";
        exit(-1);
    }

    auto functionName =
        NS::String::string("blockSha1", NS::ASCIIStringEncoding);
    auto computeFunction = defaultLibrary->newFunction(functionName);

    if (!computeFunction) {
        std::cerr << "Failed to find the compute function.\n";
    }

    mComputeFunctionPSO =
        mDevice->newComputePipelineState(computeFunction, &error);

    if (!computeFunction) {
        std::cerr << "Failed to create the pipeline state object.\n";
        exit(-1);
    }

    mCommandQueue = mDevice->newCommandQueue();

    if (!mCommandQueue) {
        std::cerr << "Failed to find command queue.\n";
        exit(-1);
    }
}

void metalComputeWrapper::prepareData() {
    // Allocate three buffers to hold our initial data and the result.
    result =
        mDevice->newBuffer(sizeof(uint64_t), MTL::ResourceStorageModeShared);
    mStart =
        mDevice->newBuffer(sizeof(uint32_t), MTL::ResourceStorageModeShared);
    mStart2 =
        mDevice->newBuffer(sizeof(uint32_t), MTL::ResourceStorageModeShared);
}

void metalComputeWrapper::sendComputeCommand(uint32_t startLoc,
                                             uint32_t startLoc2) {
    // 为当前操作写入起始点
    uint32_t *deviceStart = (uint32_t *)mStart->contents();
    uint32_t *deviceStart2 = (uint32_t *)mStart2->contents();
    *deviceStart = startLoc;
    *deviceStart2 = startLoc2;
    // Create a command buffer to hold commands.
    MTL::CommandBuffer *commandBuffer = mCommandQueue->commandBuffer();
    assert(commandBuffer != nullptr);

    // Start a compute pass.
    MTL::ComputeCommandEncoder *computeEncoder =
        commandBuffer->computeCommandEncoder();
    assert(computeEncoder != nullptr);

    encodeComputeCommand(computeEncoder);

    // End the compute pass.
    computeEncoder->endEncoding();

    // Execute the command.
    commandBuffer->commit();

    // Normally, you want to do other work in your app while the GPU is running,
    // but in this example, the code simply blocks until the calculation is
    // complete.
    commandBuffer->waitUntilCompleted();
}

void metalComputeWrapper::encodeComputeCommand(
    MTL::ComputeCommandEncoder *computeEncoder) {
    // Encode the pipeline state object and its parameters.
    computeEncoder->setComputePipelineState(mComputeFunctionPSO);
    computeEncoder->setBuffer(mStart, 0, 0);
    computeEncoder->setBuffer(result, 0, 1);
    computeEncoder->setBuffer(mStart2, 0, 2);
    
    MTL::Size gridSize = MTL::Size(GRID_SIZE, 1, 1);

    //     Calculate a threadgroup size.
    NS::UInteger threadGroupSize =
        mComputeFunctionPSO->maxTotalThreadsPerThreadgroup();
    if (threadGroupSize > GRID_SIZE) {
        threadGroupSize = GRID_SIZE;
    }
    MTL::Size threadgroupSize = MTL::Size(threadGroupSize, 1, 1);

    // Encode the compute command.
    computeEncoder->dispatchThreads(gridSize, threadgroupSize);
}
uint64_t metalComputeWrapper::getReasult() {
    uint64_t *_t = (uint64_t *)result->contents();
    return *(_t);
}
