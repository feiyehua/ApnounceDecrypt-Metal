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
uint64_t getSha1(device const uint32_t* mes1,uint32_t mes2)
{
    uint32_t mes[80];
    mes[0] = *mes1;
    mes[1] = mes2;
    mes[2] = 1U << 31;
    mes[3] = 0;
    mes[4] = 0;
    mes[5] = 0;
    mes[6] = 0;
    mes[7] = 0;
    mes[8] = 0;
    mes[9] = 0;
    mes[10] = 0;
    mes[11] = 0;
    mes[12] = 0;
    mes[13] = 0;
    mes[14] = 0;
    mes[15] = 64;

    mes[16] = ROT((mes[13] ^ mes[8] ^ mes[2] ^ mes[0]), 1);
    mes[17] = ROT((mes[14] ^ mes[9] ^ mes[3] ^ mes[1]), 1);
    mes[18] = ROT((mes[15] ^ mes[10] ^ mes[4] ^ mes[2]), 1);
    mes[19] = ROT((mes[16] ^ mes[11] ^ mes[5] ^ mes[3]), 1);
    mes[20] = ROT((mes[17] ^ mes[12] ^ mes[6] ^ mes[4]), 1);
    mes[21] = ROT((mes[18] ^ mes[13] ^ mes[7] ^ mes[5]), 1);
    mes[22] = ROT((mes[19] ^ mes[14] ^ mes[8] ^ mes[6]), 1);
    mes[23] = ROT((mes[20] ^ mes[15] ^ mes[9] ^ mes[7]), 1);
    mes[24] = ROT((mes[21] ^ mes[16] ^ mes[10] ^ mes[8]), 1);
    mes[25] = ROT((mes[22] ^ mes[17] ^ mes[11] ^ mes[9]), 1);
    mes[26] = ROT((mes[23] ^ mes[18] ^ mes[12] ^ mes[10]), 1);
    mes[27] = ROT((mes[24] ^ mes[19] ^ mes[13] ^ mes[11]), 1);
    mes[28] = ROT((mes[25] ^ mes[20] ^ mes[14] ^ mes[12]), 1);
    mes[29] = ROT((mes[26] ^ mes[21] ^ mes[15] ^ mes[13]), 1);
    mes[30] = ROT((mes[27] ^ mes[22] ^ mes[16] ^ mes[14]), 1);
    mes[31] = ROT((mes[28] ^ mes[23] ^ mes[17] ^ mes[15]), 1);
    mes[32] = ROT((mes[29] ^ mes[24] ^ mes[18] ^ mes[16]), 1);
    mes[33] = ROT((mes[30] ^ mes[25] ^ mes[19] ^ mes[17]), 1);
    mes[34] = ROT((mes[31] ^ mes[26] ^ mes[20] ^ mes[18]), 1);
    mes[35] = ROT((mes[32] ^ mes[27] ^ mes[21] ^ mes[19]), 1);
    mes[36] = ROT((mes[33] ^ mes[28] ^ mes[22] ^ mes[20]), 1);
    mes[37] = ROT((mes[34] ^ mes[29] ^ mes[23] ^ mes[21]), 1);
    mes[38] = ROT((mes[35] ^ mes[30] ^ mes[24] ^ mes[22]), 1);
    mes[39] = ROT((mes[36] ^ mes[31] ^ mes[25] ^ mes[23]), 1);
    mes[40] = ROT((mes[37] ^ mes[32] ^ mes[26] ^ mes[24]), 1);
    mes[41] = ROT((mes[38] ^ mes[33] ^ mes[27] ^ mes[25]), 1);
    mes[42] = ROT((mes[39] ^ mes[34] ^ mes[28] ^ mes[26]), 1);
    mes[43] = ROT((mes[40] ^ mes[35] ^ mes[29] ^ mes[27]), 1);
    mes[44] = ROT((mes[41] ^ mes[36] ^ mes[30] ^ mes[28]), 1);
    mes[45] = ROT((mes[42] ^ mes[37] ^ mes[31] ^ mes[29]), 1);
    mes[46] = ROT((mes[43] ^ mes[38] ^ mes[32] ^ mes[30]), 1);
    mes[47] = ROT((mes[44] ^ mes[39] ^ mes[33] ^ mes[31]), 1);
    mes[48] = ROT((mes[45] ^ mes[40] ^ mes[34] ^ mes[32]), 1);
    mes[49] = ROT((mes[46] ^ mes[41] ^ mes[35] ^ mes[33]), 1);
    mes[50] = ROT((mes[47] ^ mes[42] ^ mes[36] ^ mes[34]), 1);
    mes[51] = ROT((mes[48] ^ mes[43] ^ mes[37] ^ mes[35]), 1);
    mes[52] = ROT((mes[49] ^ mes[44] ^ mes[38] ^ mes[36]), 1);
    mes[53] = ROT((mes[50] ^ mes[45] ^ mes[39] ^ mes[37]), 1);
    mes[54] = ROT((mes[51] ^ mes[46] ^ mes[40] ^ mes[38]), 1);
    mes[55] = ROT((mes[52] ^ mes[47] ^ mes[41] ^ mes[39]), 1);
    mes[56] = ROT((mes[53] ^ mes[48] ^ mes[42] ^ mes[40]), 1);
    mes[57] = ROT((mes[54] ^ mes[49] ^ mes[43] ^ mes[41]), 1);
    mes[58] = ROT((mes[55] ^ mes[50] ^ mes[44] ^ mes[42]), 1);
    mes[59] = ROT((mes[56] ^ mes[51] ^ mes[45] ^ mes[43]), 1);
    mes[60] = ROT((mes[57] ^ mes[52] ^ mes[46] ^ mes[44]), 1);
    mes[61] = ROT((mes[58] ^ mes[53] ^ mes[47] ^ mes[45]), 1);
    mes[62] = ROT((mes[59] ^ mes[54] ^ mes[48] ^ mes[46]), 1);
    mes[63] = ROT((mes[60] ^ mes[55] ^ mes[49] ^ mes[47]), 1);
    mes[64] = ROT((mes[61] ^ mes[56] ^ mes[50] ^ mes[48]), 1);
    mes[65] = ROT((mes[62] ^ mes[57] ^ mes[51] ^ mes[49]), 1);
    mes[66] = ROT((mes[63] ^ mes[58] ^ mes[52] ^ mes[50]), 1);
    mes[67] = ROT((mes[64] ^ mes[59] ^ mes[53] ^ mes[51]), 1);
    mes[68] = ROT((mes[65] ^ mes[60] ^ mes[54] ^ mes[52]), 1);
    mes[69] = ROT((mes[66] ^ mes[61] ^ mes[55] ^ mes[53]), 1);
    mes[70] = ROT((mes[67] ^ mes[62] ^ mes[56] ^ mes[54]), 1);
    mes[71] = ROT((mes[68] ^ mes[63] ^ mes[57] ^ mes[55]), 1);
    mes[72] = ROT((mes[69] ^ mes[64] ^ mes[58] ^ mes[56]), 1);
    mes[73] = ROT((mes[70] ^ mes[65] ^ mes[59] ^ mes[57]), 1);
    mes[74] = ROT((mes[71] ^ mes[66] ^ mes[60] ^ mes[58]), 1);
    mes[75] = ROT((mes[72] ^ mes[67] ^ mes[61] ^ mes[59]), 1);
    mes[76] = ROT((mes[73] ^ mes[68] ^ mes[62] ^ mes[60]), 1);
    mes[77] = ROT((mes[74] ^ mes[69] ^ mes[63] ^ mes[61]), 1);
    mes[78] = ROT((mes[75] ^ mes[70] ^ mes[64] ^ mes[62]), 1);
    mes[79] = ROT((mes[76] ^ mes[71] ^ mes[65] ^ mes[63]), 1);
    
    
    // Perform sha calculation
    uint32_t A,B,C,D,E,temp;
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
    
    return (A==target[0]&&B==target[1]&&C==target[2]&&D==target[3]&&E==target[4]);
}

//每个block的计算函数：确定消息的前48bit，计算最后16bit对应的hash
kernel void blockSha1(device const uint32_t* mes1 [[buffer(0)]],
                      device uint64_t* result [[buffer(1)]],
                      device uint32_t* calcBuffer [[buffer(2)]],
                      uint index [[thread_position_in_grid]],
                      uint thread_position_in_threadgroup [[ thread_position_in_threadgroup ]])
{
    uint32_t mes2=index;
    //printf("%d\n",mes2);
    for(int i=0;i<(1<<16);i++)
    {
        if(getSha1(mes1,(mes2<<16)+i)!=0)
        {
            *result = ((uint64_t)*mes1 << 32) + ((uint64_t)mes2<<16) + i;
            break;
        }
    }
}

