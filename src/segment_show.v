module segment_show(input clock,input reset,input [11:0]data_show,
input [2:0]byte_status,
		    output [3:0]bytee,output[6:0]segment);

wire [5:0]data_showing;
assign data_showing=byte_status==1?data_show[5:0]:byte_status==3?data_show[5:0]:byte_status==5?data_show[5:0]:byte_status==7?data_show[11:6]:0;
wire [3:0]segment_show;
assign segment_show=byte_status==1?data_showing%10:byte_status==3?data_showing/10:byte_status==5?data_showing%10:byte_status==7?data_showing/10:0;
assign segment={3'd0,segment_show};
assign bytee=byte_status==0?4'b0001:byte_status==1?4'b0000:byte_status==2?4'b0010:byte_status==3?4'b0000:byte_status==4?4'b0100:byte_status==5?4'b0000:byte_status==6?4'b1000:4'b0000;
endmodule
