/* verilator lint_off UNUSEDSIGNAL */
module segment_show(input wire clock,input wire reset,input  wire [11:0]data_show,
input wire [2:0]byte_status,output wire [3:0]bytee,output wire [6:0]segment,input wire [3:0]segment_byte_control);

wire [5:0]data_showing;
assign data_showing=byte_status==0?data_show[5:0]:byte_status==2?data_show[5:0]:byte_status==4?data_show[11:6]:byte_status==6?data_show[11:6]:0;
wire [3:0]segment_show;
wire [6:0] segment_show_code;
	/* verilator lint_off WIDTHTRUNC  */
	wire [3:0]hundreds;
	wire [3:0]tens;
	assign hundreds= (data_showing / 10) ;
	assign tens= (data_showing % 10) ;
		/* verilator lint_on WIDTHTRUNC  */
	assign segment_show = (byte_status == 3'd0) ?tens:
                      (byte_status == 3'd2) ?hundreds:
                      (byte_status == 3'd4) ? tens  :
                      (byte_status == 3'd6) ?hundreds  : 4'd0;


segment_code segment_code_0(.number(segment_show),.code(segment_show_code));
assign segment=segment_show_code;
assign bytee=byte_status==0?4'b1110|(~segment_byte_control):byte_status==2?4'b1101|(~segment_byte_control):byte_status==4?4'b1011|(~segment_byte_control):byte_status==6?4'b0111|(~segment_byte_control):4'b1111;
endmodule
/* verilator lint_on UNUSEDSIGNAL */
