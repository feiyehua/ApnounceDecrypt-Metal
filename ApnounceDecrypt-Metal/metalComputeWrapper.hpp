//
//  metalAddWrapper.hpp
//  metal-test
//
//  Created by Sayan on 29/12/21.
//

#ifndef metalComputeWrapper_hpp
#define metalComputeWrapper_hpp

#include <Metal/Metal.hpp>

const unsigned int ARRAY_LENGTH = (1 << 7) * (1 << 16); //(1<<23);
// 不是，哥们！苹果你做出来了这么豪华的动画，居然识别不出来我写了个数组越界？硬控一早上……
const unsigned int BUFFER_SIZE = ARRAY_LENGTH * sizeof(uint32_t);
const unsigned int GRID_SIZE = 1<<14;

class metalComputeWrapper {
  public:
    MTL::Device *mDevice;

    // The compute pipeline generated from the compute kernel in the .metal
    // shader file.
    MTL::ComputePipelineState *mComputeFunctionPSO;

    // The command queue used to pass commands to the device.
    MTL::CommandQueue *mCommandQueue;

    // Buffers to hold data.
    MTL::Buffer *result;
    MTL::Buffer *calcBuffer;
    MTL::Buffer *mStart;

    void initWithDevice(MTL::Device *);
    void prepareData();
    void sendComputeCommand(uint32_t mStart);
    uint64_t getReasult();

  private:
    void encodeComputeCommand(MTL::ComputeCommandEncoder *);
};

#endif /* metalComputeWrapper_hpp */
