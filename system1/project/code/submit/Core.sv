`include "core_struct.vh"
module Core (
    input clk,
    input rst,

    Mem_ift.Master imem_ift,
    Mem_ift.Master dmem_ift,

    output cosim_valid,
    output CorePack::CoreInfo cosim_core_info
);
    import CorePack::*;
    
    // fill your code
    
    //控制信号
    imm_op_enum imm_op;             //立即数生成类型
    alu_asel_op_enum alu_asel_op;   //ALU操作数alu_a的选择
    alu_bsel_op_enum alu_bsel_op;   //ALU操作数alu_b的选择
    wb_sel_op_enum wb_sel_op;       //写回数据来源选择

    //IF阶段，读取指令
    addr_t pc,next_pc;
    data_t imem_rdata;
    inst_t inst;
    
    //imem_ift读请求
    assign imem_ift.r_request_valid = 1'b1;
    assign imem_ift.r_request_bits.raddr = pc;
    assign imem_ift.r_reply_ready = 1'b1;
    assign imem_rdata = imem_ift.r_reply_bits.rdata;

    //通过pc读取指令的低/高32位
    assign inst = (pc[2] == 1) ? imem_rdata[63:32] : imem_rdata[31:0];

    //ID阶段，解码
    reg_ind_t rs1,rs2,rd;
    data_t read_data_1,read_data_2;
    data_t imm;
    assign rs1 = inst[19:15];
    assign rs2 = inst[24:20];
    assign rd = inst[11:7];

    //获取控制信号
    controller controlsignal(
        .inst(inst),
        .we_reg(we_reg),
        .we_mem(we_mem),
        .re_mem(re_mem),
        .npc_sel(npc_sel),
        .immgen_op(imm_op),
        .alu_op(alu_op),
        .alu_asel(alu_asel_op),
        .alu_bsel(alu_bsel_op),
        .wb_sel(wb_sel_op),
        .mem_op(mem_op),
        .cmp_op(cmp_op)
    );

    RegFile regfile(
        .clk(clk),
        .rst(rst),
        .we(we_reg),
        .read_addr_1(rs1),
        .read_addr_2(rs2),
        .write_addr(rd),
        .write_data(wb_val),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );

    always_comb begin
        case(imm_op)    
            I_IMM: imm = {{52{inst[31]}},inst[31:20]};

            S_IMM: imm = {{52{inst[31]}},inst[31:25],inst[11:7]};
            
            B_IMM: imm = {{51{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};

            U_IMM: imm = {{32{inst[31]}},inst[31:12],12'b0};

            UJ_IMM: imm = {{43{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0};
            
            default: imm = '0;
        endcase
    end

    //EXE阶段，计算,更新pc
    data_t alu_a,alu_b;
    data_t alu_res;
    alu_op_enum alu_op;
    cmp_op_enum cmp_op;
    logic cmp_res;
    logic npc_sel;
    logic br_taken;

    always_comb begin
        case(alu_asel_op)
            ASEL0: alu_a = '0;

            ASEL_REG: alu_a = read_data_1;

            ASEL_PC: alu_a = pc;

            ASEL3: alu_a = '0;
        endcase
        
        case(alu_bsel_op)
            BSEL0: alu_b = '0;

            BSEL_REG: alu_b = read_data_2;

            BSEL_IMM: alu_b = imm;

            BSEL3: alu_b = '0;
        endcase
    end
    
    ALU alu(
        .a(alu_a),
        .b(alu_b),
        .alu_op(alu_op),
        .res(alu_res)
    );

    Cmp cmp(
        .a(read_data_1),
        .b(read_data_2),
        .cmp_op(cmp_op),
        .cmp_res(cmp_res)
    );
    
    assign br_taken = cmp_res & (inst[6:0] == BRANCH_OPCODE);
    assign next_pc = (npc_sel | br_taken) ? {alu_res[63:1],1'b0} : (pc + 64'd4);
    always @(posedge clk) begin
        if (rst) begin
            pc <= 64'h0;
        end else begin
            pc <= next_pc;
        end
    end

    //MEM阶段，与dmem完成内存读写
    mem_op_enum mem_op;
    data_t reg_data;
    addr_t dmem_raddr;
    data_t dmem_rdata;
    addr_t dmem_waddr;
    data_t dmem_wdata;
    mask_t dmem_wmask;
    data_t read_data;
    logic we_mem;
    logic re_mem;
    assign reg_data = read_data_2;
    assign dmem_raddr = alu_res;
    assign dmem_waddr = alu_res;

    DataPkg datapkg(
        .mem_op(mem_op),
        .reg_data(reg_data),
        .dmem_waddr(dmem_waddr),
        .dmem_wdata(dmem_wdata) 
    );

    MaskGen maskgen(
        .mem_op(mem_op),
        .dmem_waddr(dmem_waddr),
        .dmem_wmask(dmem_wmask)
    );

    DataTrunc datatrunc(
        .dmem_rdata(dmem_rdata),
        .mem_op(mem_op),
        .dmem_raddr(dmem_raddr),
        .read_data(read_data)
    );


    //dmem_ift读操作
    assign dmem_ift.r_request_valid = re_mem;
    assign dmem_ift.r_request_bits.raddr = alu_res;
    assign dmem_ift.r_reply_ready = 1'b1;
    assign dmem_rdata = dmem_ift.r_reply_bits.rdata;

    //dmem_ift写操作
    assign dmem_ift.w_request_valid = we_mem;
    assign dmem_ift.w_request_bits.waddr = alu_res;
    assign dmem_ift.w_request_bits.wdata = dmem_wdata;
    assign dmem_ift.w_request_bits.wmask = dmem_wmask;
    assign dmem_ift.w_reply_ready = 1'b1;
    
    //WB阶段，把数据写回寄存器
    logic we_reg;
    data_t wb_val;

    always_comb begin
        case(wb_sel_op)
            WB_SEL0:    wb_val = '0;

            WB_SEL_ALU: wb_val = alu_res;

            WB_SEL_MEM: wb_val = read_data;

            WB_SEL_PC:  wb_val = pc + 64'd4;
        endcase
    end

    assign cosim_valid = 1'b1;
    assign cosim_core_info.pc        = pc;
    assign cosim_core_info.inst      = {32'b0,inst};   
    assign cosim_core_info.rs1_id    = {59'b0, rs1};
    assign cosim_core_info.rs1_data  = read_data_1;
    assign cosim_core_info.rs2_id    = {59'b0, rs2};
    assign cosim_core_info.rs2_data  = read_data_2;
    assign cosim_core_info.alu       = alu_res;
    assign cosim_core_info.mem_addr  = dmem_ift.r_request_bits.raddr;
    assign cosim_core_info.mem_we    = {63'b0, dmem_ift.w_request_valid};
    assign cosim_core_info.mem_wdata = dmem_ift.w_request_bits.wdata;
    assign cosim_core_info.mem_rdata = dmem_ift.r_reply_bits.rdata;
    assign cosim_core_info.rd_we     = {63'b0, we_reg};
    assign cosim_core_info.rd_id     = {59'b0, rd}; 
    assign cosim_core_info.rd_data   = wb_val;
    assign cosim_core_info.br_taken  = {63'b0, br_taken};
    assign cosim_core_info.npc       = next_pc;

endmodule

module MultiFSM(
    input clk,
    input rst,
    Mem_ift.Master imem_ift,
    Mem_ift.Master dmem_ift,
    input we_mem,
    input re_mem,
    input CorePack::addr_t pc,
    input CorePack::addr_t alu_res,
    input CorePack::data_t data_package,
    input CorePack::mask_t mask_package,
    output stall
);
    import CorePack::*;

    // fill your code for bonus

endmodule