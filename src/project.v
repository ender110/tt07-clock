 

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

//修改名称
wire reset;
wire clock ;
assign clock=clk;
assign reset=rst_n;
//control signel
reg clock_run_flag=1'd1;
//second clock
reg[15:0]clock_counter;
always @(posedge clock or negedge reset)
begin
	if(!reset)
	begin
		clock_counter<=16'd0;
	end
	else
	begin
	       clock_counter<={1'b0,clock_counter[14:0]}+16'd1;
	end
end

//second
wire second_flag;
assign second_flag=(clock_counter[15]==1'b1)&&clock_run_flag;
reg [5:0]second;
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
	assign minute_flag=(second_flag&&(second==6'd59)&&clock_run_flag)||((status==status_show_minute)&&key_add_negedge);
	always @(posedge clock or negedge reset)
    begin
        if(!reset)
        begin
            minute<=6'd0;
        end
        else
        begin
            if(minute_flag)
            begin
                minute<=minute+6'd1;
                if(minute==6'd59)
                begin
                    minute<=6'd0;
                end
            end
         end
     end
//hour
	reg [4:0]hour;
	wire hour_flag;
	assign hour_flag=minute_flag&&(minute==6'd59)&&clock_run_flag||((status==status_show_hour)&&key_add_negedge);
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
    	//day and month
    reg [4:0]day;
    wire day_flag;
    reg[4:0]day_this_month;
    reg [3:0]month;
    wire month_flag;
	always @(posedge clock )
    begin
        case(month)
            1: day_this_month<= 5'd31;
            2: day_this_month<=5'd29;
            3: day_this_month<= 5'd31;
            4: day_this_month<= 5'd30;
            5: day_this_month<= 5'd31;
            6: day_this_month<= 5'd30;
            7: day_this_month<= 5'd31;
            8: day_this_month<=5'd31;
            9: day_this_month<= 5'd30;
            10: day_this_month<= 5'd31;
            11: day_this_month<= 5'd30;
            12: day_this_month<= 5'd31;
        endcase
    end
	assign day_flag=hour_flag&&(hour==5'd23)&&clock_run_flag||((status==status_show_day)&&key_add_negedge);
	always @(posedge clock or negedge reset)
	begin
		if(!reset)
		begin
			day<=5'd1;
		end
		else
		begin
			if(day_flag)
			begin
				
				if(day==day_this_month)
				begin
					day<=5'd1;
				end
				else
				begin
					day<=day+5'd1;
				end
			end
			else
				begin
					day<=day;
				end
		end
	end
	//month

	assign month_flag=day_flag&&(day==day_this_month)&&clock_run_flag||((status==status_show_month)&&key_add_negedge);
	always @(posedge clock or negedge reset)
	begin
		if(!reset)
		begin
			month<=4'd1;
		end
		else
		begin
			if(month_flag)
			begin
				month<=month+4'd1;
				if(month==4'd12)
				begin
					month<=4'd1;
				end
			end
		end
	end
	//key
	wire key_10ms_flag;
	assign key_10ms_flag=clock_counter[8:0]==9'd327;
	//key mode

	wire key_mode;
	assign key_mode=ui_in[0];
	reg [3:0]key_mode_filter;
	wire key_mode_negedge;
	always @(posedge clock or negedge reset)
	begin
	   if(!reset)
	   begin
	       key_mode_filter<=4'b1111;
	   end
	   else
	   begin
	       if(key_10ms_flag==1)
	       begin
	           key_mode_filter<={key_mode_filter[2:0],key_mode};
	       end
	   end
	end
	assign key_mode_negedge=(key_10ms_flag==1)&&(key_mode_filter==4'b1100);
	//key add
	
	wire key_add;
	assign key_add=ui_in[1];
	reg [3:0]key_add_filter;
	wire key_add_negedge;
	always @(posedge clock or negedge reset)
	begin
	   if(!reset)
	   begin
	       key_add_filter<=4'b1111;
	   end
	   else
	   begin
	       if(key_10ms_flag==1)
	       begin
	           key_add_filter<={key_add_filter[2:0],key_add};
	       end
	   end
	end
	assign key_add_negedge=(key_10ms_flag==1)&&(key_add_filter==4'b1100);
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
	//status
	reg [2:0]status;
        parameter status_show_time=3'd0;
        parameter status_show_hour=3'd1;
        parameter status_show_minute=3'd2;
        parameter status_show_month=3'd3;
        parameter status_show_day=3'd4;

    	always @(posedge clock or negedge reset )
	begin
		if(!reset)
			begin
				status<=3'd0;
			end
		else
			begin
			 if(key_mode_negedge==1)
	          begin
	          if(status==status_show_day)
	           begin
	               status<=0;
	           end
	           else
	           begin
	               status<=status+1;
	           end
	          end
	      end
	     
	 end
	wire[11:0]data_show;
	assign data_show=status==status_show_time?{1'd0,hour,minute}:status==status_show_minute?{6'd0,minute}:status==status_show_hour?{1'd0,hour,6'd0}:status==status_show_day?{6'd0,1'd0,day[4:0]}:status==status_show_month?{2'd0,month,6'd0}:0;
//segment_show segment_show1(.clock(clock),.reset(reset),.data_show(data_show),.segment(uo_out[6:0]),.byte_status(clock_counter[15:13]),.bytee(uio_out[3:0]));
wire segment_clock_bit;
	assign segment_clock_bit=(status==status_show_time)&&clock_counter[13];
wire [3:0]segment_byte_control;
assign segment_byte_control=status==status_show_time?4'b1111:status==status_show_minute?4'b0011:status==status_show_hour?4'b1100:status==status_show_day?4'b0011:status==status_show_month?4'b1100:0;
segment_show segment_show1(.clock(clock),.reset(reset),.data_show(data_show),.segment(uo_out[6:0]),.byte_status(clock_counter[15:13]),.bytee(uio_out[3:0]),.segment_byte_control(segment_byte_control));
//driver output 
//assign uio_oe={2'd0,minute};
assign uio_out[7:4]=data_show[3:0];
	assign uio_oe[7:0]=8'ff;
assign uo_out[7]=segment_clock_bit;
//assign uo_out={2'd0,minute};
endmodule
