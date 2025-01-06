/*** 
 * @Author       : FeiYehua
 * @Date         : 2025-01-01 12:47:59
 * @LastEditTime : 2025-01-01 12:48:02
 * @LastEditors  : FeiYehua
 * @Description  : 
 * @FilePath     : sha1.cpp
 * @     © 2024 FeiYehua
 */


#include <metal_stdlib>
using namespace metal;

//constant uint32_t target[5]={0xabc21d3f,0x9d5d98ec,0xae9f3d51,0x44752901,0x71f2bbed};
constant uint32_t target[5]={0xfcdfc642,0x15aa290c,0x42ef66bc,0x6bd3c2ea,0xb74af5fd};

// 32-bit rotate
inline uint32_t ROT(uint32_t x, int n) {
    return ((x << n) | (x >> (32 - n)));
}

// SHA init constants
#define I1 1732584193U
#define I2 4023233417U
#define I3 2562383102U
#define I4 271733878U
#define I5 3285377520U

// Main loop SHA logical functions f1 to f4
inline uint32_t f1(uint32_t x, uint32_t y, uint32_t z)
{
    return ((x & y) | (~x & z));
}
inline uint32_t f2(uint32_t x, uint32_t y, uint32_t z) { return (x ^ y ^ z); }
inline uint32_t f3(uint32_t x, uint32_t y, uint32_t z)
{
    return ((x & y) | (x & z) | (y & z));
}
inline uint32_t f4(uint32_t x, uint32_t y, uint32_t z) { return (x ^ y ^ z); }

// Calculation functions for 80 rounds of SHA1
#define CALC1(i)                                                               \
    temp = ROT(A, 5) + f1(B, C, D) + mes[i] + E + 1518500249U;                     \
    E = D;                                                                       \
    D = C;                                                                       \
    C = ROT(B, 30);                                                              \
    B = A;                                                                       \
    A = temp

#define CALC2(i)                                                               \
    temp = ROT(A, 5) + f2(B, C, D) + mes[i] + E + 1859775393U;                     \
    E = D;                                                                       \
    D = C;                                                                       \
    C = ROT(B, 30);                                                              \
    B = A;                                                                       \
    A = temp

#define CALC3(i)                                                               \
    temp = ROT(A, 5) + f3(B, C, D) + mes[i] + E + 2400959708U;                     \
    E = D;                                                                       \
    D = C;                                                                       \
    C = ROT(B, 30);                                                              \
    B = A;                                                                       \
    A = temp

#define CALC4(i)                                                               \
    temp = ROT(A, 5) + f4(B, C, D) + mes[i] + E + 3395469782U;                     \
    E = D;                                                                       \
    D = C;                                                                       \
    C = ROT(B, 30);                                                              \
    B = A;                                                                       \
    A = temp



// 我们考虑计算一个16位16进制串的sha1.
// 也就是消息是一个64位整数。
// 需要计算的消息长度是64bit。
// 我们每次分配一个block计算2^16个sha1，
// 每个grid总计算2^16*2^16个sha1，
// 那么每个block的前48bit是可以确定的

// 初始化消息，附加填充位
//mes1是前32bit，mes2是后32bit
uint64_t getSha1(device const uint32_t* mes1,uint32_t mes2,device uint32_t* mes)
{
    //printf("hello\n");
    //uint32_t* mes=(uint32_t*)malloc(sizeof(uint32_t)*64);
    // uint32_t mes[80];
    // mes = (uint32_t *)malloc(sizeof(uint32_t) * 64);
    // cudaMalloc(&mes,sizeof(uint32_t)*64);

    mes[0] = *mes1;
    mes[1] = mes2;
    mes[2] = 1U << 31;
#pragma unroll
    for (int i = 3; i <= 14; i++)
    {
        mes[i] = 0;
    }
    // memset(mes + 3, 0, 14 * sizeof(uint32_t));
    mes[15] = 64;
    // for(int i=0;i<16;i++)
    // {
    //     printf("%x\n",mes[i]);
    // }
#pragma unroll
    for (int i = 16; i < 80; i++)
    {
        mes[i] = ROT((mes[i - 3] ^ mes[i - 8] ^ mes[i - 14] ^ mes[i - 16]), 1);
    }
    uint32_t A,B,C,D,E,temp;
    A = I1;
    B = I2;
    C = I3;
    D = I4;
    E = I5;
        // Perform sha calculation
    A = I1;
    B = I2;
    C = I3;
    D = I4;
    E = I5;

    // 80 rounds
    CALC1(0);
    CALC1(1);
    CALC1(2);
    CALC1(3);
    CALC1(4);
    CALC1(5);
    CALC1(6);
    CALC1(7);
    CALC1(8);
    CALC1(9);
    CALC1(10);
    CALC1(11);
    CALC1(12);
    CALC1(13);
    CALC1(14);
    CALC1(15);
    CALC1(16);
    CALC1(17);
    CALC1(18);
    CALC1(19);
    CALC2(20);
    CALC2(21);
    CALC2(22);
    CALC2(23);
    CALC2(24);
    CALC2(25);
    CALC2(26);
    CALC2(27);
    CALC2(28);
    CALC2(29);
    CALC2(30);
    CALC2(31);
    CALC2(32);
    CALC2(33);
    CALC2(34);
    CALC2(35);
    CALC2(36);
    CALC2(37);
    CALC2(38);
    CALC2(39);
    CALC3(40);
    CALC3(41);
    CALC3(42);
    CALC3(43);
    CALC3(44);
    CALC3(45);
    CALC3(46);
    CALC3(47);
    CALC3(48);
    CALC3(49);
    CALC3(50);
    CALC3(51);
    CALC3(52);
    CALC3(53);
    CALC3(54);
    CALC3(55);
    CALC3(56);
    CALC3(57);
    CALC3(58);
    CALC3(59);
    CALC4(60);
    CALC4(61);
    CALC4(62);
    CALC4(63);
    CALC4(64);
    CALC4(65);
    CALC4(66);
    CALC4(67);
    CALC4(68);
    CALC4(69);
    CALC4(70);
    CALC4(71);
    CALC4(72);
    CALC4(73);
    CALC4(74);
    CALC4(75);
    CALC4(76);
    CALC4(77);
    CALC4(78);
    CALC4(79);

    A += I1;
    B += I2;
    C += I3;
    D += I4;
    E += I5;
    

    if(A==target[0]&&B==target[1]&&C==target[2]&&D==target[3]&&E==target[4])
    {
        return ((uint64_t)mes1<<32)+mes2;
    }
    else return 0;
}

//每个block的计算函数：确定消息的前48bit，计算最后16bit对应的hash
kernel void blockSha1(device const uint32_t* mes1 [[buffer(0)]],
                      device uint64_t* result [[buffer(1)]],
                      device uint32_t* calcBuffer [[buffer(2)]],
                      uint index [[thread_position_in_grid]])
{
    uint32_t mes2=index;
    //printf("%d\n",mes2);
    for(int i=0;i<(1<<16);i++)
    {
        if(getSha1(mes1,(mes2<<16)+i,calcBuffer+(mes2<<7))!=0)
        {
            *result = ((uint64_t)*mes1 << 32) + ((uint64_t)mes2<<16) + i;
            break;
        }
    }
}

////start是给定的起始点：前16bit
//void cal(uint32_t start,device uint64_t* result,device uint32_t* calcBuffer)
//{
//    
//}
