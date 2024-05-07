`timescale 1ns / 1ps

module Sim_mano_project();
// inputs
reg clk_tb ;
// outputs 
wire [2:0] SC_tb ;
wire [3:0] PC_tb ;
wire [3:0] AR_tb ;
wire [7:0] IR_tb ;
wire       J_tb  ;
wire [2:0] D_tb  ;
wire [7:0] DR_tb ;
wire [7:0] AC_tb ;
wire       E_tb  ; 
wire [7:0] Memory_tb ;
wire [7:0] Common_Bus_tb ;


// clock signal 
always begin 
    #5 clk_tb = ~clk_tb ;
end 

initial begin 
    clk_tb = 1 ;   
end


Top copyone
(
    .clk (clk_tb),
    .SC_top (SC_tb),
    .PC_top (PC_tb),
    .AR_top (AR_tb),
    .IR_top (IR_tb),
    .J_top  ( J_tb),
    .op_code (D_tb),
    .DR_top (DR_tb),
    .AC_top (AC_tb),
    .E_top  (E_tb ),
    .Memory (Memory_tb),
    .Common_Bus (Common_Bus_tb)

);
endmodule
