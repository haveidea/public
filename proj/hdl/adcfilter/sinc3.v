module sinc3(data_adc, clk_adc, rstn_adc, DATA ,word_clk,mode);  
input clk_adc;  
input rstn_adc;  
input data_adc;  
input [1:0]mode;    
output [15:0] DATA;  
output word_clk;    
integer location;   
integer info_file;    
reg [35:0]   ip_data1;   
reg [35:0]   acc1;   
reg [35:0]   acc2;   
reg [35:0]   acc3;   
reg [35:0]   acc3_d1;   
reg [35:0]   acc3_d2;   
reg [35:0]   diff1;   
reg [35:0]   diff2;   
reg [35:0]   diff3;   
reg [35:0]   diff1_d;   
reg [35:0]   diff2_d;   
reg [15:0]   DATA;   
reg [11:0]   word_count;    
reg word_clk;   reg init;    

/*Perform the Sinc ACTION*/   
always @ (data_adc)   
if(data_adc ==0) 
  ip_data1 <= 0;  /* change from a 0 to a -1 for 2's comp */  
else
  ip_data1 <= 1;    

/*ACCUMULATOR (INTEGRATOR) Perform the accumulation (IIR) at the speed of the
 * modulator.    Z = one sample delay    MCLKOUT = modulators conversion bit
 * rate*/  
always @ (posedge clk_adc or negedge rstn_adc)   
if (!rstn_adc)   begin    
  /*initialize acc registers on reset*/    
  acc1 <= 0;    
  acc2 <= 0;    
  acc3 <= 0;    
end   
else   begin    
  /*perform accumulation process*/    
  acc1 <= acc1 + ip_data1;    
  acc2 <= acc2 + acc1;    
  acc3 <= acc3 + acc2;   
end      /*DECIMATION STAGE (MCLKOUT/ WORD_CLK)*/  

always @ (negedge clk_adc or negedge rstn_adc)   
if (!rstn_adc)    
  word_count <= 0;  
else if(mode[1] == 0)   begin    
  if(word_count == 255)    
    word_count <= 0;    
  else    
    word_count <= word_count + 1'b1;   
end  
else    
  word_count <= word_count + 1'b1;    

always @ (*)   
if(mode[1] == 1)    
  word_clk <= word_count[11];  
else
  word_clk <= word_count[7];    

 /*DIFFERENTIATOR ( including decimation   stage)   Perform the
 * differentiation stage (FIR) at a   lower speed.   Z = one sample delay
 * WORD_CLK = output word rate*/   

always @ (posedge word_clk or negedge rstn_adc)   
if(!rstn_adc)   begin    
  acc3_d2 <= 0;    
  diff1_d <= 0;    
  diff2_d <= 0;    
  diff1 <= 0;    
  diff2 <= 0;    
  diff3 <= 0;    
end   
else   begin    
  diff1 <= acc3 - acc3_d2;    
  diff2 <= diff1 - diff1_d;    
  diff3 <= diff2 - diff2_d;    
  acc3_d2 <= acc3;    
  diff1_d <= diff1;    
  diff2_d <= diff2;   
end    

/* Clock the Sinc output into an output register WORD_CLK = output word rate
 * */  
always @ (posedge word_clk or negedge rstn_adc)   
if(!rstn_adc)    
  DATA <= 0;  
else    
  case(mode)    
    2'b00:DATA <= diff3[23:8]-4500;//mode4     
    2'b01:DATA <= {8'd0,diff3[23:16]}-4500;//mode2    
    2'b10:DATA <= {4'd0,diff3[35:24]}-4500;//mode1    
    2'b11:DATA <= diff3[35:20]-4500;//mode3   
  endcase    
endmodule
~                                                                                                                                                                                                                                                                                                                                                                                                           
~                                                                                                                                                                                                                                                                                                                                                                                                           
~                              
