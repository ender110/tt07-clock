`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/08 21:27:00
// Design Name: 
// Module Name: testbench_for_vivado
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench_for_vivado(

    );
    reg clock;
    reg reset=1;
    initial
    begin
    clock=0;
    forever
    #30517 clock=~clock;
    end
     tt_um_ender_clock tt_um_ender_clock1 (
     .clk(clock),
     .rsr_n(reset)
//	input  wire [7:0] ui_in,    // Dedicated inputs
//    output wire [7:0] uo_out,   // Dedicated outputs
//    input  wire [7:0] uio_in,   // IOs: Input path
//    output wire [7:0] uio_out,  // IOs: Output path
//    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
//    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
//    input  wire       clk,      // clock
//    input  wire       rst_n     // reset_n - low to reset
);
endmodule
