.text
.globl  fibonacci

fibonacci:
    addi    sp, sp, -32     #函数序言，开辟32个字节的栈帧
    sd      ra, 24(sp)      #把返回地址ra存入栈中，避免子函数调用的时候被覆盖
    sd      s0, 16(sp)      #备份保存寄存器s0，保证回归父函数的时候将其复原      
    addi    s0, sp, 32      #让s0指向栈顶，作为fp使用
    sd      a0, -24(s0)     #存参数入栈

    ld      a1, -24(s0)             #从栈中读取本层参数
    li      a5, 1                   #确定递归边界，当n=1时停止递归
    bgt     a1, a5, .first_call     #将本层参数a1和边界比较，确定是进入递归还是开始返回
    li      a0, 1                   #如果不用递归，也就是base case（n=1/0）则函数值是1，存入a0准备返回
    j       .exit                   #切换到返回部分

.first_call: 
    addi    a1, a1, -1              #计算下层函数的参数 n-1 
    mv      a0,  a1                 #子函数参数只能放在a0，将参数复制到a0，准备递归
    call    fibonacci               #调用自己，计算fibonacci(n-1)

    mv      a3, a0                  #子函数计算结束，从a0获得子函数的取值，存入a3
    sd      a3, -32(s0)             #将a3存入栈中保存，避免后续调用时a3被覆盖
    
    ld      a1, -24(s0)             #重新获取本层参数，准备计算fibonacci(n-2)参数
    addi    a2, a1, -2              #计算下层函数的参数 n-2
    mv      a0, a2                  #将参数复制到a0，准备递归
    call    fibonacci               #调用自己，计算fibonacci(n-2)

    mv      a4, a0                  #将f(n-2)的值保存在a4，准备计算本层的结果a3+a4
    ld      a3, -32(s0)             #由于中间有函数调用，a3的值不再可信，需要从栈帧中取出之前计算结果

    add     a5, a3, a4              #计算最终结果
    mv      a0, a5                  #按照约定将最终结果存入a0，准备返回

.exit:
    ld      ra, 24(sp)              #获取真正的返回地址
    ld      s0, 16(sp)              #恢复s0
    addi    sp, sp, 32              #恢复栈帧
    jr      ra                      #返回父函数
    