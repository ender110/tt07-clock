module segment_show(input clock,input reset,input [11:0]data_show,
input [2:0]byte_status,
		    output [3:0]bytee,output[6:0]segment);

//reg[15:0]bit_status;
//always @(posedge clock or negedge reset)
//begin
//	if(!reset)
//	begin
//		bit_status<=0;1
//	end
//	else
//	begin
//		bit_status<=bit_status+1;
//	end
//end
reg [6:0]segment_table[9:0];
always @(posedge clock or negedge reset)
begin
	if(!reset)
	begin
		segment_table[0]<=0;
		segment_table[1]<=1;
		segment_table[2]<=3;
		segment_table[3]<=5;
		segment_table[4]<=12;
		segment_table[5]<=23;
		segment_table[6]<=10;
		segment_table[7]<=50;
		segment_table[8]<=40;
		segment_table[9]<=55;
	end
	else
	begin
	
	end

end
//wire [2:0]byte_status;
//assign byte_status=bit_status[2:0];
assign bytee=byte_status==0?4'b0001:byte_status==1?4'b0000:byte_status==2?4'b0010:byte_status==3?4'b0000:byte_status==4?4'b0100:byte_status==5?4'b0000:byte_status==6?4'b1000:4'b0000;
//wire	[3:0]	low_ones,low_tens; 
//assign low_ones = data_show[5:0] % 10;
//assign low_tens = data_show[5:0]  / 10;
//wire	[3:0]	high_ones,high_tens; 
//assign high_ones = data_show[11:6] % 10;
//assign high_tens = data_show[11:6]  / 10;
reg [5:0]data_showing;
always@(*)
begin
case(byte_status)
0:data_showing<=0;
1:data_showing<=data_show[5:0];
2:data_showing<=0;
3:data_showing<=data_show[5:0];
4:data_showing<=0;
5:data_showing<=data_show[11:6];
6:data_showing<=0;
7:data_showing<=data_show[11:6];
endcase
end
reg[6:0]segment_show;
always@(*)
begin
case(byte_status)
0:segment_show<=0;
1:segment_show<=data_showing%10;
2:segment_show<=0;
3:segment_show<=data_showing/10;
4:segment_show<=0;
5:segment_show<=data_showing%10;
6:segment_show<=0;
7:segment_show<=data_showing/10;
endcase
end
assign segment=segment_show;
//assign segment=byte_status==0?segment_table[low_ones]:byte_status==1?4'b0000:byte_status==2?segment_table[low_tens]:byte_status==3?4'b0000:byte_status==4?segment_table[high_ones]:byte_status==5?4'b0000:byte_status==6?segment_table[high_tens]:4'b0000;
endmodule
