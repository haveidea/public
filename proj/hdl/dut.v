`include "dut_define.vh"
module dut(
  inout DQ
);
   parameter    CLK2M4PERIOD   = `CLK2M4PERIOD   ; //ns
   parameter    CLK2M4RATIO    = `CLK2M4RATIO    ;
   parameter    CLK2M4DUTY     = `CLK2M4DUTY     ;
   parameter    CLK300PERIOD   = `CLK300PERIOD   ; //ns
   parameter    CLK300RATIO    = `CLK300RATIO    ;
   parameter    CLK300DUTY     = `CLK300DUTY     ;
   parameter    PRESENCEMIN    = `PRESENCEMIN    ; //us
   parameter    PRESENCEMAX    = `PRESENCEMAX    ; //us
   parameter    CELSIUS0DEG    = `CELSIUS0DEG    ; //Celsius degree

   wire                       sys_clk2m4;   // clock 2.4MHz
   wire                       sys_clk300;   // clock 300KHz
   wire                       sys_resetn;   // resetn 0:reset
   reg                        sys_standby;  // standby
   wire                       onewire_ctok; // ConvertT done
   wire                       onewire_crok; // CopyReg done
   wire                       onewire_reok; // Recall EEPROM done
   wire                        onewire_ppm;  // parasite power mode
   reg [63:0]                 romcode;
   wire [7:0]                  owam_byte5;   // byte5
   wire [7:0]                  owam_byte6;   // byte6
   wire [7:0]                  owam_byte7;   // byte7
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
   wire [15:0]                 onewire_temp;   // 16-bit temperature
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
   owpad                    owpad_inst
     (
      // inout
      .__dq__               (DQ),
      // output
      .dq_in                (onewire_dqin),
      // input
      .dq_out               (onewire_dqout),
      .dq_ena               (onewire_dqena)
      );
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

  conf_dummy u_conf_dummy(
    .owam_byte5 (owam_byte5),
    .owam_byte6 (owam_byte6),
    .owam_byte7 (owam_byte7),
    .onewire_crok(onewire_crok),
    .onewire_ctok(onewire_ctok),
    .onewire_reok(onewire_reok),
    .onewire_ppm(onewire_ppm),
    .onewire_temp(onewire_temp),
    .onewire_ttrim(onewire_ttrim)
  );

endmodule
