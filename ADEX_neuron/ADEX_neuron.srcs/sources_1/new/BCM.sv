`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.07.2022 14:29:54
// Design Name: 
// Module Name: BCM
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


module BCM#(parameter initial_weight = 23'sh00_0000)(input clk,rst, input pre,post,output reg signed [22:0]w,output reg signed [17:0] avg_dw);//

localparam T_plus = 4; // 16
localparam T_minus = 5; // 32
localparam Ty = 6;      // 114
localparam A3_plus = 4;   //  1/16
localparam A2_minus = 7; //   1/128
localparam W_max = 'sh1_DFFF;
localparam dt = 13;
localparam N_cnt = 9;
/// the equations to be implemented 
////   dw1 = o1(t)*A3_plus*o2(t-e);  if t = t_pre 
////   dw2 = r1(t)*A2__minus ;    if t = t_post


reg  signed [17:0] r1,o2,o1,dw;
reg [N_cnt-1:0] cnt;



////////////// REG FOR PIPELINING ///////////////   
reg  [3:0] r1xo2_mux1;           //
reg  [4:0] r1xo2_mux2;           // 
reg  [5:0] r1xo2_mux3;           // 
reg  [6:0] r1xo2_mux4;           // 
reg  [7:0] r1xo2_4;              // 
///////////////////////////////////////////////////

wire signed [17:0] r1xo2;
wire unsigned [5:0] r1xo2_add1;
wire unsigned [6:0] r1xo2_add2;
wire unsigned [7:0] r1xo2_add3;
wire unsigned [3:0] wire_r1xo2_mux1;           // 8 REG
wire unsigned [4:0] wire_r1xo2_mux2;           // 10 REG
wire unsigned [5:0] wire_r1xo2_mux3;           // 12 REG
wire unsigned [6:0] wire_r1xo2_mux4;           // 14 REG



always@(posedge clk,negedge rst) begin 

if(!rst) begin
 
 w <= initial_weight;
 r1 <= 18'sh1_0000;
 o2 <= 18'sh1_0000;
 o1 <= 18'sh1_0000; 
 r1xo2_mux1 <= 0;
 r1xo2_mux2 <= 0;
 r1xo2_mux3 <= 0;
 r1xo2_mux4 <= 0;
 r1xo2_4 <= 0;
 avg_dw <= 0;
 dw <= 0;
 cnt <= 0;
 end
else begin 
// update exponcial variables

if(cnt==(2^^N_cnt)-1) begin 
cnt <= 0;
avg_dw <= dw>>>N_cnt;
dw <= 0;
end

if(pre) begin
 r1 <= 18'sh1_0000;
 w <= w - {5'b0,(o1>>>A2_minus)};
 dw <= dw - (o1>>>A2_minus);
 cnt <= cnt + 1;

 end
else begin  
r1 <= (r1 - ((r1>>>T_plus)>>>dt));

 end


if(post) // if post spike occurs
begin
o2 <= 18'sh1_0000;
o1 <= 18'sh1_0000;
w <= w + {5'b0,(r1xo2>>>A3_plus)};
dw <= dw + (r1xo2>>>A3_plus);
cnt <= cnt + 1;

end
else     
begin 
o1 <= (o1 - ((o1>>>T_minus)>>>dt));
o2 <= (o2 - ((o2>>>Ty)>>>dt));

end

////////...........................  PIPELINE 1 .........................////////////

// mux output mult4 o2xo1               
r1xo2_mux1 <= wire_r1xo2_mux1;
r1xo2_mux2 <= wire_r1xo2_mux2;
r1xo2_mux3 <= wire_r1xo2_mux3;
r1xo2_mux4 <= wire_r1xo2_mux4;

////////...........................  PIPELINE 2 .........................////////////
// mult1 adder 2
r1xo2_4 <= r1xo2_add3;


     end
end 



assign wire_r1xo2_mux1 = r1[15:12]&{o2[12],o2[12],o2[12],o2[12]};
assign wire_r1xo2_mux2 = ({1'b0,r1[15:12]}<<1)&{o2[13],o2[13],o2[13],o2[13],o2[13]};  
assign wire_r1xo2_mux3 = ({2'b0,r1[15:12]}<<2)&{o2[14],o2[14],o2[14],o2[14],o2[14],o2[14]};
assign wire_r1xo2_mux4 = ({3'b0,r1[15:12]}<<3)&{o2[15],o2[15],o2[15],o2[15],o2[15],o2[15],o2[15]};



/// mult adder 1
assign r1xo2_add1 = {1'b0,r1xo2_mux1} + r1xo2_mux2;
assign r1xo2_add2 = r1xo2_add1 + r1xo2_mux3;
assign r1xo2_add3 = r1xo2_add2 + r1xo2_mux4;

// mult output wire with addpending 0's at integer part and at least signifient 8 bits
assign r1xo2 = {2'b00,r1xo2_4,8'b0};


endmodule 
