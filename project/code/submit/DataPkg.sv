`include "core_struct.vh"

module DataPkg(
    input CorePack::mem_op_enum mem_op,
    input CorePack::data_t reg_data,
    input CorePack::addr_t dmem_waddr,
    output CorePack::data_t dmem_wdata
);

  import CorePack::*;

  // Data package
  // fill your code

  always_comb begin
      case (mem_op)
        MEM_B: begin
          dmem_wdata = 64'b0;
          dmem_wdata[dmem_waddr[2:0]*8 +: 8] = reg_data[7:0];
        end 

        MEM_H: begin
          dmem_wdata = 64'b0;
          dmem_wdata[{dmem_waddr[2:1],1'b0}*8 +: 16] = reg_data[15:0];
        end

        MEM_W: begin
          dmem_wdata = 64'b0;
          dmem_wdata[{dmem_waddr[2],2'b00}*8 +: 32] = reg_data[31:0];
        end

        MEM_D: begin
          dmem_wdata = reg_data;
        end
        
        default: dmem_wdata = 64'b0;
      endcase
  end

endmodule
