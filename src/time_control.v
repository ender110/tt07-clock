`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/06 22:47:05
// Design Name: 
// Module Name: time_control
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


module time_control #(parameter BUS_WIDTH = 6,VALUE_INIT   = 0)(
input  clock,input  reset,
input [BUS_WIDTH-1:0]max,
input add_req,output reg carry_flag,
output reg [BUS_WIDTH-1:0]data_out
    );

        
 reg [BUS_WIDTH-1:0]data_old;
    	always @(posedge clock or negedge reset)
	begin
		if(!reset)
		begin
			data_out<=VALUE_INIT;
			carry_flag<=1'd0;
		end
		else
		begin

						data_old<=data_out;
			if(add_req)
			begin
				//data<=data+{{BUS_WIDTH-1{1'b0}},{1'd0}};
		data_out<=data_out+1;

				if(data_out==max)
				begin 
					data_out<=VALUE_INIT;
				end
			end
				if((data_old==max)&&(data_out==0))
			     begin
			         carry_flag<=1'd1;
			     end
			     else
			     begin
			         carry_flag<=1'd0;
			     end
		end
	end
endmodule
