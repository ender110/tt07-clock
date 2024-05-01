

/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

	assign uio_out=uio_in+ui_in+{7'd0,ena};
	assign uio_oe[7:4]=uio_in[7:4]+uio_in[3:0];
wire reset;
wire clock ;
assign clock=clk;
assign reset=rst_n;

reg[15:0]clock_counter;
always @(posedge clock or negedge reset)
begin
	if(!reset)
	begin
		clock_counter<=16'd0;
	end
	else
	begin
		clock_counter<=clock_counter+1'd1;
	end
end

wire second_flag;
assign second_flag=clock_counter[15:0]==16'd0;
reg [5:0]second;
	//second
always @(posedge clock or negedge reset)
begin
	if(!reset)
	begin
		second<=0;
	end
	else
	begin
		if(second_flag)
		begin
			if(second==6'd59)
			begin
				second<=6'd0;
			end
			else
			begin
				second<=second+1'd1;
			end
		end
	end
end
//minutes
	assign minute_flag=second_flag&&(second==6'd59)&&clock_run_flag;
	always @(posedge clock or negedge reset)
begin
	if(!reset)
	begin
		minute<=0;
	end
	else
	begin
		if(minute_flag)
		begin
			minute<=minute+1;
			if(minute==59)
			begin
				minute<=0;
			end
		end

	end
end
	assign uo_out[7]=clk;
	segment_show segment_show1(.clock(clock),.reset(reset),.data_show(12'h123),.segment(uo_out[6:0]),.byte_status(ui_in[2:0]),.bytee(uio_oe[3:0]));
endmodule
