`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2022 11:48:36
// Design Name: 
// Module Name: ADEX_neuron
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


module ADEX_neuron#(localparam no_of_bits = 24)(input clk,rst,input signed [no_of_bits-1:0]I,output reg spikes);

localparam signed W_init = 24'sh0_025A_E;
localparam signed EL = 24'shF_EDED_3;
localparam signed V_max = 24'sh0_051E_B;
localparam signed e_init = 24'sh0_0002_B;

reg signed [no_of_bits-1:0] V,W,VP,e;
wire signed [no_of_bits-1:0] E,dv;
wire signed [(2*no_of_bits)-1:0] exdv,exdvxdv;

assign exdv = e*dv;
assign exdvxdv = {exdv[47],exdv[42:20]}*dv;
assign E = (e>>>12) + (({exdv[47],exdv[42:20]})>>>3) + (({exdvxdv[47],exdvxdv[42:20]})<<<6);
assign dv = V - VP;


always@(posedge clk,negedge rst)
begin 
    if(!rst) 
       begin
         V <= EL;
         W <= W_init;
         e <= e_init;
         VP <= EL;
         spikes <= 0;
       end
    else 
       begin 
          if(V > V_max)
                begin 
                   V <= EL;
                   W <= W + W_init;
                   e <= e_init;
                   VP <= EL;
                   spikes <= 1;
                end
           else 
                begin 
                   VP <= V;
                   V <= V - ((V - EL)>>>3) + E + (I<<<2) - (W>>>5);
                   W <= W + ((V - EL)>>>8) - (W>>>7);
                   e <= (E<<<12);
                   spikes <= 0;
                end
        end
end

endmodule
