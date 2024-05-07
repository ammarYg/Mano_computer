`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////First////////////////////////////////////////////////
// 4-bit =>
module Sequence_counter (clk,clr,SC,T0,T1,T2,T3,T4,T5,T6,T7,D0,D1,D2,D3,D4,D5,D6,D7,J);

input clk,clr ;
input J ;
input D0,D1,D2,D3,D4,D5,D6,D7 ;

output reg [2:0] SC ;
output T0,T1,T2,T3,T4,T5,T6,T7 ; 

initial begin 
    SC = 0 ; 
end

wire C1,C2,C3,C4,C5,C6,C7,r,p;

assign C1 = D0 & T5 ;
assign C2 = D1 & T5 ;
assign C3 = D2 & T5 ;
assign C4 = D3 & T4 ;
assign C5 = D4 & T4 ;
assign C6 = D5 & T5 ;
assign C7 = D6 & T6 ;
assign r = D7 & ~J & T3 ;
assign p = D7 &  J & T3 ;

assign clr = C1 | C2 | C3 | C4 | C5 | C6 | C7 | r | p ;

always @(posedge clk)
    begin 
        if (clr)
            SC <= 0 ; 

        else
            SC <= SC + 1 ;   
    end

assign T0 = (SC==3'b000) ? 1'b1 : 1'b0 ;
assign T1 = (SC==3'b001) ? 1'b1 : 1'b0 ;
assign T2 = (SC==3'b010) ? 1'b1 : 1'b0 ;
assign T3 = (SC==3'b011) ? 1'b1 : 1'b0 ;
assign T4 = (SC==3'b100) ? 1'b1 : 1'b0 ;
assign T5 = (SC==3'b101) ? 1'b1 : 1'b0 ;
assign T6 = (SC==3'b110) ? 1'b1 : 1'b0 ;
assign T7 = (SC==3'b111) ? 1'b1 : 1'b0 ;

endmodule
////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////Second///////////////////////////////////////////////
// 12-bit =>
module Program_counter (clk,clr,inr,load,PC,PC_in,DR,T1,T3,T4,T5,T6,D4,D5,D6,D7,J,ir0,ir1,ir2,ir3);

input clk,clr,inr,load ;
input [3:0] PC_in ;
input [7:0] DR ;
input J ;
input T1,T3,T4,T5,T6,D4,D5,D6,D7 ;
input ir0,ir1,ir2,ir3 ;
output reg [7:0] PC ;

initial begin 
    PC = 0 ;
end

wire I1,I2,I3,I4 ;
wire r ;
wire CLA,INC,SPA,SNA ;
wire L1,L2 ;

assign I1 = T1 ;
assign I2 = D6 & T6 ;
assign I3 = (DR==0) ? 1'b1 : 1'b0 ;
assign I4 = I2 & I3 ;
assign r = D7 & ~J & T3 ;

assign inr = I1 | I4 ;

assign L1 = D4 & T4 ;
assign L2 = D5 & T5 ;
assign load = L1 | L2 ;

always @ (posedge clk)
    begin 
        if (inr)
            begin
                PC <= PC + 1 ;    
            end
        if (load)
            begin 
                PC <= PC_in ;
            end
    end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////Third////////////////////////////////////////////////
// 12-bit 
module Address_reg (clk,clr,inr,load,AR,AR_in,PC,IR,T0,T2,T3,T4,D5,D7,J);

input clk,clr,inr,load ;
input [3:0] AR_in ;
input [3:0] PC ;
input [7:0] IR ;
input T0,T2,T3,T4,D5,D7,J ;

output reg [3:0] AR ;

wire I1 ;
wire L1,L2 ;
assign I1 = D5 & T4 ;
assign L1 = T2 ;
assign L2 = ~D7 & J & T3 ;

assign load = T0 | L1 | L2 ;
assign inr  = I1 ;

always @ (posedge clk)
    begin 
        if (T0)
            begin
                AR <= PC ;
            end     
        if (T2)
            begin
                AR <= IR[3:0] ;
            end 
        if (~D7 & J & T3)
            begin
                AR <= AR_in ;
            end          
//        if (load)
//            begin
//                AR <= AR_in ;
//            end    
        if (inr)
            begin
                AR <= AR + 1 ;
            end
    end
endmodule 
//////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////Fourth////////////////////////////////////////////////
module RAM(clk,address,Memory_out,Memory_in,T4,T6,D3,D5,D6);

input clk;
input [3:0] address ;
input [7:0] Memory_in ;
input T4,T6 ;
input D3,D5,D6 ;

output reg [7:0] Memory_out ;

reg [7:0] Memory [15:0] ;

wire write ;
wire W1,W2,W3 ;
assign W1 = D3 & T4 ;
assign W2 = D5 & T4 ;
assign W3 = D6 & T6 ;
assign write = W1 | W2 | W3 ;

initial begin 
    Memory [0]  = 8'hFF ; 
    Memory [1]  = 8'h00 ; // AND operation 
    Memory [2]  = 8'h1A ; // ADD operation 
    Memory [3]  = 8'h2B ; // LDA operation 
    Memory [4]  = 8'h3C ; // STA operation
    Memory [5]  = 8'h4D ; // BUN operation
    Memory [6]  = 8'h5E ; // BSA operation
    Memory [7]  = 8'h6F ; // ISZ operation
    Memory [8]  = 8'h6F ; // ISZ operation
    Memory [9]  = 8'h78 ; // CLA operation 
    Memory [10] = 8'h74 ; // INC operation 
    Memory [11] = 8'h72 ; // CMA operation
    Memory [12] = 8'h71 ; // CME operation
    Memory [13] = 8'hFE ; 
    Memory [14] = 8'hFF ;
    Memory [15] = 8'hF0 ;
end

always @ (*)
    begin
        if (~write)
            begin    
                Memory_out <= Memory [address] ;
            end
        else if (write)
            begin
                Memory_out <= Memory_in ;
            end
    end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////Fifth////////////////////////////////////////////////
// 16-bit =>
module Instruction_reg (clk,load,IR,J,op_code,ir0,ir1,ir2,ir3,Memory,T1,T2);

input clk,load ;
input T1,T2 ;
input [7:0] Memory ;

output reg [7:0] IR ; 
output reg [2:0] op_code ;
output reg ir0,ir1,ir2,ir3 ;
output reg J ;

assign load = T1 ;

always @ (posedge clk)
    begin
        if (load)
            begin 
                IR <= Memory ;
            end
        if (T2)
            begin
                J <= IR[7] ;
                ir0 <= IR[0] ;
                ir1 <= IR[1] ;
                ir2 <= IR[2] ;
                ir3 <= IR[3] ;
                op_code <= IR[6:4] ;
            end
    end
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////Sixth////////////////////////////////////////////////
// 16-bit =>
// ( 3-input pins 'cross' 8-output pins ) =>
module Decoder (clk,decoder_In,T2,D0,D1,D2,D3,D4,D5,D6,D7);

input clk ; 
input T2 ;

output [2:0] decoder_In ;
output D0,D1,D2,D3,D4,D5,D6,D7 ; 

assign D0 = (decoder_In==3'b000) ? 1'b1 : 1'b0 ;
assign D1 = (decoder_In==3'b001) ? 1'b1 : 1'b0 ;
assign D2 = (decoder_In==3'b010) ? 1'b1 : 1'b0 ;
assign D3 = (decoder_In==3'b011) ? 1'b1 : 1'b0 ;
assign D4 = (decoder_In==3'b100) ? 1'b1 : 1'b0 ;
assign D5 = (decoder_In==3'b101) ? 1'b1 : 1'b0 ;
assign D6 = (decoder_In==3'b110) ? 1'b1 : 1'b0 ;
assign D7 = (decoder_In==3'b111) ? 1'b1 : 1'b0 ;

endmodule
////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////Seventh//////////////////////////////////////////////
module Data_reg (clk,clr,inr,load,DR,DR_in,T4,T5,D0,D1,D2,D6);

input clk,clr,inr,load ;
input T4,T5,D0,D1,D2,D6 ;
input [7:0] DR_in ;

output reg [7:0] DR ;

initial begin
    DR = 8'h34  ;
end

wire I1 ;
wire L1,L2,L3,L4 ;
assign L1 = D0 & T4 ;
assign L2 = D1 & T4 ;
assign L3 = D2 & T4 ;
assign L4 = D6 & T4 ;
assign I1 = D6 & T5 ;

assign load = L1 | L2 | L3 | L4 ;
assign inr  = I1 ;

always @ (posedge clk)
    begin 
        if (load)
            begin
                DR <= DR_in ;
            end
        else if (~load)
            begin
                DR <= DR ;
            end
        if (inr)
            begin
                DR <= DR + 1 ;
            end
    end

endmodule
//////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////Eighth//////////////////////////////////////////////
module Arth_Logic_Unit (AC,DR_in,AC_in,T5,D0,D1,D2);

input [7:0] DR_in ;
input [7:0] AC_in ;
input T5,D0,D1,D2 ;

output reg [7:0] AC ;

always @ (*)
    begin
        if (D0 & T5)
            begin
                AC <= AC_in & DR_in ;
            end
        if (D1 & T5)
            begin
                AC <= AC_in + DR_in ;
            end
        if (D2 & T5)
            begin
                AC <= DR_in ;
            end
    end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////Nineth//////////////////////////////////////////////
// 16-bit =>
module Accumelator (clk,clr,inr,cma,cme,load,AC,AC_in,E,ir0,ir1,ir2,ir3,T3,T5,D0,D1,D2,D7,J);

input clk,clr,inr,cma,cme,load ;
input [7:0] AC_in ;
input T3,T5,D0,D1,D2,D7,J ;
input ir0,ir1,ir2,ir3 ;

output reg [7:0] AC ;
output reg E ;

initial begin
    AC = 8'hFF ;
    E  = 1'b1  ;
end

wire L1,L2,L3 ;
wire r ;
wire C1 ;
wire I1 ;
assign L1 = D0 & T5 ;
assign L2 = D1 & T5 ;
assign L3 = D2 & T5 ;
assign r  = D7 & ~J & T3 ;  

assign load = L1 | L2 | L3 ;
assign clr = r & ir3 ;
assign cma = r & ir2 ;
assign cme = r & ir1 ;
assign inr = r & ir0 ;

always @(posedge clk)
    begin
        if (load)
            begin
                AC <= AC_in ;
            end
        if (clr)
            begin
                AC <= 0 ;
            end
        if (inr)
            begin
                {E,AC} <= AC + 1 ;
            end
        if (cma)
            begin
                AC <= ~AC ;
            end  
        if (cme)
            begin
                E <= ~E ;
            end              
            
    end
endmodule 
//////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////Tenth//////////////////////////////////////////////
module Common_Bus (clk,Common_Bus,AR,PC,IR,DR,AC,Memory,T0,T1,T2,T3,T4,T5,T6,T7,D0,D1,D2,D3,D4,D5,D6,D7,J);

input clk ;
input T0,T1,T2,T3,T4,T5,T6,T7,D0,D1,D2,D3,D4,D5,D6,D7,J ;
input [3:0] AR ;
input [3:0] PC ;
input [7:0] IR ;
input [7:0] DR ;
input [7:0] AC ;
input [7:0] Memory ;

output reg [7:0] Common_Bus ;

initial begin
    Common_Bus = 0 ;
end

wire C1,C2,C3,C4,C5,C6,C7,C8,C9,C10,C11 ;
assign C1 = D4 & T4 ;
assign C2 = D5 & T5 ;
assign C3 = D0 & T4 ;
assign C4 = D1 & T4 ;
assign C5 = D2 & T4 ;
assign C6 = D6 & T4 ;
assign C7 = D2 & T5 ;
assign C8 = D3 & T4 ;
assign C10 = D6 & T6 ;
assign C11 = D5 & T4 ;
assign C9 = ~D7 & J & T3 ;

always @ (posedge clk)
    begin
        if (T0 | C11)
            begin
                Common_Bus <= PC ;  
            end
        if (C1 | C2)
            begin
                Common_Bus <= AR ;
            end
        if (T2)
            begin
                Common_Bus <= IR ;
            end
        if (C3 | C4 | C5 | C6 | C9)
            begin
                Common_Bus <= Memory ;
            end
        if (C7 | C10)
            begin
                Common_Bus <= DR ;
            end
        if (C8)
            begin
                Common_Bus <= AC ;
            end
    end
endmodule
//////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////Eleventh//////////////////////////////////////////////
//module Interupt (R,IEN,FGI,FGO,T0,T1,T2);

//input T0,T1,T2,FGI,FGO ;

//output reg R,IEN ;

//initial begin
//    R   = 0 ;
//    IEN = 0 ;
//end

//wire C1,C2,C3 ; 
//assign C1 = ~T0 & ~T1 & ~T2 ;
//assign C2 = FGI + FGO ;
//assign C3 = C2 & C2 & IEN ;

//always @ (*)
//    begin
//        if (C3) 
//            begin
//                R <= 1 ;
//            end    
//    end
//endmodule
//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////-------TOP-------///////////////////////////////////
/////////////////////////////////////-------MODULE------//////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////
module Top (clk,SC_top,PC_top,AR_top,DR_top,AC_top,IR_top,J_top,op_code,E_top/*,R_top,IEN_top,FGO_top,FGI_top*/,Common_Bus,Memory);

input clk ;

output [2:0] SC_top ;
output [3:0] PC_top ;
output [3:0] AR_top ;
output [7:0] DR_top ;
output [7:0] AC_top ;
output [7:0] IR_top ;
output J_top ;
output E_top ;
//output R_top ;
//output IEN_top ;
//output FGO_top,FGI_top ;
output [2:0] op_code ;
output [7:0] Memory ;
output [7:0] Common_Bus ;

wire [2:0] connect_SC ;
wire [3:0] connect_PC ;
wire [3:0] connect_AR ;
wire [7:0] connect_DR ;
wire [7:0] connect_AC ;
wire [7:0] connect_ALU ;
wire [7:0] connect_IR ;
wire [7:0] connect_RAM ;
wire connect_ir0,connect_ir1,connect_ir2,connect_ir3 ;
wire connect_J ;
wire connect_E ;
wire connect_R ;
wire connect_IEN ;
wire connect_FGI ;
wire connect_FGO ;
wire [2:0] connect_op ;
wire [7:0] connect_Common_Bus ;

wire connect_T0 ;
wire connect_T1 ;
wire connect_T2 ;
wire connect_T3 ;
wire connect_T4 ;
wire connect_T5 ;
wire connect_T6 ;
wire connect_T7 ;

wire connect_D0 ;
wire connect_D1 ;
wire connect_D2 ;
wire connect_D3 ;
wire connect_D4 ;
wire connect_D5 ;
wire connect_D6 ;
wire connect_D7 ;

assign SC_top     = connect_SC ;
assign PC_top     = connect_PC ;
assign AR_top     = connect_AR ;
assign DR_top     = connect_DR ; 
assign AC_top     = connect_AC ; 
assign IR_top     = connect_IR ;
assign J_top      = connect_J  ;
assign E_top      = connect_E  ;
assign op_code    = connect_op ;
//assign R_top      = connect_R  ;
//assign IEN_top    = connect_IEN ;
//assign FGI_top    = connect_FGI ;
//assign FGO_top    = connect_FGO ;
assign Memory     = connect_RAM ;
assign Common_Bus = connect_Common_Bus ;


Sequence_counter copyone 
(
    .clk (clk),
    .SC (SC_top),
    .J (connect_J),
    .T0 (connect_T0),
    .T1 (connect_T1),
    .T2 (connect_T2),
    .T3 (connect_T3),
    .T4 (connect_T4),
    .T5 (connect_T5),
    .T6 (connect_T6),
    .T7 (connect_T7),
    .D0 (connect_D0),
    .D1 (connect_D1),
    .D2 (connect_D2),
    .D3 (connect_D3),
    .D4 (connect_D4),
    .D5 (connect_D5),
    .D6 (connect_D6),
    .D7 (connect_D7)
);

Program_counter copytwo
(
    .clk (clk),
    .PC_in (connect_Common_Bus),
    .PC (connect_PC),
    .DR (connect_DR),
    .T1 (connect_T1),
    .T5 (connect_T5),
    .T6 (connect_T6),
    .D5 (connect_D5),
    .D6 (connect_D6),
    .ir0 (connect_ir0),
    .ir1 (connect_ir1),
    .ir2 (connect_ir2),
    .ir3 (connect_ir3)
);

Address_reg copythree
(
    .clk (clk),
    .AR_in (connect_Common_Bus),
    .AR (connect_AR),
    .PC (connect_PC),
    .IR (connect_IR),
    .J  (connect_J ),
    .T0 (connect_T0),
    .T2 (connect_T2),
    .T3 (connect_T3),
    .T4 (connect_T4),
    .D5 (connect_D5),
    .D7 (connect_D7) 
);

RAM copyfour 
(
    .clk (clk),
    .address (connect_AR),
    .Memory_out (connect_RAM),
    .Memory_in (connect_Common_Bus),
    .T4 (connect_T4),
    .T6 (connect_T6),
    .D3 (connect_D3),
    .D5 (connect_D5),
    .D6 (connect_D6)
);

Instruction_reg copyfive 
(
    .clk (clk),
    .IR (connect_IR),
    .T1 (connect_T1),
    .T2 (connect_T2),
    .Memory (connect_RAM),
    .J (connect_J),
    .ir0 (connect_ir0),
    .ir1 (connect_ir1),
    .ir2 (connect_ir2),
    .ir3 (connect_ir3),
    .op_code (connect_op)
);

Decoder copysix
(
    .clk (clk),
    .decoder_In (connect_op),
    .T2 (connect_T2),
    .D0 (connect_D0),
    .D1 (connect_D1),
    .D2 (connect_D2),
    .D3 (connect_D3),
    .D4 (connect_D4),
    .D5 (connect_D5),
    .D6 (connect_D6),
    .D7 (connect_D7)
);

Data_reg copyseven
(
    .clk (clk),
    .DR_in (connect_Common_Bus),
    .DR (connect_DR),
    .T4 (connect_T4),
    .T5 (connect_T5),
    .D0 (connect_D0),
    .D1 (connect_D1),
    .D2 (connect_D2),
    .D6 (connect_D6)
);

Accumelator copyeight
(
    .clk (clk),
    .AC_in (connect_ALU),
    .AC (connect_AC),
    .E (connect_E),
    .T3 (connect_T3),
    .T5 (connect_T5),
    .D0 (connect_D0),
    .D1 (connect_D1),
    .D2 (connect_D2),
    .D7 (connect_D7),
    .J  (connect_J),
    .ir0 (connect_ir0),
    .ir1 (connect_ir1),
    .ir2 (connect_ir2),
    .ir3 (connect_ir3)
);

Arth_Logic_Unit copynine
(
    .AC_in (connect_AC),
    .DR_in (connect_DR),
    .AC (connect_ALU),
    .T5 (connect_T5),
    .D0 (connect_D0),
    .D1 (connect_D1),
    .D2 (connect_D2)
);

//Interupt copyten
//(
//    .R (connect_R),
//    .IEN (connect_IEN),
//    .FGO (connect_FGO),
//    .FGI (connect_FGI),
//    .T0 (connect_T0),
//    .T1 (connect_T1),
//    .T2 (connect_T2)
//);

Common_Bus copyeleven
(
    .clk (clk),
    .Common_Bus (connect_Common_Bus),
    .Memory (connect_RAM),
    .AR (connect_AR),
    .PC (connect_PC),
    .DR (connect_DR),
    .AC (connect_AC),
    .IR (connect_IR),
    .J  (connect_J) ,
    .T0 (connect_T0),
    .T1 (connect_T1),
    .T2 (connect_T2),
    .T3 (connect_T3),
    .T4 (connect_T4),
    .T5 (connect_T5),
    .T6 (connect_T6),
    .T7 (connect_T7),
    .D0 (connect_D0),
    .D1 (connect_D1),
    .D2 (connect_D2),
    .D3 (connect_D3),
    .D4 (connect_D4),
    .D5 (connect_D5),
    .D6 (connect_D6),
    .D7 (connect_D7)
);
endmodule