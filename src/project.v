 

/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_ender_clock (
	input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
/* verilator lint_off PINMISSING */
//修改名称
wire reset;
wire clock ;
assign clock=clk;
assign reset=rst_n;
//control signel
wire [2:0]status;
parameter status_show_time=3'd0;
parameter status_show_hour=3'd1;
parameter status_show_minute=3'd2;
parameter status_show_month=3'd3;
parameter status_show_day=3'd4;
reg clock_run_flag=1'd1;
//产生一秒内的计数，用以控制编码器动态扫描和数码管时间的点
reg[15:0]clock_counter;
always @(posedge clock or negedge reset)
begin
	if(!reset)
	begin
		clock_counter<=16'd0;
	end
	else
	begin
	       clock_counter<=clock_counter+16'd1;
	end
end
//second clock
wire second_flag;
time_control #(16,0) time_control_second_flags(  .clock(clock),  .reset((reset&clock_run_flag)), .add_req(1'd1),.carry_flag(second_flag),.max(16'd32767) );
//second
wire second_carry;
time_control #(6,0) time_control_second(  .clock(clock),  .reset((reset&clock_run_flag)), .add_req(second_flag),.carry_flag(second_carry),.max(6'd59) );
//minutes
wire [5:0]minute;
wire minute_carry;
time_control #(5,0) time_control_minute(  .clock(clock),  .reset(reset), .add_req(second_carry||((status==status_show_minute)&&key_add_negedge)),.data_out(minute),.carry_flag(minute_carry),.max(59) );
//hour
wire [4:0]hour;
wire hour_carry;
time_control #(5,0) time_control_hour(  .clock(clock),  .reset(reset), .add_req(minute_carry||((status==status_show_hour)&&key_add_negedge)),.data_out(hour),.carry_flag(hour_carry),.max(23) );
//day
wire [4:0]day;
wire[4:0]day_this_month;
wire day_carry;
time_control #(5,0) time_control_day(  .clock(clock),  .reset(reset), .add_req(hour_carry||((status==status_show_day)&&key_add_negedge)),.data_out(day),.carry_flag(day_carry),.max(day_this_month) );
//month
wire [3:0]month;
wire month_carry;
time_control #(5,1) time_control_month(  .clock(clock),  .reset(reset), .add_req(day_carry||((status==status_show_day)&&key_add_negedge)),.data_out(month),.carry_flag(month_carry),.max(12) );
//key
wire key_10ms_flag;
wire key_add_negedge;
time_control #(9,0) time_control_10ms(  .clock(clock),  .reset(reset), .add_req(clock),.carry_flag(key_10ms_flag) );

key key_add(  .clock(clock),  .reset(reset), .time_flag(key_10ms_flag), .key_in(ui_in[1]), .key_out(key_add_negedge) );
wire key_mode_negedge;
key key_mode(  .clock(clock),  .reset(reset), .time_flag(key_10ms_flag), .key_in(ui_in[0]), .key_out(key_mode_negedge) );
    
	//clock_run_flag
	always @(posedge clock or negedge reset)
	begin
	   if(!reset)
	   begin
	       clock_run_flag<=1'd1;
	   end
	   else
	   begin
	       if((status!=status_show_time)&&(key_add_negedge))
	       begin
	           clock_run_flag<=1'd0;
	       end
	       if(status==status_show_time)
	       begin
	           clock_run_flag<=1'd1;
	       end
	   end
	end
day_of_month day_of_month_0(.month(month),.day_this_month(day_this_month));
	//status

time_control #(3,status_show_time) time_control_status(  .clock(clock),  .reset(reset), .add_req(key_mode_negedge),.data_out(status),.max(status_show_day));



wire [3:0]segment_byte_control;
assign segment_byte_control=status==status_show_time?4'b1111:status==status_show_minute?4'b0011:status==status_show_hour?4'b1100:status==status_show_day?4'b0011:status==status_show_month?4'b1100:0;
segment_show segment_show1(.clock(clock),.reset(reset),.data_show(data_show),.segment(uo_out[6:0]),.byte_status(clock_counter[5:3]),.bytee(uio_out[3:0]),.segment_byte_control(segment_byte_control));
wire[11:0]data_show;
assign data_show=status==status_show_time?{1'd0,hour,minute}:status==status_show_minute?{6'd0,minute}:status==status_show_hour?{1'd0,hour,6'd0}:status==status_show_day?{6'd0,1'd0,day[4:0]}:status==status_show_month?{2'd0,month,6'd0}:0;
assign uio_out[7:4]=data_show[3:0];
assign uio_oe[7:0]=8'hff;
wire segment_D56;
assign segment_D56=(status==status_show_time)&&clock_counter[13];
assign uo_out[7]=segment_D56;
	/* verilator lint_on PINMISSING */
endmodule
