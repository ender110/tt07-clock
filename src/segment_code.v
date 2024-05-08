
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/07 19:49:56
// Design Name: 
// Module Name: segment_code
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module segment_code(
input wire  [3:0]number,output wire [6:0]code
    );
    assign code=number==0?7'h3f:number==1?7'h06:number==2?7'h5b:number==3?7'h4f:number==4?7'h66:number==5?7'h6d:number==6?7'h7d:number==7?7'h07:number==8?7'h7f:number==9?7'h6f:7'h0;
endmodule
