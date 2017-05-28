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
// File name            : tb_onewire.v
// File contents        : TestBench of One-Wire-Bus Module
// Purpose              : Simulation of One-wire protocol/1-wire
//                        Simulating HDL code
// Destination project  : N20
// Destination library  : N20_LIB
//---------------------------------------------------------------------
// File Revision        : $Revision$
// File Author          : $Author$
// Last modification    : $Date$
//---------------------------------------------------------------------
//*******************************************************************--
`timescale 1 ns / 100 ps // timescale for following module
//*******************************************************************--
`include "onewire_define.v"
//`include "onewire_comparator.v"
//`include "onewire_adapter.v"
//`include "onewire_regfile.v"
module tb_onewire ();

`include "onewire_params.v"
   //---------------------------------------------------------------
   // Test Bench environment parameters
   //---------------------------------------------------------------
   parameter    CLK2M4PERIOD   = `CLK2M4PERIOD   ; //ns
   parameter    CLK2M4RATIO    = `CLK2M4RATIO    ;
   parameter    CLK2M4DUTY     = `CLK2M4DUTY     ;
   parameter    CLK300PERIOD   = `CLK300PERIOD   ; //ns
   parameter    CLK300RATIO    = `CLK300RATIO    ;
   parameter    CLK300DUTY     = `CLK300DUTY     ;
   parameter    RSTPULSEMIN    = `RSTPULSEMIN    ; //us
   parameter    RSTPULSEMAX    = `RSTPULSEMAX    ; //us
   parameter    PRESENCEMIN    = `PRESENCEMIN    ; //us
   parameter    PRESENCEMAX    = `PRESENCEMAX    ; //us
   parameter    TSLOTINITMIN   = `TSLOTINITMIN   ; //us
   parameter    TSLOTINITMAX   = `TSLOTINITMAX   ; //us
   parameter    TSLOTRCMIN     = `TSLOTRCMIN     ; //us
   parameter    TSLOTRCMAX     = `TSLOTRCMAX     ; //us
   parameter    TSLOTREMMIN    = `TSLOTREMMIN    ; //us
   parameter    TSLOTREMMAX    = `TSLOTREMMAX    ; //us
   parameter    RECOVERYMIN    = `RECOVERYMIN    ; //us
   parameter    RECOVERYMAX    = `RECOVERYMAX    ; //us
   parameter    POS125DEGREE   = `POS125DEGREE   ; //Celsius degree
   parameter    POS105DEGREE   = `POS105DEGREE   ; //Celsius degree
   parameter    POS85DEGREE    = `POS85DEGREE    ; //Celsius degree
   parameter    POS25DEGREE    = `POS25DEGREE    ; //Celsius degree
   parameter    POS10DEGREE    = `POS10DEGREE    ; //Celsius degree
   parameter    POS1DEGREE     = `POS1DEGREE     ; //Celsius degree
   parameter    CELSIUS0DEG    = `CELSIUS0DEG    ; //Celsius degree
   parameter    NEG1DEGREE     = `NEG1DEGREE     ; //Celsius degree
   parameter    NEG10DEGREE    = `NEG10DEGREE    ; //Celsius degree
   parameter    NEG25DEGREE    = `NEG25DEGREE    ; //Celsius degree
   parameter    NEG55DEGREE    = `NEG55DEGREE    ; //Celsius degree
   parameter    NEG85DEGREE    = `NEG85DEGREE    ; //Celsius degree
   parameter    NEG105DEGREE   = `NEG105DEGREE   ; //Celsius degree
   parameter    NEG125DEGREE   = `NEG125DEGREE   ; //Celsius degree


   // simulation signals define
   wire                       sys_clk2m4;   // clock 2.4MHz
   wire                       sys_clk300;   // clock 300KHz
   wire                       sys_resetn;   // resetn 0:reset
   reg                        sys_standby;  // standby
   reg                        onewire_ctok; // ConvertT done
   reg                        onewire_crok; // CopyReg done
   reg                        onewire_reok; // Recall EEPROM done
   reg                        onewire_ppm;  // parasite power mode
   reg [63:0]                 romcode;
   reg [7:0]                  owam_byte5;   // byte5
   reg [7:0]                  owam_byte6;   // byte6
   reg [7:0]                  owam_byte7;   // byte7
   wire [63:0]                owam_romcode; // romcode[63:0] reg
   wire [7:0]                 owam_tha;     // tha[7:0] reg
   wire [7:0]                 owam_tla;     // tla[7:0] reg
   wire [7:0]                 owam_cfg;     // cfg[7:0] reg
   wire                       owam_rc0_we;  // romcode[7:0]   wr en
   wire                       owam_rc1_we;  // romcode[15:8]  wr en
   wire                       owam_rc2_we;  // romcode[23:16] wr en
   wire                       owam_rc3_we;  // romcode[31:24] wr en
   wire                       owam_rc4_we;  // romcode[39:32] wr en
   wire                       owam_rc5_we;  // romcode[47:40] wr en
   wire                       owam_rc6_we;  // romcode[55:48] wr en
   wire                       owam_rc7_we;  // romcode[63:56] wr en
   wire                       owam_tha_we;  // tha[7:0] reg   wr en
   wire                       owam_tla_we;  // tla[7:0] reg   wr en
   wire                       owam_cfg_we;  // cfg[7:0] reg   wr en
   wire [7:0]                 owam_databus; // wr reg 8-bit data bus

   //------------------------------------------------------------------
   reg [15:0]                 onewire_temp;   // 16-bit temperature
   reg [15:0]                 onewire_ttrim;  // 16-bit timing adjust
   reg [7:0]                  onewire_byte0;  // byte0
   reg [7:0]                  onewire_byte1;  // byte1
   reg [7:0]                  onewire_byte2;  // byte2
   reg [7:0]                  onewire_byte3;  // byte3
   reg [7:0]                  onewire_byte4;  // byte4
   reg [7:0]                  onewire_byte5;  // byte5
   reg [7:0]                  onewire_byte6;  // byte6
   reg [7:0]                  onewire_byte7;  // byte7
   reg [7:0]                  onewire_byte8;  // byte8
   reg [7:0]                  onewire_byte9;  // byte9
   reg [7:0]                  onewire_byte10; // byte10
   reg [7:0]                  onewire_byte11; // byte11
   reg [7:0]                  onewire_byte12; // byte12
   reg [7:0]                  onewire_byte13; // byte13
   reg [7:0]                  onewire_byte14; // byte14
   reg [7:0]                  onewire_byte15; // byte15
   reg [7:0]                  onewire_byte16; // byte16
   reg [7:0]                  onewire_byte17; // byte17
   reg [7:0]                  onewire_byte18; // byte18
   reg [7:0]                  onewire_byte19; // byte19
   reg [7:0]                  onewire_byte20; // byte20
   reg [7:0]                  onewire_byte21; // byte21
   reg [7:0]                  onewire_byte22; // byte22
   reg [7:0]                  onewire_byte23; // byte23
   reg [7:0]                  onewire_byte24; // byte24
   reg [15:0]                 eeprom [1:16];  // EEPROM 16x16 bit
   reg [7:0]                  onewire_romcrc; // romcode[63:56]
   reg [7:0]                  onewire_regcrc; // byte8
   wire [15:0]                eeprom_edio;
   wire                       onewire_dq;
   wire                       onewire_dqin;
   wire                       onewire_dqout;
   wire                       onewire_dqena;
   wire                       onewire_convert; // ConvertT
   wire                       onewire_copyreg; // CopyReg
   wire                       onewire_recall;  // Recall EEPROM
   wire                       __DQ__;
   reg                        __PPM__;
   reg                        __CvT__;
   reg                        __CpR__;
   reg                        __RcE__;
   reg                        dat;
   reg [279:0]                scenario; //Max:35-char(contain space)
   reg [7:0]                  commands;
   reg [7:0]                  tx_bytes;
   reg [7:0]                  tx_bits;
   reg [7:0]                  tx_wdata;
   reg [7:0]                  tx_rdatt;
   reg [7:0]                  tx_rdatf;
   integer                    i, j;

`include "onewire_tasks.v"
   // initial EEPROM memory
   //initial begin
   //$readmemh("eeprom.data", eeprom); // load eeprom.data into
   // EEPROM memory
   //$readmemh("romcode.data", romcode); // load romcode.data into
   // romcode
   //end

   // simulation signals initial
   initial begin
      force analog_emu.rstn_o= 'b1;
      sys_standby = 'b0;
      INIT_OWBUS;
      romcode[63:0] = 64'h8300_0008_73B3_F528;
      $display("ROM Code[63: 0] = 64'h%04H_%04H_%04h_%04H",
               romcode[63:48], romcode[47:32], romcode[31:16],
               romcode[15:0]);
      onewire_ctok = 0; // ConvertT done
      onewire_crok = 0; // CopyReg done
      onewire_reok = 0; // Recall EEPROM done
      onewire_ppm = 1;  // parasite power mode:1=VDD,0=PPM
      onewire_temp = 16'h0550;  // 16-bit temperature
      onewire_ttrim = 16'h8989; // 16-bit timing adjust
      owam_byte5 = 8'hff;       // byte5
      owam_byte6 = 8'h96;       // byte6
      owam_byte7 = 8'h10;       // byte7
      onewire_byte0 = 8'h00;  // byte0
      onewire_byte1 = 8'h00;  // byte1
      onewire_byte2 = 8'h00;  // byte2
      onewire_byte3 = 8'h00;  // byte3
      onewire_byte4 = 8'h00;  // byte4
      onewire_byte5 = 8'h00;  // byte5
      onewire_byte6 = 8'h00;  // byte6
      onewire_byte7 = 8'h00;  // byte7
      onewire_byte8 = 8'h00;  // byte8
      onewire_byte9 = 8'h00;  // byte9
      onewire_byte10 = 8'h00; // byte10
      onewire_byte11 = 8'h00; // byte11
      onewire_byte12 = 8'h00; // byte12
      onewire_byte13 = 8'h00; // byte13
      onewire_byte14 = 8'h00; // byte14
      onewire_byte15 = 8'h00; // byte15
      onewire_byte16 = 8'h00; // byte16
      onewire_byte17 = 8'h00; // byte17
      onewire_byte18 = 8'h00; // byte18
      onewire_byte19 = 8'h00; // byte19
      onewire_byte20 = 8'h00; // byte20
      onewire_byte21 = 8'h00; // byte21
      onewire_byte22 = 8'h00; // byte22
      onewire_byte23 = 8'h00; // byte23
      onewire_byte24 = 8'h00; // byte24
   //------------------------------------------------------------------
