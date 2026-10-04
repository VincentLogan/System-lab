`include "core_struct.vh"

module MaskGen(
    input CorePack::mem_op_enum mem_op,
    input CorePack::addr_t dmem_waddr,
    output CorePack::mask_t dmem_wmask
);

  import CorePack::*;

  // Mask generation
  // fill your code
  
  always_comb begin
    case (mem_op)
      MEM_B: dmem_wmask = 8'h01 << dmem_waddr[2:0];
      MEM_H: dmem_wmask = 8'h03 << {dmem_waddr[2:1], 1'b0};
      MEM_W: dmem_wmask = 8'h0f << {dmem_waddr[2], 2'b00};
      MEM_D: begin
        dmem_wmask = '1;
      end
      default: dmem_wmask = 8'h0;
    endcase
  end

endmodule
