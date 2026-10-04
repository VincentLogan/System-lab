`include "core_struct.vh"
module ALU (
  input  CorePack::data_t a,
  input  CorePack::data_t b,
  input  CorePack::alu_op_enum  alu_op,
  output CorePack::data_t res
);

  import CorePack::*;
  logic [31:0] temp;

  // fill your code
  always_comb begin
    temp = '0;
    case(alu_op)
        ALU_ADD:  res = a + b;
        ALU_SUB:  res = a - b;
        ALU_AND:  res = a & b;  
        ALU_OR:   res = a | b;
        ALU_XOR:  res = a ^ b; 
        ALU_SLT:  res = {63'b0, $signed(a) < $signed(b)};
        ALU_SLTU: res = {63'b0, a < b};
        ALU_SLL:  res = a << b[5:0];
        ALU_SRL:  res = a >> b[5:0];
        ALU_SRA:  res = $signed(a) >>> b[5:0];
        ALU_ADDW: begin
          temp = a[31:0] + b[31:0];
          res = {{32{temp[31]}}, temp[31:0]};
        end
        ALU_SUBW: begin
          temp = a[31:0] - b[31:0];
          res = {{32{temp[31]}}, temp[31:0]};
        end
        ALU_SLLW: begin
          temp = a[31:0] << b[4:0];
          res = {{32{temp[31]}}, temp[31:0]};
        end
        ALU_SRLW: begin
          temp = a[31:0] >> b[4:0];
          res = {{32{temp[31]}}, temp[31:0]};
        end
        ALU_SRAW: begin
          temp = $signed(a[31:0]) >>> b[4:0];
          res = {{32{temp[31]}}, temp[31:0]};
        end
        ALU_DEFAULT:
          res = 64'b0;
    endcase
  end

endmodule
