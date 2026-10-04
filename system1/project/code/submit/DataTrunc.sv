`include "core_struct.vh"

module DataTrunc (
    input CorePack::data_t dmem_rdata,
    input CorePack::mem_op_enum mem_op,
    input CorePack::addr_t dmem_raddr,
    output CorePack::data_t read_data
);

  import CorePack::*;

  // Data trunction
  // fill your code

  data_t shifted_data;
  assign shifted_data = dmem_rdata >> (dmem_raddr[2:0] * 8);
  
  always_comb begin
    case (mem_op)
      MEM_B:  read_data = {{56{shifted_data[7]}},  shifted_data[7:0]};
      MEM_H:  read_data = {{48{shifted_data[15]}}, shifted_data[15:0]};
      MEM_W:  read_data = {{32{shifted_data[31]}}, shifted_data[31:0]};
      MEM_D:  read_data = dmem_rdata;
      MEM_UB: read_data = {56'b0,shifted_data[7:0]};
      MEM_UH: read_data = {48'b0,shifted_data[15:0]};
      MEM_UW: read_data = {32'b0,shifted_data[31:0]};
      MEM_NO: read_data = 64'b0;
    endcase
  end

endmodule
