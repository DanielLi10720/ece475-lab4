//=========================================================================
// RISC-V Out-of-Order Reorder Buffer (16 entries, in-order commit)
//=========================================================================

`ifndef RISCV_CORE_REORDERBUFFER_V
`define RISCV_CORE_REORDERBUFFER_V

module riscv_CoreReorderBuffer
(
  input         clk,
  input         reset,

  input         rob_alloc_req_val,
  output        rob_alloc_req_rdy,
  input  [ 4:0] rob_alloc_req_preg,

  output [ 3:0] rob_alloc_resp_slot,

  input         rob_fill_val,
  input  [ 3:0] rob_fill_slot,

  output        rob_commit_wen,
  output [ 3:0] rob_commit_slot,
  output [ 4:0] rob_commit_rf_waddr
);

  reg [3:0] head;
  reg [3:0] tail;
  reg [4:0] count;

  reg [4:0] preg     [0:15];
  reg       complete [0:15];

  integer i;

  wire can_commit = (count > 0) && complete[head];

  wire [4:0] cnt_after_commit = count - (can_commit ? 5'd1 : 5'd0);
  assign rob_alloc_req_rdy = (cnt_after_commit < 16);

  wire do_alloc = rob_alloc_req_val && rob_alloc_req_rdy;

  assign rob_alloc_resp_slot   = tail;
  assign rob_commit_wen        = can_commit;
  assign rob_commit_slot       = head;
  assign rob_commit_rf_waddr   = preg[head];

  always @(posedge clk) begin
    if (reset) begin
      head  <= 4'b0;
      tail  <= 4'b0;
      count <= 5'b0;
      for (i = 0; i < 16; i = i + 1) begin
        complete[i] <= 1'b0;
        preg[i]     <= 5'b0;
      end
    end
    else begin
      if (rob_fill_val)
        complete[rob_fill_slot] <= 1'b1;

      if (can_commit)
        head <= head + 4'd1;

      if (do_alloc) begin
        preg[tail]     <= rob_alloc_req_preg;
        complete[tail] <= 1'b0;
        tail           <= tail + 4'd1;
      end

      count <= count + {4'b0, do_alloc} - {4'b0, can_commit};
    end
  end

endmodule

`endif
