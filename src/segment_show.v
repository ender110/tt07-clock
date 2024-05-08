module segment_show(input clock,input reset,input [11:0]data_show,
input [2:0]byte_status,output [3:0]bytee,output[6:0]segment,input [3:0]segment_byte_control);

wire [5:0]data_showing;
assign data_showing=byte_status==0?data_show[5:0]:byte_status==2?data_show[5:0]:byte_status==4?data_show[11:6]:byte_status==6?data_show[11:6]:0;
wire [3:0]segment_show;
reg [6:0] segment_show_code;
	/* verilator lint_off WIDTHEXPAND */
assign segment_show = (byte_status == 3'd0) ? (data_showing % 10) :
                      (byte_status == 3'd2) ? (data_showing / 10) :
                      (byte_status == 3'd4) ? (data_showing % 10) :
                      (byte_status == 3'd6) ? (data_showing / 10) : 4'd0;
	/* verilator lint_on WIDTHEXPAND */
always @(posedge clock or negedge reset)
begin
    if(!reset)
    begin
        segment_show_code<=7'd0;
    end
    else
    begin
        case(segment_show)
	    0: segment_show_code<= 7'h3f;//0x3f   0x06   0x5b   0x4f  0x66  0x6d
	    1: segment_show_code<= 7'h06;
	    2: segment_show_code<= 7'h5b;
	    3: segment_show_code<= 7'h4f;
	    4: segment_show_code<= 7'h66;
	    5: segment_show_code<= 7'h6d;
	    6: segment_show_code<= 7'h7d;//0x7d  0x07   0x7f    0x6f
	    7: segment_show_code<= 7'h07;
	    8: segment_show_code<= 7'h7f;
	    9: segment_show_code<= 7'h6f;

	    default: segment_show_code<= 7'b0;// 0
	    endcase
    end

end
assign segment=segment_show_code;
assign bytee=byte_status==0?4'b1110|(~segment_byte_control):byte_status==2?4'b1101|(~segment_byte_control):byte_status==4?4'b1011|(~segment_byte_control):byte_status==6?4'b0111|(~segment_byte_control):4'b1111;
endmodule
