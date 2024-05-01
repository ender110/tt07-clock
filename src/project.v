

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
	wire clock ;
wire key_mode;
wire key_add;
	wire reset;
wire[6:0] segment;
	wire[3:0] bytee;
assign  key_mode=ui_in[0];
    assign  key_add=ui_in[1];
	assign  uo_out={1'b1,segment};
	assign  uio_out={4'hf,bytee};
assign reset=rst_n;
assign clock=clk;
	assign uio_oe=0;
reg [5:0]second;
reg [5:0]minute;
reg [4:0]hour;
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
wire minute_flag;
wire hour_flag;
assign second_flag=clock_counter[15:0]==16'd0&&clock_run_flag;
assign minute_flag=second_flag&&(second==6'd59)&&clock_run_flag;
assign hour_flag=minute_flag&&(minute==6'd59)&&clock_run_flag;
reg clock_run_flag=1;
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
//minute
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
reg [11:0]data_show;
reg [3:0]segment_status;

	segment_show segment_show1(.clock(clock),.reset(reset),.data_show(data_show),.bytee(bytee),.segment(segment),.byte_status(clock_counter[15:13]));
wire key_mode_down,key_add_down;
wire key_add_negedge;
reg [2:0]status;
parameter status_show_time=0;
// parameter status_show_time_date=1;
// parameter status_show_minute=2;
// parameter status_show_hour=3;
// parameter status_show_day=4;
// parameter status_show_month=5;
// parameter status_show_stop=6;
//assign data_show=status==status_show_time?{hour,minute}:0;
always @(posedge clock )
begin
	case(status)
		status_show_time:data_show<={1'b0,hour,minute};
		status_show_minute:data_show<={6'd25,minute};
		status_show_hour:data_show<={1'b0,hour,6'd25};
		default:data_show<=12'hxxx;
	endcase
end
always @(posedge clock or negedge reset)
begin
	if(!reset)
	begin
		status<=status_show_time;
	end
	else
	begin
		if(key_mode_down==1)
		begin
				if(status==status_show_stop)
			begin
				status<=0;
			end
			else
			begin
				status<=status+1;
			end
		end
		else
		begin
			status=status;
		end
	
	end
end

endmodule
