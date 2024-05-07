`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/06 22:27:13
// Design Name: 
// Module Name: key
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


module key(
input  clock,input  reset,input time_flag,
input key_in,output key_out
    );
    
	reg [3:0]key_filter;
	wire key_mode_negedge;
	always @(posedge clock or negedge reset)
	begin
	   if(reset==1'd0)
	   begin
	       key_filter<=4'b1111;
	   end
	   else
	   begin
	       if(time_flag==1)
	       begin
	           key_filter<={key_filter[2:0],key_in};
	       end
	   end
	end
	assign key_out=(time_flag==1)&&(key_filter==4'b1100);
endmodule
