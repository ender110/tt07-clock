`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg i_encoder_a,i_encoder_b,i_orthogonal_en;
  wire o_step_forward,o_step_back;
  // Replace tt_um_example with your module name:
  tsp_enc_step_parse user_project (

      // Include power ports for the Gate Level test:
`ifdef GL_TEST
      .VPWR(1'b1),
      .VGND(1'b0),
`endif
    //! 时钟
    .clk(clk),
    //! 复位(高有效)
    .rstp(rst_n),

    //! 编码器输入源A
    .i_encoder_a(i_encoder_a),
    //! 编码器输入源B
    .i_encoder_b(i_encoder_b),
    //! 正交频率使能(正交频率是信号频率的4倍)，参数配置
   .i_orthogonal_en(i_orthogonal_en),


    //! 正向(前进)信号
    .o_step_forward(o_step_forward),
    //! 反向(后退)信号
    .o_step_back(o_step_back)
  );

endmodule
