### lab3
---

## lab3-1

### 设计简单的有限状态机

#### 一、使用enum语法设计FSM

- **设计思路**：
  1. 采用enum枚举方法实现有限状态机，先使用enum定义一个枚举类型，由于该状态机只有四个状态，该类型宽度设为**2位**即可，即使用两位数据表示四个状态
  2. `{S0,S1,S2,S3}`一次性枚举常量，分别代表四个状态
  3. **异步复位**，当复位信号处于低电平，直接将状态置S0
  4. **同步更新**，当时钟上沿到来时，根据当前状态和输入X，通过状态表决定跳转到哪个状态
   
- **代码实现**：

```verilog
module FSM(
    input rstn,
    input clk,
    input a,
    input b,
    output [1:0] state
);
    typedef enum logic [1:0] {S0, S1, S2, S3} fsm_state;
    fsm_state state_reg;
    always @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            state_reg <= S0;
        end
        else begin
            case(state_reg) 
                S0: if(a == 0 && b == 1) state_reg <= S0;
                    else if(a == 1) state_reg <= S1;
                    else state_reg <= S0;

                S1: if(a == 0 && b == 1) state_reg <= S0;
                    else if(a == 1) state_reg <= S2;
                    else state_reg <= S1;

                S2: if(a == 0 && b == 1) state_reg <= S0;
                    else if(a == 1) state_reg <= S3;
                    else state_reg <= S2;

                S3: state_reg <= S3;

            endcase
        end
    end

    assign state = state_reg;
endmodule
```

- **仿真截图 & 仿真通过截图**：
<div style="display: flex;">
  <img src="./picture/1.png" alt="Image 1" style="width: 48%; max-width: 100%; height: auto;">
  <img src="./picture/success1.png" alt="Image 2" style="width: 48%; max-width: 100%; height: auto;">
</div>


#### 二、思考题

1. 