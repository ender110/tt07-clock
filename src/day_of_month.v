
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/05/07 21:01:04
// Design Name: 
// Module Name: day_of_month
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


module day_of_month(
input wire [3:0]month,
output wire[4:0] day_this_month
    );
assign day_this_month=month==1?5'd31:month==2?5'd28:month==3?5'd31:month==4?5'd30:month==5?5'd31:month==6?5'd30:month==7?5'd31:month==8?5'd31:month==9?5'd30:month==10?5'd31:month==11?5'd30:5'd31;
endmodule