`ifdef LOAD_EEPROM
      for (i=0; i<16; i=i+1) begin
         eeprom[i] = 16'h0000;
         //repeat(1) #(RECOVERYMIN*1000);
      end
     `ifdef MONO
      eeprom[0]  = {`TB_ONEWIRE.owam_inst.reg_tl[7:0],
                    `TB_ONEWIRE.owam_inst.reg_th[7:0]};
      eeprom[1]  = {owam_byte5[7:0],
                    `TB_ONEWIRE.owam_inst.reg_config[7:0]};
     `else
      eeprom[0]  = {owam_tla[7:0],owam_tha[7:0]};
      eeprom[1]  = {owam_byte5[7:0],owam_cfg[7:0]};
     `endif
      eeprom[2]  = {owam_byte7[7:0],owam_byte6[7:0]};
      eeprom[3]  = 16'h55aa;
      eeprom[4]  = romcode[15:0];
      eeprom[5]  = romcode[31:16];
      eeprom[6]  = romcode[47:32];
      eeprom[7]  = romcode[63:48];
`endif
   end

	reg DQ_DRIVE;

   // generate simulation clock

   // 1-wire protocol simulation
   always @(`OWAM.reg_comm) begin
      if (`OWAM.reg_comm==8'h00) commands = 8'bzzzz_zzzz;
      else commands = `OWAM.reg_comm;
   end

   // onewire adapter instance
   //pullup #(TSLOTRCMIN*100) (__DQ__);
   pullup(__DQ__);
   owpad                    owpad_inst
     (
      // inout
      .__dq__               (__DQ__),
      // output
      .dq_in                (onewire_dqin),
      // input
      .dq_out               (onewire_dqout),
      .dq_ena               (onewire_dqena)
      );
   //assign onewire_dqin = __DQ__;
   owand                  owand_inst
     (
      // inout
      .__dq__               (__DQ__),
      .dq_pad               (onewire_dq),
      // input
      .dq_drive             (DQ_DRIVE)
      );
   //------------------------------------------------------------------
   //assign __DQ__ = onewire_dqena? onewire_dqout : 
   //                               `TB_ONEWIRE.DQ_DRIVE;
  analog_emu 
  #(.CLK2M4PERIOD(CLK2M4PERIOD), .CLK300PERIOD(CLK300PERIOD))
  analog_emu
  (
      .clk_2m4              (sys_clk2m4),
      .clk_300k             (sys_clk300),
      .rstn_o               (sys_resetn)
  );

   onewire_adapter          owam_inst
     (
      // input
      .clk_2m4              (sys_clk2m4),
      .clk_300              (sys_clk300),
      .owpo_rstn            (sys_resetn),
      .owwu_rstn            (sys_resetn),
      .owam_ppm             (onewire_ppm),  // parasite power mode
      .owam_ctok            (onewire_ctok), // ConvertT done
      .owam_temp            (onewire_temp), // 16-bit temperature
      .owam_crok            (onewire_crok), // CopyReg done
      .owam_reok            (onewire_reok), // Recall EEPROM done
      .dq_in                (onewire_dqin),
     `ifdef MONO
     `else
      .owam_romcode         (owam_romcode), // romcode[63:0]
      .owam_tha             (owam_tha),     // tha[7:0]
      .owam_tla             (owam_tla),     // tla[7:0]
      .owam_cfg             (owam_cfg),     // cfg[7:0]
     `endif
      .owam_byte5           (owam_byte5),   // byte5[7:0]
      .owam_byte6           (owam_byte6),   // byte6[7:0]
      .owam_byte7           (owam_byte7),   // byte7[7:0]
     `ifdef DTT
      .owam_ttrim           (onewire_ttrim), // 16-bit timing adjust
     `endif
      // output
     `ifdef MONO
     `else
      .owam_rc0_we          (owam_rc0_we),  // romcode[7:0]   wr en
      .owam_rc1_we          (owam_rc1_we),  // romcode[15:8]  wr en
      .owam_rc2_we          (owam_rc2_we),  // romcode[23:16] wr en
      .owam_rc3_we          (owam_rc3_we),  // romcode[31:24] wr en
      .owam_rc4_we          (owam_rc4_we),  // romcode[39:32] wr en
      .owam_rc5_we          (owam_rc5_we),  // romcode[47:40] wr en
      .owam_rc6_we          (owam_rc6_we),  // romcode[55:48] wr en
      .owam_rc7_we          (owam_rc7_we),  // romcode[63:56] wr en
      .owam_tha_we          (owam_tha_we),  // tha[7:0] reg   wr en
      .owam_tla_we          (owam_tla_we),  // tla[7:0] reg   wr en
      .owam_cfg_we          (owam_cfg_we),  // cfg[7:0] reg   wr en
      .owam_databus         (owam_databus), // wr reg 8-bit data bus
     `endif
      .owam_copyreg         (onewire_copyreg), // issue CopyReg
      .owam_recall          (onewire_recall),  // issue Recall
      .owam_convert         (onewire_convert), // issue ConvertT
      .dq_out               (onewire_dqout),
      .dq_ena               (onewire_dqena)
      );

   //------------------------------------------------------------------
   onewire_regfile          regfile_inst
     (
      // input
      .clk_2m4              (sys_clk2m4),
      .clk_300              (sys_clk300),
      .owpo_rstn            (sys_resetn),
      .owwu_rstn            (sys_resetn),
      .owam_ppm             (onewire_ppm),  // parasite power mode
      .owam_rc0_we          (owam_rc0_we),  // romcode[7:0]   wr en
      .owam_rc1_we          (owam_rc1_we),  // romcode[15:8]  wr en 
      .owam_rc2_we          (owam_rc2_we),  // romcode[23:16] wr en 
      .owam_rc3_we          (owam_rc3_we),  // romcode[31:24] wr en 
      .owam_rc4_we          (owam_rc4_we),  // romcode[39:32] wr en 
      .owam_rc5_we          (owam_rc5_we),  // romcode[47:40] wr en 
      .owam_rc6_we          (owam_rc6_we),  // romcode[55:48] wr en
      .owam_rc7_we          (owam_rc7_we),  // romcode[63:56] wr en
      .owam_tha_we          (owam_tha_we),  // tha[7:0] reg   wr en
      .owam_tla_we          (owam_tla_we),  // tla[7:0] reg   wr en
      .owam_cfg_we          (owam_cfg_we),  // cfg[7:0] reg   wr en
      .owam_databus         (owam_databus), // wr reg 8-bit data bus
      // output
      .owam_romcode         (owam_romcode), // romcode[63:0]
      .owam_tha             (owam_tha),     // tha[7:0]
      .owam_tla             (owam_tla),     // tla[7:0]
      .owam_cfg             (owam_cfg),     // cfg[7:0]
      .owam_byte5           (),   // byte5[7:0]
      .owam_byte6           (),   // byte6[7:0]
      .owam_byte7           ()    // byte7[7:0]
      );

`ifdef FSDB
   initial begin
      $fsdbDumpfile("onewire_test.fsdb");
      $fsdbDumpvars(0,tb_onewire,"+mda");
      $fsdbDumpon();
   end
`endif

`ifdef VCD
   initial begin
      $dumpfile("onewire_test.vcd");
      $dumpvars;
   end
`endif

   // back-annotate sdf
   //initial begin
   //$sdf_annotate("sdf_onewire_adapter", onewire_adapter, 1);
   //end

   // generate simulation sequency
   initial begin
      /* 
       * $shm_open("waves.shm");
       * $shm_probe(tb_onewire, "AS"); // AC: include library cells
       */
      $display("simulation start from here");
      scenario = "--<0>-- Initialization";
      $display("%0s",scenario);
      //commands = 8'bzzzz_zzzz;
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(10) #(RECOVERYMIN*1000);
      force analog_emu.rstn_o= 'b0;
      repeat(20) #(RECOVERYMIN*1000);
      force analog_emu.rstn_o= 'b1;
      repeat(100) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<1>--0x55,romcode[63:0]--0x4e,th,tl,config----
      //---------------------------------------------------------------
      scenario = "--<1>-- ->MatchROM(hit)->WrReg";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_MatchROM);
      tx_wdata = OWRC_MatchROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      //WRITE_ONE_BYTE(romcode[7:0]);
      tx_wdata = romcode[7:0];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[15:8]);
      tx_wdata = romcode[15:8];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[23:16]);
      tx_wdata = romcode[23:16];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[31:24]);
      tx_wdata = romcode[31:24];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[39:32]);
      tx_wdata = romcode[39:32];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[47:40]);
      tx_wdata = romcode[47:40];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[55:48]);
      tx_wdata = romcode[55:48];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[63:56]);
      tx_wdata = romcode[63:56];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_WriteReg);
      tx_wdata = OWFC_WriteReg;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b00;
      //WRITE_ONE_BYTE(POS105DEGREE);
      tx_wdata = POS105DEGREE;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(NEG105DEGREE);
      tx_wdata = NEG105DEGREE;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(8'h7f); //[R2:R0]=[7:5]=3'b011,12-bit resolution
      tx_wdata = 8'h7f;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);


      //---------------------------------------------------------------
      //--<2>--0x33,romcode[63:0]--0xbe,byte0-9----
      //---------------------------------------------------------------
      scenario = "--<2>-- ->RdROM(hit)->RdReg";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      owam_byte5 = 8'hff; // byte5
      owam_byte6 = 8'h69; // byte6
      romcode[63:0]=64'h0000_0000_0000_0000;
      repeat(10) #(RECOVERYMIN*1000);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_ReadROM);
      tx_wdata = OWRC_ReadROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      tx_wdata = 8'bzzzz_zzzz;
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      for (i=0; i<64; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(romcode[i]);
         end else begin
            READ_SLOT_MIN(romcode[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            j = i - 7;
            tx_rdatt = {romcode[i],romcode[i-1],romcode[i-2],
                        romcode[i-3],romcode[i-4],romcode[i-5],
                        romcode[i-6],romcode[i-7]};
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_ReadReg);
      tx_wdata = OWFC_ReadReg;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      tx_wdata = 8'bzzzz_zzzz;
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte0[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte0[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte0;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte1[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte1[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte1;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte2[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte2[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte2;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte3[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte3[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte3;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte4[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte4[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte4;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte5[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte5[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte5;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte6[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte6[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte6;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte7[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte7[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte7;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte8[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte8[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte8;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<3>--0x55,romcode[63:0]&0x0..--0x4e,th,tl,config----
      //---------------------------------------------------------------
      scenario = "--<3>-- ->MatchROM(miss)->WrReg";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_MatchROM);
      tx_wdata = OWRC_MatchROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      //WRITE_ONE_BYTE(romcode[7:0]);
      tx_wdata = romcode[7:0];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[15:8]);
      tx_wdata = romcode[15:8];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[23:16]);
      tx_wdata = romcode[23:16];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[31:24]);
      tx_wdata = romcode[31:24];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[39:32]);
      tx_wdata = romcode[39:32];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[47:40]);
      tx_wdata = romcode[47:40];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[55:48]);
      tx_wdata = romcode[55:48];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[63:56]&8'h0f);
      tx_wdata = romcode[63:56] & 8'h0f;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_WriteReg);
      tx_wdata = OWFC_WriteReg;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b00;
      //WRITE_ONE_BYTE(POS105DEGREE);
      tx_wdata = POS105DEGREE;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(NEG105DEGREE);
      tx_wdata = NEG105DEGREE;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(8'h7f); //[R2:R0]=[7:5]=3'b011,12-bit resolution
      tx_wdata = 8'h7f;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<4>--0xf0,byte9-16----
      //---------------------------------------------------------------
      scenario = "--<4>-- ->SearchROM(hit)";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      owam_byte5 = 8'h04; // byte5
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_SearchROM);
      tx_wdata = OWRC_SearchROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      j=0;
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte9[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte10[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte9[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte10[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte9;
            tx_rdatf = onewire_byte10;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte11[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte12[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte11[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte12[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte11;
            tx_rdatf = onewire_byte12;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte13[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte14[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte13[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte14[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte13;
            tx_rdatf = onewire_byte14;
         end
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte15[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte16[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte15[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte16[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte15;
            tx_rdatf = onewire_byte16;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte17[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte18[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte17[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte18[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte17;
            tx_rdatf = onewire_byte18;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte19[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte20[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte19[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte20[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte19;
            tx_rdatf = onewire_byte20;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte21[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte22[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte21[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte22[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte21;
            tx_rdatf = onewire_byte22;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte23[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte24[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte23[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte24[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte23;
            tx_rdatf = onewire_byte24;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<5>--0xf0,byte9,11,13,15,17,19,21,!23..----
      //---------------------------------------------------------------
      scenario = "--<5>-- ->SearchROM(miss)";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      onewire_byte9 = 8'h00;
      onewire_byte10 = 8'h00;
      onewire_byte11 = 8'h00;
      onewire_byte12 = 8'h00;
      onewire_byte13 = 8'h00;
      onewire_byte14 = 8'h00;
      onewire_byte15 = 8'h00;
      onewire_byte16 = 8'h00;
      onewire_byte17 = 8'h00;
      onewire_byte18 = 8'h00;
      onewire_byte19 = 8'h00;
      onewire_byte20 = 8'h00;
      onewire_byte21 = 8'h00;
      onewire_byte22 = 8'h00;
      onewire_byte23 = 8'h00;
      onewire_byte24 = 8'h00;
      repeat(1) #(RECOVERYMIN*1000);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_SearchROM);
      tx_wdata = OWRC_SearchROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      j=0;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte9[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte10[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte9[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte10[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte9;
            tx_rdatf = onewire_byte10;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte11[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte12[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte11[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte12[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte11;
            tx_rdatf = onewire_byte12;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte13[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte14[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte13[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte14[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte13;
            tx_rdatf = onewire_byte14;
         end
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte15[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte16[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte15[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte16[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte15;
            tx_rdatf = onewire_byte16;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte17[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte18[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte17[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte18[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte17;
            tx_rdatf = onewire_byte18;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte19[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte20[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte19[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte20[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte19;
            tx_rdatf = onewire_byte20;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte21[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte22[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte21[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte22[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte21;
            tx_rdatf = onewire_byte22;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = ~romcode[j+7:j];
      tx_wdata = ~{romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                   romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte23[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte24[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte23[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte24[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (!romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte23;
            tx_rdatf = onewire_byte24;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<6>--0x55,romcode[63:0]--0xb4,PPM----
      //---------------------------------------------------------------
      scenario = "--<6>-- ->MatchROM(hit)->RdPPM";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_MatchROM);
      tx_wdata = OWRC_MatchROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      //WRITE_ONE_BYTE(romcode[7:0]);
      tx_wdata = romcode[7:0];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[15:8]);
      tx_wdata = romcode[15:8];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[23:16]);
      tx_wdata = romcode[23:16];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[31:24]);
      tx_wdata = romcode[31:24];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[39:32]);
      tx_wdata = romcode[39:32];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[47:40]);
      tx_wdata = romcode[47:40];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[55:48]);
      tx_wdata = romcode[55:48];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[63:56]);
      tx_wdata = romcode[63:56];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_ReadPPM);
      tx_wdata = OWFC_ReadPPM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b00;
      READ_SLOT_MIN(__PPM__);
      wait(__DQ__);
      tx_bits = tx_bits + 8'h01;
      tx_bytes = tx_bytes + 8'h01;
      tx_rdatt = {8{__PPM__}};
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<7>--0xcc--0x44,VDD(read...)----
      //---------------------------------------------------------------
      scenario = "--<7>-- ->Skip->ConvT(VDD,noAlarm)";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_SkipROM);
      tx_wdata = OWRC_SkipROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_ConvertT);
      tx_wdata = OWFC_ConvertT;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      i = 0;
      __CvT__ = 0;
      while (__CvT__==0) begin
         if (i & 1) begin
            READ_SLOT_MAX(__CvT__);
         end else begin
            READ_SLOT_MIN(__CvT__);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = {8{__CvT__}};
         end
         tx_bits = tx_bits + 8'h01;
         repeat(10) #(RECOVERYMIN*1000);
         //__CvT__ = !__CvT__;
         tx_rdatt = 8'bzzzz_zzzz;
         if (i==270) begin
            onewire_ctok = 1;
         end else if (i==271) begin
            onewire_ctok = 0;
         end
         i = i + 1;
      end
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<8>--0xcc--0x44,PPM(wait...)----
      //---------------------------------------------------------------
      scenario = "--<8>-- ->Skip->ConvT,PPM,SetAlarm";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      onewire_ppm = 0;
      __PPM__ = onewire_ppm;
      repeat(10) #(RECOVERYMIN*1000);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_SkipROM);
      tx_wdata = OWRC_SkipROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_ConvertT);
      tx_wdata = OWFC_ConvertT;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      i = 0;
      __CvT__ = 0;
      /*while (__CvT__==0) begin
         if (i & 1) begin
            READ_SLOT_MAX(__CvT__);
         end else begin
            READ_SLOT_MIN(__CvT__);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = {8{__CvT__}};
         end
         tx_bits = tx_bits + 8'h01;
         repeat(10) #(RECOVERYMIN*1000);
         //__CvT__ = !__CvT__;
         tx_rdatt = 8'bzzzz_zzzz;
         if (i==270) begin
            onewire_ctok = 1;
         end else if (i==271) begin
            onewire_ctok = 0;
         end
         i = i + 1;
      end*/
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      onewire_temp = 16'h0690;
      repeat(27010) #(RECOVERYMIN*1000);
      onewire_ctok = 1;
      repeat(100) #(RECOVERYMIN*1000);
      onewire_ctok = 0;
      repeat(3000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<9>--0x55,romcode[63:0]--0x48,VDD(read...)----
      //---------------------------------------------------------------
      scenario = "--<9>-- ->MatchROM(hit)->Copy(VDD)";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      onewire_ppm = 1;
      __PPM__ = onewire_ppm;
      repeat(10) #(RECOVERYMIN*1000);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_MatchROM);
      tx_wdata = OWRC_MatchROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      //WRITE_ONE_BYTE(romcode[7:0]);
      tx_wdata = romcode[7:0];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[15:8]);
      tx_wdata = romcode[15:8];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[23:16]);
      tx_wdata = romcode[23:16];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[31:24]);
      tx_wdata = romcode[31:24];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[39:32]);
      tx_wdata = romcode[39:32];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[47:40]);
      tx_wdata = romcode[47:40];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[55:48]);
      tx_wdata = romcode[55:48];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[63:56]);
      tx_wdata = romcode[63:56];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_CopyReg);
      tx_wdata = OWFC_CopyReg;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      i = 0;
      __CpR__ = 0;
      while (__CpR__==0) begin
         if (i & 1) begin
            READ_SLOT_MAX(__CpR__);
         end else begin
            READ_SLOT_MIN(__CpR__);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = {8{__CpR__}};
         end
         tx_bits = tx_bits + 8'h01;
         repeat(10) #(RECOVERYMIN*1000);
         //__CpR__ = !__CpR__;
         tx_rdatt = 8'bzzzz_zzzz;
         if (i==170) begin
            onewire_crok = 1;
         end else if (i==181) begin
            onewire_crok = 0;
         end
         i = i + 1;
      end
      if (onewire_crok) begin
         onewire_crok = 0;
      end
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<10>--0x55,romcode[63:0]--0x48,PPM(wait...)----
      //---------------------------------------------------------------
      scenario = "--<10>-- ->MatchROM(hit)->Copy(PPM)";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      onewire_ppm = 0;
      __PPM__ = onewire_ppm;
      repeat(10) #(RECOVERYMIN*1000);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_MatchROM);
      tx_wdata = OWRC_MatchROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      //WRITE_ONE_BYTE(romcode[7:0]);
      tx_wdata = romcode[7:0];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[15:8]);
      tx_wdata = romcode[15:8];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[23:16]);
      tx_wdata = romcode[23:16];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[31:24]);
      tx_wdata = romcode[31:24];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[39:32]);
      tx_wdata = romcode[39:32];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[47:40]);
      tx_wdata = romcode[47:40];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[55:48]);
      tx_wdata = romcode[55:48];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[63:56]);
      tx_wdata = romcode[63:56];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_CopyReg);
      tx_wdata = OWFC_CopyReg;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      i = 0;
      __CpR__ = 0;
      /*while (__CpR__==0) begin
         if (i & 1) begin
            READ_SLOT_MAX(__CpR__);
         end else begin
            READ_SLOT_MIN(__CpR__);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = {8{__CpR__}};
         end
         tx_bits = tx_bits + 8'h01;
         repeat(10) #(RECOVERYMIN*1000);
         //__CpR__ = !__CpR__;
         tx_rdatt = 8'bzzzz_zzzz;
         if (i==270) begin
            onewire_crok = 1;
         end else if (i==271) begin
            onewire_crok = 0;
         end
         i = i + 1;
      end*/
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(17010) #(RECOVERYMIN*1000);
      onewire_crok = 1;
      repeat(100) #(RECOVERYMIN*1000);
      onewire_crok = 0;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<11>--0xcc--0xb8,VDD(read...)----
      //---------------------------------------------------------------
      scenario = "--<11>-- ->SkipROM->Recall(VDD)";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      onewire_ppm = 1;
      __PPM__ = onewire_ppm;
      repeat(10) #(RECOVERYMIN*1000);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_SkipROM);
      tx_wdata = OWRC_SkipROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_RecallE2);
      tx_wdata = OWFC_RecallE2;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      i = 0;
      __RcE__ = 0;
      while (__RcE__==0) begin
         if (i & 1) begin
            READ_SLOT_MAX(__RcE__);
         end else begin
            READ_SLOT_MIN(__RcE__);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = {8{__RcE__}};
         end
         tx_bits = tx_bits + 8'h01;
         repeat(10) #(RECOVERYMIN*1000);
         //__RcE__ = !__RcE__;
         tx_rdatt = 8'bzzzz_zzzz;
         if (i==130) begin
            onewire_reok = 1;
         end else if (i==171) begin
            onewire_reok = 0;
         end
         i = i + 1;
      end
      if (onewire_reok) begin
         onewire_reok = 0;
      end
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<12>--0xcc--0xb8,PPM(wait...)----
      //---------------------------------------------------------------
      scenario = "--<12>-- ->SkipROM->Recall(PPM)";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      onewire_ppm = 0;
      __PPM__ = onewire_ppm;
      repeat(10) #(RECOVERYMIN*1000);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_SkipROM);
      tx_wdata = OWRC_SkipROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_RecallE2);
      tx_wdata = OWFC_RecallE2;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      i = 0;
      __RcE__ = 0;
      /*while (__RcE__==0) begin
         if (i & 1) begin
            READ_SLOT_MAX(__RcE__);
         end else begin
            READ_SLOT_MIN(__RcE__);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = {8{__RcE__}};
         end
         tx_bits = tx_bits + 8'h01;
         repeat(10) #(RECOVERYMIN*1000);
         //__RcE__ = !__RcE__;
         tx_rdatt = 8'bzzzz_zzzz;
         if (i==130) begin
            onewire_ctok = 1;
         end else if (i==171) begin
            onewire_ctok = 0;
         end
         i = i + 1;
      end
      if (onewire_reok) begin
         onewire_reok = 0;
      end*/
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(13010) #(RECOVERYMIN*1000);
      onewire_reok = 1;
      repeat(3000) #(RECOVERYMIN*1000);
      onewire_reok = 0;
      repeat(3000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<13>--0xec,byte9,11,13,15,17,19,21,!23----
      //---------------------------------------------------------------
      scenario = "--<13>-- ->AlarmSearch(miss)";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      onewire_ppm = 1;
      __PPM__ = onewire_ppm;
      repeat(10) #(RECOVERYMIN*1000);
      onewire_byte9 = 8'h00;
      onewire_byte10 = 8'h00;
      onewire_byte11 = 8'h00;
      onewire_byte12 = 8'h00;
      onewire_byte13 = 8'h00;
      onewire_byte14 = 8'h00;
      onewire_byte15 = 8'h00;
      onewire_byte16 = 8'h00;
      onewire_byte17 = 8'h00;
      onewire_byte18 = 8'h00;
      onewire_byte19 = 8'h00;
      onewire_byte20 = 8'h00;
      onewire_byte21 = 8'h00;
      onewire_byte22 = 8'h00;
      onewire_byte23 = 8'h00;
      onewire_byte24 = 8'h00;
      repeat(10) #(RECOVERYMIN*1000);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_AlarmSearch);
      tx_wdata = OWRC_AlarmSearch;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      j=0;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte9[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte10[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte9[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte10[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte9;
            tx_rdatf = onewire_byte10;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte11[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte12[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte11[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte12[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte11;
            tx_rdatf = onewire_byte12;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte13[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte14[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte13[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte14[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte13;
            tx_rdatf = onewire_byte14;
         end
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte15[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte16[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte15[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte16[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte15;
            tx_rdatf = onewire_byte16;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte17[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte18[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte17[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte18[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte17;
            tx_rdatf = onewire_byte18;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte19[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte20[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte19[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte20[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte19;
            tx_rdatf = onewire_byte20;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte21[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte22[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte21[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte22[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte21;
            tx_rdatf = onewire_byte22;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = ~romcode[j+7:j];
      tx_wdata = ~{romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                   romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte23[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte24[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte23[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte24[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (!romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte23;
            tx_rdatf = onewire_byte24;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<14>--0xcc--0x44,VDD(read...)----
      //---------------------------------------------------------------
      scenario = "--<14>-- ->Skip->ConvT(ClrAlarm)";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_SkipROM);
      tx_wdata = OWRC_SkipROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_ConvertT);
      tx_wdata = OWFC_ConvertT;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      i = 0;
      __CvT__ = 0;
      while (__CvT__==0) begin
         if (i & 1) begin
            READ_SLOT_MAX(__CvT__);
         end else begin
            READ_SLOT_MIN(__CvT__);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = {8{__CvT__}};
         end
         tx_bits = tx_bits + 8'h01;
         repeat(10) #(RECOVERYMIN*1000);
         //__CvT__ = !__CvT__;
         tx_rdatt = 8'bzzzz_zzzz;
         if (i==260) begin
            onewire_temp = 16'h0590;
         end else if (i==270) begin
            onewire_ctok = 1;
         end else if (i==271) begin
            onewire_ctok = 0;
         end
         i = i + 1;
      end
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<15>--0xec,byte9-23=high...----
      //---------------------------------------------------------------
      scenario = "--<15>-- ->AlarmSearch(NoAlarm)";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      onewire_byte9 = 8'h00;
      onewire_byte10 = 8'h00;
      onewire_byte11 = 8'h00;
      onewire_byte12 = 8'h00;
      onewire_byte13 = 8'h00;
      onewire_byte14 = 8'h00;
      onewire_byte15 = 8'h00;
      onewire_byte16 = 8'h00;
      onewire_byte17 = 8'h00;
      onewire_byte18 = 8'h00;
      onewire_byte19 = 8'h00;
      onewire_byte20 = 8'h00;
      onewire_byte21 = 8'h00;
      onewire_byte22 = 8'h00;
      onewire_byte23 = 8'h00;
      onewire_byte24 = 8'h00;
      repeat(10) #(RECOVERYMIN*1000);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      WRITE_ONE_BYTE(OWRC_AlarmSearch);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_AlarmSearch);
      tx_wdata = OWRC_AlarmSearch;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      j=0;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte9[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte10[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte9[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte10[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte9;
            tx_rdatf = onewire_byte10;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte11[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte12[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte11[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte12[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte11;
            tx_rdatf = onewire_byte12;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte13[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte14[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte13[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte14[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte13;
            tx_rdatf = onewire_byte14;
         end
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte15[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte16[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte15[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte16[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte15;
            tx_rdatf = onewire_byte16;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte17[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte18[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte17[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte18[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte17;
            tx_rdatf = onewire_byte18;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte19[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte20[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte19[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte20[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte19;
            tx_rdatf = onewire_byte20;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte21[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte22[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte21[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte22[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte21;
            tx_rdatf = onewire_byte22;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      j=j+8;
      //tx_wdata = romcode[j+7:j];
      tx_wdata = {romcode[j+7],romcode[j+6],romcode[j+5],romcode[j+4],
                  romcode[j+3],romcode[j+2],romcode[j+1],romcode[j]};
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte23[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MIN(onewire_byte24[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte23[i]);
            wait(__DQ__);
            tx_bits = tx_bits + 8'h01;
            repeat(1) #(RECOVERYMIN*1000);
            READ_SLOT_MAX(onewire_byte24[i]);
         end
         wait(__DQ__);
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
         if (romcode[i+j]) begin
            WRITE_1_SLOT_MIN;
         end else begin
            WRITE_0_SLOT_MIN;
         end
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = onewire_byte23;
            tx_rdatf = onewire_byte24;
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<16>--0xcc--0x44,VDD(read...)----
      //---------------------------------------------------------------
      scenario = "--<16>-- ->SkipROM->ConvT(Alarm)";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_SkipROM);
      tx_wdata = OWRC_SkipROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_ConvertT);
      tx_wdata = OWFC_ConvertT;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      i = 0;
      __CvT__ = 0;
      while (__CvT__==0) begin
         if (i & 1) begin
            READ_SLOT_MAX(__CvT__);
         end else begin
            READ_SLOT_MIN(__CvT__);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = {8{__CvT__}};
         end
         tx_bits = tx_bits + 8'h01;
         repeat(10) #(RECOVERYMIN*1000);
         //__CvT__ = !__CvT__;
         tx_rdatt = 8'bzzzz_zzzz;
         if (i==260) begin
            onewire_temp = 16'h0970;
         end else if (i==270) begin
            onewire_ctok = 1;
         end else if (i==271) begin
            onewire_ctok = 0;
         end
         i = i + 1;
      end
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<17>--0xcc,romcode[63:0]--0xbe,byte0-..5(break)..9----
      //---------------------------------------------------------------
      scenario = "--<17>-- ->Skip->RdReg(break-5-)";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      owam_byte5 = 8'hff; // byte5
      owam_byte6 = 8'h96; // byte6
      //romcode[63:0]=64'h0000_0000_0000_0000;
      repeat(10) #(RECOVERYMIN*1000);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_SkipROM);
      tx_wdata = OWRC_SkipROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      /*repeat(1) #(RECOVERYMIN*1000);
      for (i=0; i<64; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(romcode[i]);
         end else begin
            READ_SLOT_MIN(romcode[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = romcode[i:i-7];
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;*/
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_ReadReg);
      tx_wdata = OWFC_ReadReg;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      tx_wdata = 8'bzzzz_zzzz;
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte0[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte0[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte0;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte1[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte1[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte1;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte2[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte2[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte2;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte3[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte3[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte3;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte4[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte4[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte4;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte5[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte5[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte5;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      /*for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte6[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte6[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte6;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte7[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte7[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte7;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte8[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte8[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte8;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_bytes = tx_bytes + 8'h01;*/
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<18>--0x55,romcode[63:0]--0xb4,PPM----
      //---------------------------------------------------------------
      scenario = "--<18>-- ->MatchROM(hit)->RdPPM";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      onewire_ppm = 0;
      __PPM__ = onewire_ppm;
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_MatchROM);
      tx_wdata = OWRC_MatchROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      //WRITE_ONE_BYTE(romcode[7:0]);
      tx_wdata = romcode[7:0];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[15:8]);
      tx_wdata = romcode[15:8];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[23:16]);
      tx_wdata = romcode[23:16];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[31:24]);
      tx_wdata = romcode[31:24];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[39:32]);
      tx_wdata = romcode[39:32];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[47:40]);
      tx_wdata = romcode[47:40];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[55:48]);
      tx_wdata = romcode[55:48];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[63:56]);
      tx_wdata = romcode[63:56];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_ReadPPM);
      tx_wdata = OWFC_ReadPPM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b00;
      READ_SLOT_MIN(__PPM__);
      wait(__DQ__);
      tx_bits = tx_bits + 8'h01;
      tx_bytes = tx_bytes + 8'h01;
      tx_rdatt = {8{__PPM__}};
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<19>--0xcc,romcode[63:0]--0xbe,byte0-..5(break)..9----
      //---------------------------------------------------------------
      scenario = "--<19>-- ->Skip->RdReg(bk-5-)6[0]";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      owam_byte5 = 8'h7f; // byte5
      owam_byte6 = 8'h95; // byte6
      //romcode[63:0]=64'h0000_0000_0000_0000;
      repeat(10) #(RECOVERYMIN*1000);
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_SkipROM);
      tx_wdata = OWRC_SkipROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      /*repeat(1) #(RECOVERYMIN*1000);
      for (i=0; i<64; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(romcode[i]);
         end else begin
            READ_SLOT_MIN(romcode[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) begin
            tx_bytes = tx_bytes + 8'h01;
            tx_rdatt = romcode[i:i-7];
         end
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;*/
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_ReadReg);
      tx_wdata = OWFC_ReadReg;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      tx_wdata = 8'bzzzz_zzzz;
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte0[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte0[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte0;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte1[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte1[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte1;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte2[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte2[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte2;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte3[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte3[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte3;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte4[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte4[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte4;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte5[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte5[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte5;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      /*for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte6[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte6[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte6;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte7[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte7[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte7;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_rdatt = 8'bzzzz_zzzz;
      tx_bytes = tx_bytes + 8'h01;
      for (i=0; i<8; i=i+1) begin
         if (i & 1) begin
            READ_SLOT_MAX(onewire_byte8[i]);
         end else begin
            READ_SLOT_MIN(onewire_byte8[i]);
         end
         wait(__DQ__);
         if (((i+1)%8)==0) tx_rdatt = onewire_byte8;
         tx_bits = tx_bits + 8'h01;
         repeat(1) #(RECOVERYMIN*1000);
      end
      tx_bytes = tx_bytes + 8'h01;*/
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<20>--0x55,romcode[63:0]--0xb4,PPM----
      //---------------------------------------------------------------
      scenario = "--<20>-- ->MatchROM(hit)->RdPPM";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      onewire_ppm = 0;
      __PPM__ = onewire_ppm;
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_MatchROM);
      tx_wdata = OWRC_MatchROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      //WRITE_ONE_BYTE(romcode[7:0]);
      tx_wdata = romcode[7:0];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[15:8]);
      tx_wdata = romcode[15:8];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[23:16]);
      tx_wdata = romcode[23:16];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[31:24]);
      tx_wdata = romcode[31:24];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[39:32]);
      tx_wdata = romcode[39:32];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[47:40]);
      tx_wdata = romcode[47:40];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[55:48]);
      tx_wdata = romcode[55:48];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[63:56]);
      tx_wdata = romcode[63:56];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWFC_ReadPPM);
      tx_wdata = OWFC_ReadPPM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b00;
      READ_SLOT_MIN(__PPM__);
      wait(__DQ__);
      tx_bits = tx_bits + 8'h01;
      tx_bytes = tx_bytes + 8'h01;
      tx_rdatt = {8{__PPM__}};
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      //--<21>--0xa6,romcode[63:0]----
      //---------------------------------------------------------------
      scenario = "--<21>-- ->SetupROM(crcerr)";
      //---------"-------8-------16-------24-------35"-----------------
      $display("%0s",scenario);
      //onewire_ppm = 0;
      //__PPM__ = onewire_ppm;
      romcode[63:0] = 64'h8311_1118_73B3_F528;
      RESET_PULSE;
      repeat(10) #(RECOVERYMIN*1000);
      DRIVE_DQ_Z;
      @(negedge __DQ__);
      @(posedge __DQ__);
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'b1100_zzzz;
      tx_bits = 8'h00;
      //WRITE_ONE_BYTE(OWRC_SetupROM);
      tx_wdata = OWRC_SetupROM;
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'h00;
      //WRITE_ONE_BYTE(romcode[7:0]);
      tx_wdata = romcode[7:0];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[15:8]);
      tx_wdata = romcode[15:8];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[23:16]);
      tx_wdata = romcode[23:16];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[31:24]);
      tx_wdata = romcode[31:24];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[39:32]);
      tx_wdata = romcode[39:32];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[47:40]);
      tx_wdata = romcode[47:40];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[55:48]);
      tx_wdata = romcode[55:48];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = tx_bytes + 8'h01;
      //WRITE_ONE_BYTE(romcode[63:56]);
      tx_wdata = romcode[63:56];
      for (i=0; i<8; i=i+1) begin
         dat = tx_wdata[i];
         if (dat) begin
            if (i & 1) begin
               WRITE_1_SLOT_MAX;
            end else begin
               WRITE_1_SLOT_MIN;
            end
         end else begin
            if (i & 1) begin
               WRITE_0_SLOT_MAX;
            end else begin
               WRITE_0_SLOT_MIN;
            end
         end
         repeat(1) #(RECOVERYMIN*1000);
         tx_bits = tx_bits + 8'h01;
      end
      repeat(1) #(RECOVERYMIN*1000);
      tx_bytes = 8'bzzzz_zzzz;
      tx_bits  = 8'bzzzz_zzzz;
      tx_wdata = 8'bzzzz_zzzz;
      tx_rdatt = 8'bzzzz_zzzz;
      tx_rdatf = 8'bzzzz_zzzz;
      repeat(1000) #(RECOVERYMIN*1000);

      //---------------------------------------------------------------
      $display("simulation stop -at- here");
      //---------------------------------------------------------------
      repeat(1000) #(RECOVERYMIN*1000);
      $finish(0);
      /* 
       * $shm_close;
       */
   end // initial begin

endmodule // tb_onewire
