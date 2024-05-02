 

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
// input clock,
// input reset,

);
	reg clock_run_flag=1;
	assign uio_out=uio_in+ui_in[6:0]+{7'd0,ena};
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
	wire minute_flag;
	reg [5:0]minute;
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
//hour
	reg [4:0]hour;
	wire hour_flag;
	assign hour_flag=minute_flag&&(minute==6'd59)&&clock_run_flag;
	always @(posedge clock or negedge reset)
begin
	if(!reset)
	begin
		hour<=0;
	end
	else
	begin
		if(hour_flag)
		begin
			hour<=hour+1;
			if(hour==23)
			begin
				hour<=0;
			end
		end
	end
end
	//day
	reg [4:0]day;
	wire day_flag;
	assign day_flag=hour_flag&&(hour==5'd23)&&clock_run_flag;
	always @(posedge clock or negedge reset)
	begin
		if(!reset)
		begin
			day<=0;
		end
		else
		begin
			if(day_flag)
			begin
				day<=day+4'd1;
				if(day==4'd30)
				begin
					day<=4'd0;
				end
			end
		end
	end
	//month
	reg [3:0]month;
	wire month_flag;
	assign month_flag=day_flag&&(day==5'd30)&&clock_run_flag;
	always @(posedge clock or negedge reset)
	begin
		if(!reset)
		begin
			day<=0;
		end
		else
		begin
			if(day_flag)
			begin
				month<=month+4'd1;
				if(month==4'd30)
				begin
					month<=4'd0;
				end
			end
		end
	end
	//
	assign uo_out[7]=clk;
	reg [2:0]status=3'd0;
	parameter status_show_time=3'd0;
	parameter status_show_time_date=3'd1;
parameter status_show_minute=3'd2;
parameter status_show_hour=3'd3;
parameter status_show_day=3'd4;
parameter status_show_month=3'd5;
//  parameter status_show_stop=3'd6;
wire key_down;
	assign key_down=ui_in[3];
	reg [3:0]key_down_filtering;
	wire key_down_filted;
	always @(posedge clock_counter[10] or negedge reset )
		begin
			if(!reset)
				begin
					key_down_filtering<=4'd0;
				end
			else
				begin
					key_down_filtering<={key_down_filtering[3:0],key_down};
				end
		end
	assign key_down_filted={3'd0,key_down_filtering[3]}+{3'd0,key_down_filtering[2]}+{3'd0,key_down_filtering[1]}+{3'd0,key_down_filtering[0]}>2?1:0;
	always @(posedge key_down_filted or negedge reset )
	begin
		if(!reset)
			begin
				status<=3'd0;
			end
		else
			begin
				status<=status+1;
			end
	end
	wire[11:0]data_show;
	assign data_show=status==status_show_time?{1'd1,hour,minute}:status==status_show_time_date?{1'd1,hour,minute}:status==status_show_minute?{6'd0,minute}:status==status_show_hour?{1'd1,hour,6'd0}:status==status_show_day?{6'd0,1'd0,day[4:0]}:status==status_show_month?{2'd0,month,6'd0}:0;
	segment_show segment_show1(.clock(clock),.reset(reset),.data_show(data_show),.segment(uo_out[6:0]),.byte_status(ui_in[2:0]),.bytee(uio_oe[3:0]));
endmodule
