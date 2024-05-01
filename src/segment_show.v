module segment_show(input clock,input reset,input [11:0]data_show,
input [2:0]byte_status,
		    output [3:0]bytee,output[6:0]segment);

assign bytee=4'd0;//data_show+clock+reset+byte_status;
	
wire [5:0]data_showing;
assign data_showing=byte_status==1?data_show[5:0]:byte_status==3?data_show[5:0]:byte_status==5?data_show[5:0]:byte_status==7?data_show[11:6]:0;
wire [3:0]segment_show;
assign segment_show=byte_status==1?data_showing%10:byte_status==3?data_showing/10:byte_status==5?data_showing%10:byte_status==7?data_showing/10:0;
	assign segment={3'd0,segment_show};
endmodule
