//*******************************************************************--
// Copyright (c) 2016  Beijing 7Q Technology Co., Ltd.               --
//*******************************************************************--
// Please review the terms of the license agreement before using     --
// this file. If you are not an authorized user, please destroy this --
// source code file and notify Beijing 7Q Technology Co., Ltd.       --
// (sales@7qtek.com) immediately that you inadvertently received an  --
// unauthorized copy.                                                --
//*******************************************************************--
//---------------------------------------------------------------------
// File name            : onewire_regfile.v
// File contents        : Module Registers Entities
// Purpose              : Implement SRAM scratchpad Entities
//                        Synthesisable HDL Core
// Destination project  : N20
// Destination library  : N20_LIB
//---------------------------------------------------------------------
// File Revision        : $Revision$
// File Author          : $Author$
// Last modification    : $Date$
//---------------------------------------------------------------------
//*******************************************************************--
//`timescale 1 ns / 100 ps // timescale for following module
//*******************************************************************--
module onewire_regfile(
   clk_2m4,                   // 2.4MHz clock
   clk_300,                   // 300KHz clock
   owpo_rstn,                 // poweron resetn, 0:in effect
   owwu_rstn,                 // wakeup resetn, 0:in effect
   owam_ppm,                  // adapter parasite power mode
   owam_rc0_we,               // romcode[7:0]   write enable
   owam_rc1_we,               // romcode[15:8]  write enable
   owam_rc2_we,               // romcode[23:16] write enable
   owam_rc3_we,               // romcode[31:24] write enable
   owam_rc4_we,               // romcode[39:32] write enable
   owam_rc5_we,               // romcode[47:40] write enable
   owam_rc6_we,               // romcode[55:48] write enable
   owam_rc7_we,               // romcode[63:56] write enable
   owam_tha_we,               // tha[7:0] reg   write enable
   owam_tla_we,               // tla[7:0] reg   write enable
   owam_cfg_we,               // cfg[7:0] reg   write enable
   owam_databus,              // write register 8-bit data bus
   owam_romcode,              // romcode[63:0] register
   owam_tha,                  // tha[7:0] register
   owam_tla,                  // tla[7:0] register
   owam_cfg,                  // cfg[7:0] register
   owam_byte5,                // byte5[7:0] register
   owam_byte6,                // byte6[7:0] register
   owam_byte7                 // byte7[7:0] register
   );

   `include "onewire_params.v"

   input                      clk_2m4;      // 2.4MHz clock
   input                      clk_300;      // 300KHz clock
   input                      owpo_rstn;    // poweron resetn, 0:ef
   input                      owwu_rstn;    // wakeup resetn, 0:ef
   input                      owam_ppm;     // parasite power mode:
                                            // 1=VDD,0=PPM
   input                      owam_rc0_we;  // romcode[7:0]   wr en
   input                      owam_rc1_we;  // romcode[15:8]  wr en
   input                      owam_rc2_we;  // romcode[23:16] wr en
   input                      owam_rc3_we;  // romcode[31:24] wr en
   input                      owam_rc4_we;  // romcode[39:32] wr en
   input                      owam_rc5_we;  // romcode[47:40] wr en
   input                      owam_rc6_we;  // romcode[55:48] wr en
   input                      owam_rc7_we;  // romcode[63:56] wr en
   input                      owam_tha_we;  // tha[7:0] reg   wr en
   input                      owam_tla_we;  // tla[7:0] reg   wr en
   input                      owam_cfg_we;  // cfg[7:0] reg   wr en
   input [7:0]                owam_databus; // wr reg 8-bit data bus
   //------------------------------------------------------------------
   output [63:0]              owam_romcode; // romcode[63:0] reg
   output [7:0]               owam_tha;     // tha[7:0] reg
   output [7:0]               owam_tla;     // tla[7:0] reg
   output [7:0]               owam_cfg;     // cfg[7:0] reg
   output [7:0]               owam_byte5;   // byte5 reg
   output [7:0]               owam_byte6;   // byte6 reg
   output [7:0]               owam_byte7;   // byte7 reg

   //-- module input signals --
   wire [7:0]                 owam_databus; // wr reg 8-bit data bus

   //-- module output signals --
   wire [63:0]                owam_romcode; // romcode[63:0] reg
   wire [7:0]                 owam_tha;     // tha[7:0] reg
   wire [7:0]                 owam_tla;     // tla[7:0] reg
   wire [7:0]                 owam_cfg;     // cfg[7:0] reg
   wire [7:0]                 owam_byte5;   // byte5 reg
   wire [7:0]                 owam_byte6;   // byte6 reg
   wire [7:0]                 owam_byte7;   // byte7 reg

   //------------------------------------------------------------------
   reg [63:0]                 reg_romcode; // romcode[63:0] reg
   reg [7:0]                  reg_tha;     // tha[7:0] reg
   reg [7:0]                  reg_tla;     // tla[7:0] reg
   reg [7:0]                  reg_cfg;     // cfg[7:0] reg
   reg [7:0]                  reg_byte5;   // byte5 reg
   reg [7:0]                  reg_byte6;   // byte6 reg
   reg [7:0]                  reg_byte7;   // byte7 reg

   //------------------------------------------------------------------
   assign owam_romcode = reg_romcode;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn | !owwu_rstn) begin
         reg_romcode <= ROMCODE_DEF;
      end else begin
	 if (owam_rc0_we) begin
            reg_romcode[7:0] <= owam_databus;
         end
	 if (owam_rc1_we) begin
            reg_romcode[15:8] <= owam_databus;
         end
	 if (owam_rc2_we) begin
            reg_romcode[23:16] <= owam_databus;
         end
	 if (owam_rc3_we) begin
            reg_romcode[31:24] <= owam_databus;
         end
	 if (owam_rc4_we) begin
            reg_romcode[39:32] <= owam_databus;
         end
	 if (owam_rc5_we) begin
            reg_romcode[47:40] <= owam_databus;
         end
	 if (owam_rc6_we) begin
            reg_romcode[55:48] <= owam_databus;
         end
	 if (owam_rc7_we) begin
            reg_romcode[63:56] <= owam_databus;
         end
      end
   end

   //------------------------------------------------------------------
   assign owam_tha = reg_tha;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn | !owwu_rstn) begin
         reg_tha <= THAREG_DEF;
      end else if (owam_tha_we) begin
         reg_tha <= owam_databus;
      end
   end

   //------------------------------------------------------------------
   assign owam_tla = reg_tla;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn | !owwu_rstn) begin
         reg_tla <= TLAREG_DEF;
      end else if (owam_tla_we) begin
         reg_tla <= owam_databus;
      end
   end

   //------------------------------------------------------------------
   assign owam_cfg = reg_cfg;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn | !owwu_rstn) begin
         reg_cfg <= CFGREG_DEF;
      end else if (owam_cfg_we) begin
         reg_cfg <= owam_databus;
      end
   end

   //------------------------------------------------------------------
   assign owam_byte5 = reg_byte5;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn | !owwu_rstn) begin
         reg_byte5 <= 8'hff;
      end
   end

   //------------------------------------------------------------------
   assign owam_byte6 = reg_byte6;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn | !owwu_rstn) begin
         reg_byte6 <= 8'h96;
      end
   end

   //------------------------------------------------------------------
   assign owam_byte7 = reg_byte7;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn | !owwu_rstn) begin
         reg_byte7 <= 8'h10;
      end
   end

endmodule // onewire_regfile
