//=========================================================================
// 5-Stage RISCV Scoreboard
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

  reg valid [15:0];
  reg pending [15:0];
  reg [4:0] preg [15:0];

  reg [3:0] head;
  reg [3:0] tail;


  /*assign rob_alloc_req_rdy   = 1'b1;
  assign rob_alloc_resp_slot = 4'b0;
  assign rob_commit_wen      = 1'b0;
  assign rob_commit_rf_waddr = 1'b0;
  assign rob_commit_slot     = 4'b0;
  */
  
  assign rob_alloc_req_rdy = (((tail + 1) & 4'hF) != head);
  assign rob_alloc_resp_slot = tail[3:0];
  assign rob_commit_wen      = valid[head] && !pending[head];
  assign rob_commit_slot     = head[3:0];
  assign rob_commit_rf_waddr = preg[head];


  //------------------------------------------
  // Valid/Pending/Preg
  //------------------------------------------
  integer i;

  always @(posedge clk) begin
    if (reset) begin
      head <= 4'b0;
      tail <= 4'b0;
      for (i = 0; i < 16; i++) begin
        valid[i] <= 1'b0;
        pending[i] <= 1'b0;
        preg[i] <= 4'b0;
      end
    end
    else begin

      if (rob_alloc_req_val) begin
        valid[tail] <= 1'b1;
        pending[tail] <= 1'b1;
        preg[tail] <= rob_alloc_req_preg;
        tail <= tail + 4'b1;
      end

      if(rob_fill_val) begin
        pending[rob_fill_slot] <= 1'b0;
      end
      
      if(rob_commit_wen) begin
        valid[rob_commit_slot] <= 1'b0;
        head <= head + 4'b1;
      end
    end
    
  end
  


  
endmodule

`endif

