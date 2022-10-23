`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2022 15:07:56
// Design Name: 
// Module Name: test
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


module test();

reg clk,rst;
reg [22:0] I_N;//,I_A;
wire pre;//,post;
reg [22:0] ECG_N;//,ECG_A;
reg [22:0] mem1[2000:0];
//reg [22:0] mem2[2000:0];
integer cnt,spikes_cnt;//,ecg;


initial $readmemh("E:/MODERN_LEARNING_CONTENT/VLSI/NEUROMORPHIC CIRCUITS/Adaptive Exponential Integrate-and-Fire Model/Python/sample_data_hex/4_36680760_normal_data.csv",mem1);
//initial $readmemh("ecg/A2.txt",mem2);

AdEx2 neuron1(clk,rst,I_N,pre);
//AdEx2 neuron2(clk,rst,I_A,post);

integer k = 0;
initial begin 
clk = 0; rst = 1;I_N = 'b0;cnt = 0;spikes_cnt = 0;
#5 rst = 0; 
#50 rst = 1;
for(k=0;k<3600;k=k+1) begin 
ECG_N = mem1[k];
//ECG_A = mem2[k];
#10000 I_N = {5'b0,ECG_N[22:0]};//I_A = {5'b0,ECG_A[22:3]};
end
#500 $finish();
end


always#(0.5) clk = ~clk;
always#(1) begin 
if(cnt>10000) begin 
cnt = 0;
//ecg = spikes_cnt;
spikes_cnt = 0;
end
else begin 
cnt = cnt + 1;
spikes_cnt = spikes_cnt + pre;
end
end


endmodule
