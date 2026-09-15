`include "core_struct.vh"
module controller (
    input CorePack::inst_t inst,
    output we_reg,
    output we_mem,
    output re_mem,
    output npc_sel,
    output CorePack::imm_op_enum immgen_op,
    output CorePack::alu_op_enum alu_op,
    output CorePack::cmp_op_enum cmp_op,
    output CorePack::alu_asel_op_enum alu_asel,
    output CorePack::alu_bsel_op_enum alu_bsel,
    output CorePack::wb_sel_op_enum wb_sel,
    output CorePack::mem_op_enum mem_op
    // output ControllerPack::ControllerSignals ctrl_signals
);

    import CorePack::*;
    // import ControllerPack::*;
    
    // fill your code

    funct3_t funct3;
    funct7_t funct7;
    opcode_t opcode;
    assign funct3 = inst[14:12];
    assign funct7 = inst[31:25];
    assign opcode = inst[6:0];

    wire inst_load   = (opcode == LOAD_OPCODE);
    wire inst_imm    = (opcode == IMM_OPCODE);
    wire inst_auipc  = (opcode == AUIPC_OPCODE);
    wire inst_immw   = (opcode == IMMW_OPCODE);
    wire inst_store  = (opcode == STORE_OPCODE);
    wire inst_reg    = (opcode == REG_OPCODE);
    wire inst_lui    = (opcode == LUI_OPCODE);
    wire inst_regw   = (opcode == REGW_OPCODE);
    wire inst_branch = (opcode == BRANCH_OPCODE);
    wire inst_jalr   = (opcode == JALR_OPCODE);
    wire inst_jal    = (opcode == JAL_OPCODE);

    assign we_reg = inst_load | inst_imm | inst_auipc | inst_immw
               | inst_reg | inst_lui | inst_regw
               | inst_jalr | inst_jal;

    assign we_mem = inst_store;

    assign re_mem = inst_load;

    assign npc_sel = inst_jalr | inst_jal;

    always_comb begin

        immgen_op = IMM0;
        alu_op    = ALU_DEFAULT;
        cmp_op    = CMP_NO;
        alu_asel  = ASEL0;
        alu_bsel  = BSEL0;
        mem_op    = MEM_NO;
        wb_sel    = WB_SEL0;

        case(opcode)
            //R-type
            REG_OPCODE: begin
                alu_asel = ASEL_REG;
                alu_bsel = BSEL_REG;
                wb_sel = WB_SEL_ALU;
                case (funct7) 
                    7'b0000000: begin
                        case (funct3)
                            ADD_FUNCT3:  alu_op = ALU_ADD;
                            SLL_FUNCT3:  alu_op = ALU_SLL;
                            SLT_FUNCT3:  alu_op = ALU_SLT;
                            SLTU_FUNCT3: alu_op = ALU_SLTU;
                            XOR_FUNCT3:  alu_op = ALU_XOR;
                            SRL_FUNCT3:  alu_op = ALU_SRL;
                            OR_FUNCT3:   alu_op = ALU_OR;
                            AND_FUNCT3:  alu_op = ALU_AND;
                            default: alu_op = ALU_DEFAULT;
                        endcase
                    end

                    7'b0100000: begin
                        case(funct3)
                            SUB_FUNCT3:  alu_op = ALU_SUB;
                            SRA_FUNCT3:  alu_op = ALU_SRA;
                            default: alu_op = ALU_DEFAULT;
                        endcase
                    end

                    default: alu_op = ALU_DEFAULT;
                endcase
            end

            REGW_OPCODE: begin
                alu_asel = ASEL_REG;
                alu_bsel = BSEL_REG;
                wb_sel = WB_SEL_ALU;
                case (funct7) 
                    7'b0000000: begin
                        case (funct3)
                            ADDW_FUNCT3:  alu_op = ALU_ADDW;
                            SLLW_FUNCT3:  alu_op = ALU_SLLW;
                            SRLW_FUNCT3:  alu_op = ALU_SRLW; 
                            default: alu_op = ALU_DEFAULT;
                        endcase
                    end

                    7'b0100000: begin
                        case(funct3)
                            SUBW_FUNCT3:  alu_op = ALU_SUBW;
                            SRAW_FUNCT3:  alu_op = ALU_SRAW;
                            default: alu_op = ALU_DEFAULT;
                        endcase
                    end
                    default: alu_op = ALU_DEFAULT;
                endcase
            end

            //I-type
            IMM_OPCODE: begin
                alu_asel = ASEL_REG;
                alu_bsel = BSEL_IMM;
                wb_sel = WB_SEL_ALU;
                immgen_op = I_IMM;
                case(funct3) 
                    ADD_FUNCT3:  alu_op = ALU_ADD;
                    SLT_FUNCT3:  alu_op = ALU_SLT;
                    SLTU_FUNCT3: alu_op = ALU_SLTU;
                    XOR_FUNCT3:  alu_op = ALU_XOR;
                    OR_FUNCT3:   alu_op = ALU_OR;
                    AND_FUNCT3:  alu_op = ALU_AND;
                    SLL_FUNCT3:  alu_op = ALU_SLL;
                    SRL_FUNCT3:  alu_op = funct7[5] ? ALU_SRA : ALU_SRL;
                    default: alu_op = ALU_DEFAULT;
                endcase
            end

            IMMW_OPCODE: begin
                alu_asel = ASEL_REG;
                alu_bsel = BSEL_IMM;
                wb_sel = WB_SEL_ALU;
                immgen_op = I_IMM;
                case(funct3) 
                    ADDW_FUNCT3:  alu_op = ALU_ADDW;
                    SLLW_FUNCT3:  alu_op = ALU_SLLW;
                    SRLW_FUNCT3:  alu_op = funct7[5] ? ALU_SRAW : ALU_SRLW;
                    default: alu_op = ALU_DEFAULT;
                endcase
            end

            LOAD_OPCODE: begin
                alu_asel = ASEL_REG;
                alu_bsel = BSEL_IMM;
                alu_op = ALU_ADD;
                wb_sel = WB_SEL_MEM;
                immgen_op = I_IMM;
                case(funct3) 
                    LB_FUNCT3:  mem_op = MEM_B;
                    LH_FUNCT3:  mem_op = MEM_H;
                    LW_FUNCT3:  mem_op = MEM_W;
                    LD_FUNCT3:  mem_op = MEM_D;
                    LBU_FUNCT3: mem_op = MEM_UB;
                    LHU_FUNCT3: mem_op = MEM_UH;
                    LWU_FUNCT3: mem_op = MEM_UW;
                    default: mem_op = MEM_NO;
                endcase
            end

            JALR_OPCODE: begin
                alu_asel = ASEL_REG;
                alu_bsel = BSEL_IMM;    
                alu_op = ALU_ADD;
                wb_sel = WB_SEL_PC;
                immgen_op = I_IMM;
                mem_op = MEM_NO;
            end

            //S-type
            STORE_OPCODE: begin
                alu_asel = ASEL_REG;
                alu_bsel = BSEL_IMM;
                alu_op = ALU_ADD;
                immgen_op = S_IMM;
                case(funct3)
                    SB_FUNCT3: mem_op = MEM_B;
                    SH_FUNCT3: mem_op = MEM_H;
                    SW_FUNCT3: mem_op = MEM_W;
                    SD_FUNCT3: mem_op = MEM_D;
                    default: mem_op = MEM_NO;
                endcase
            end

            //B-type
            BRANCH_OPCODE: begin
                alu_asel = ASEL_PC;
                alu_bsel = BSEL_IMM;
                immgen_op = B_IMM;
                alu_op = ALU_ADD;
                case (funct3)
                    BEQ_FUNCT3:  cmp_op = CMP_EQ;
                    BNE_FUNCT3:  cmp_op = CMP_NE;
                    BLT_FUNCT3:  cmp_op = CMP_LT;
                    BGE_FUNCT3:  cmp_op = CMP_GE;
                    BLTU_FUNCT3: cmp_op = CMP_LTU;
                    BGEU_FUNCT3: cmp_op = CMP_GEU;
                    default:     cmp_op = CMP_NO;
                endcase 
            end

            //U-type
            LUI_OPCODE: begin
                alu_asel = ASEL0;
                alu_bsel = BSEL_IMM;
                alu_op = ALU_ADD;
                immgen_op = U_IMM;
                wb_sel = WB_SEL_ALU;
            end

            AUIPC_OPCODE: begin
                alu_asel = ASEL_PC;
                alu_bsel = BSEL_IMM;
                alu_op = ALU_ADD;
                immgen_op = U_IMM;
                wb_sel = WB_SEL_ALU;
            end

            //J-type
            JAL_OPCODE: begin
                alu_asel = ASEL_PC;
                alu_bsel = BSEL_IMM;
                wb_sel = WB_SEL_PC;
                immgen_op = UJ_IMM;
                alu_op = ALU_ADD;
            end

            default: alu_op = ALU_DEFAULT;
        endcase
    end
endmodule
