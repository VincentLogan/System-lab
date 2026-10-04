.text
.globl  bubble_sort

bubble_sort:
    addi a1, a1, -1 
    #a1(len)作为判断有没有结束循环的依据，长度为n，需要n-1次比较，初始化a1--，当a1 = 0时，完成排序

.Out_loop:
    li t3, 0            # t3为内层循环的计数器，初始化为0
    addi t4, a0, 0      # t4指针初始化复位到数组首地址
    beqz a1, .exit      # 如果剩余需要比较的次数为0说明排序完成

.Inner_loop:
    ld t1, 0(t4)                    # 从内存中取出当前元素t1
    ld t2, 8(t4)                    # 从内存中取出当前元素t2，t2和t1的地址相对间隔为8
    ble t1, t2, .skip_exchange      # 如果A <= B，无须交换，直接跳过交换代码
    sd t2, 0(t4)                    # 交换在内存中的值
    sd t1, 8(t4)

.skip_exchange:
    addi t4, t4, 8                  # 指针向后移动8字节（一个long long元素长度）
    addi t3, t3, 1                  # 计数器递增
    blt t3, a1, .Inner_loop         # 当t3 < a1说明比较次数没达到a1，跳转内部循环继续比较

    addi a1, a1, -1                 # 当t3 = a1，本轮内层循环结束，让下一轮需要比较次数减一
    j .Out_loop                     # 跳转回外部循环，判断是否要继续进行内部循环

.exit:
    jr ra                           # 结束函数，回到主函数
