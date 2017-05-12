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
// File name            : onewire_adapter.v
// File contents        : Module One-Wire-Bus Adapter
// Purpose              : Realization One-wire protocol/1-wire subset
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
module onewire_adapter(
   clk_2m4,                   // 2.4MHz clock
   clk_300,                   // 300KHz clock
   owpo_rstn,                 // poweron resetn, 0:in effect
   owwu_rstn,                 // wakeup resetn, 0:in effect
   owam_ppm,                  // adapter parasite power mode
   owam_ctok,                 // adapter ConvertT done
   owam_temp,                 // adapter 16-bit temperature
   owam_crok,                 // adapter CopyReg done
   owam_reok,                 // adapter Recall done
   dq_in,                     // DQ input
  `ifdef MONO
  `else
   owam_romcode,              // romcode[63:0] register
   owam_tha,                  // tha[7:0] register
   owam_tla,                  // tla[7:0] register
   owam_cfg,                  // cfg[7:0] register
  `endif
   owam_byte5,                // byte5[7:0] register
   owam_byte6,                // byte6[7:0] register
   owam_byte7,                // byte7[7:0] register
  `ifdef DTT
   owam_ttrim,                // 16-bit timing adjust register
  `endif
  `ifdef MONO
  `else
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
  `endif
   owam_copyreg,              // adapter issue CopyReg
   owam_recall,               // adapter issue Recall EEPROM
   owam_convert,              // adapter issue ConvertT
   dq_out,                    // DQ output
   dq_ena                     // DQ enable
   );

   `include "onewire_params.v"

   input                      clk_2m4;      // 2.4MHz clock
   input                      clk_300;      // 300KHz clock
   input                      owpo_rstn;    // poweron resetn, 0:ef
   input                      owwu_rstn;    // wakeup resetn, 0:ef
   input                      owam_ppm;     // parasite power mode:
                                            // 1=VDD,0=PPM
   input                      owam_ctok;    // ConvertT done
   input [15:0]               owam_temp;    // 16-bit temperature
   input                      dq_in;        // DQ input
   input                      owam_crok;    // CopyReg done
   input                      owam_reok;    // Recall done
  `ifdef MONO
  `else
   input [63:0]               owam_romcode; // romcode[63:0] reg
   input [7:0]                owam_tha;     // tha[7:0] reg
   input [7:0]                owam_tla;     // tla[7:0] reg
   input [7:0]                owam_cfg;     // cfg[7:0] reg
  `endif
   input [7:0]                owam_byte5;   // byte5 reg
   input [7:0]                owam_byte6;   // byte6 reg
   input [7:0]                owam_byte7;   // byte7 reg
  `ifdef DTT
   input [15:0]               owam_ttrim;   // 16-bit timing adjust
  `endif
   //------------------------------------------------------------------
  `ifdef MONO
  `else
   output                     owam_rc0_we;  // romcode[7:0]   wr en
   output                     owam_rc1_we;  // romcode[15:8]  wr en
   output                     owam_rc2_we;  // romcode[23:16] wr en
   output                     owam_rc3_we;  // romcode[31:24] wr en
   output                     owam_rc4_we;  // romcode[39:32] wr en
   output                     owam_rc5_we;  // romcode[47:40] wr en
   output                     owam_rc6_we;  // romcode[55:48] wr en
   output                     owam_rc7_we;  // romcode[63:56] wr en
   output                     owam_tha_we;  // tha[7:0] reg   wr en
   output                     owam_tla_we;  // tla[7:0] reg   wr en
   output                     owam_cfg_we;  // cfg[7:0] reg   wr en
   output [7:0]               owam_databus; // wr reg 8-bit data bus
  `endif
   output                     owam_copyreg; // issue CopyReg
   output                     owam_recall;  // issue Recall
   output                     owam_convert; // issue ConvertT
   output                     dq_out;       // DQ output
   output                     dq_ena;       // DQ enable

   //-- module input signals --
   wire [15:0]                owam_temp;    // 16-bit temperature
  `ifdef MONO
  `else
   wire [63:0]                owam_romcode; // romcode[63:0] reg
   wire [7:0]                 owam_tha;     // tha[7:0] reg
   wire [7:0]                 owam_tla;     // tla[7:0] reg
   wire [7:0]                 owam_cfg;     // cfg[7:0] reg
  `endif
   wire [7:0]                 owam_byte5;   // byte5 reg
   wire [7:0]                 owam_byte6;   // byte6 reg
   wire [7:0]                 owam_byte7;   // byte7 reg
  `ifdef DTT
   wire [15:0]                owam_ttrim;   // 16-bit timing adjust
  `endif

   //-- module output signals --
  `ifdef MONO
  `else
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
  `endif
   wire                       owam_convert; // issue ConvertT
   wire                       owam_copyreg; // issue CopyReg
   wire                       owam_recall;  // issue Recall
   wire                       dq_out;
   wire                       dq_ena;

   //-- edge detector signals --
   reg                        reg_dq_1;
   reg                        reg_dq_2;
   wire                       det_pos;
   wire                       det_neg;

   //------------------------------------------------------------------
   reg                        reg_ctok_1; // ConvertT done
   reg                        reg_ctok_2;
   reg                        reg_ctov;
   reg                        reg_convert;
   reg                        reg_crok_1; // CopyReg done
   reg                        reg_crok_2;
   reg                        reg_crov;
   reg                        reg_copyreg;
   reg                        reg_reok_1; // Recall EEPROM done
   reg                        reg_reok_2;
   reg                        reg_reov;
   reg                        reg_recall;
   reg                        reg_ppm;  // parasite power mode
   wire                       ctok_pos;
   wire                       ctok_neg;
   wire                       ctok_set;
   wire                       ctok_clr;
   wire                       ctov_set;
   wire                       ctov_end;
   wire                       crok_pos;
   wire                       crok_neg;
   wire                       crok_set;
   wire                       crok_clr;
   wire                       crov_set;
   wire                       crov_end;
   wire                       reok_pos;
   wire                       reok_neg;
   wire                       reok_set;
   wire                       reok_clr;
   wire                       reov_set;
   wire                       reov_end;

   //-- flow machine signals --
   reg [XFLOWWIDTH-1:0]       reg_xflow, nxt_xflow;
   reg [XFCNTWIDTH-1:0]       reg_xfcnt, bit_expect;
   wire                       phase_owlp; // low power
   wire                       phase_owrp; // reset pulse
   wire                       phase_owwf; // wait for
   wire                       phase_owpp; // presence pulse
   wire                       phase_owrc; // rom command
   wire                       phase_owfc; // function command
   wire                       phase_ownm; // no match
   wire                       owrp_end;   // reset pulse end
   wire                       owwf_end;   // wait for 32us end
   wire                       owpp_end;   // presence pulse 110us end
   wire                       owrc_end;   // rom command end
   wire                       owrc_miss;  // rom code miss
   wire                       owrc_case;  // two miss case
   wire                       owrc_over;  // only rom command
   wire                       owfc_end;   // function command end
   wire                       owfc_mrst;  // master tx reset
   wire                       ownm_mrst;  // no match tx reset
   wire                       xfcnt_rst;  // reset rxtx bit counter
   wire                       xfcnt_ena;  // enable rxtx bit counter
   wire                       xfcnt_hld;  // hold rxtx bit counter
   wire                       rcsr_end;   // Search ROM end
   wire                       rcrr_end;   // Read ROM end
   wire                       rcmr_end;   // Match ROM end
   wire                       rckr_end;   // Skip ROM end
   wire                       rcas_end;   // Alarm Search end
   wire                       rcsm_end;   // Setup ROM end
   wire                       fcct_end;   // Convert T end
   wire                       fcwr_end;   // Write Register end
   wire                       fcrr_end;   // Read Register end
   wire                       fccr_end;   // Copy Register end
   wire                       fcre_end;   // Recall EEPROM end
   wire                       rppm_end;   // Read PPM end

   //-- timeslot machine signals --
   reg [TSLOTWIDTH-1:0]       reg_tslot, nxt_tslot;
   reg [TSCNTWIDTH-1:0]       reg_tscnt;
   wire                       rythm_idle; // timeslot idle
   wire                       rythm_actv; // timeslot start
   wire                       rythm_init; // timing initial
   wire                       rythm_pull; // pulling rhythm
   wire                       rythm_rena; // renascence slot
   wire                       rythm_samp; // samples rhythm
   wire                       rythm_tail; // length slot
   wire                       rythm_miss; // nomatch rhythm
   wire                       pulse_sank; // sankhara gap
   wire                       pulse_anat; // anatta gap
   wire                       pulse_nirv; // nirvana gap
   wire                       xflow_init; // initial sequence
   wire                       pull_proc;  // process cycle when pulling
   wire                       pull_fix;   // pulling for dqout=1
   wire                       init_end;   // initial end
   wire                       pull_end;   // pulling end
   wire                       rena_end;   // renascence end
   wire                       samp_end;   // samples end
   wire                       tail_end;   // length-slot end
   wire                       miss_end;   // nomatch end
   wire                       tscnt_rst;  // reset timeslot counter
   wire                       tscnt_clr;  // clear timeslot counter
   wire                       tscnt_samp; // clear when samples
   wire                       tscnt_ena;  // enable timeslot counter
   wire                       tscnt_ini;  // initial pulse
   wire                       tscnt_cmm;  // rom/func command
   wire                       tscnt_miss; // no match
   wire                       tscnt_rena; // flow renascence
   wire                       tscnt_reld; // nirvana reload

   //------------------------------------------------------------------
  `ifdef DTT
   //TTRIM[3:0]
   reg [TSCNTWIDTH-1:0]       ttrim_pdhigh; // Presence-Detect High
   reg [TSCNTWIDTH-1:0]       ttrim_pdlow;  // Presence-Detect Low
   //TTRIM[7:4]
   reg [TSCNTWIDTH-1:0]       ttrim_rpldet; // Reset-pulse Low Detect
   //TTRIM[11:8]
   reg [TSCNTWIDTH-1:0]       ttrim_phproc; // Pulling High Process
   reg [TSCNTWIDTH-1:0]       ttrim_rphigh; // Read-data Pulling High
   reg [TSCNTWIDTH-1:0]       ttrim_nphigh; // Nirvana Pulling High
   reg [TSCNTWIDTH-1:0]       ttrim_plproc; // Pulling Low Process
   reg [TSCNTWIDTH-1:0]       ttrim_rplow;  // Read-data Pulling Low
   reg [TSCNTWIDTH-1:0]       ttrim_nplow;  // Nirvana Pulling Low
   //TTRIM[15:12]
   reg [TSCNTWIDTH-1:0]       ttrim_swtick; // Sample Window Tick
   reg [TSCNTWIDTH-1:0]       ttrim_sdproc; // Sample Datum Process
   reg [TSCNTWIDTH-1:0]       ttrim_spkarm; // Sample Process Karma
  `endif

   //-- datapath & register signals --
   reg [7:0]                  reg_comm, reg_fetch;
   wire                       comm_fth; // fetch command register
   wire                       comm_rst; // reset command register
   wire                       comm_clr; // clear command register
  `ifdef MONO
   reg [63:0]                 reg_romcode;
   reg [7:0]                  reg_th, reg_tl;
   reg [7:0]                  reg_config;
   wire                       rst_romcode; // romcode register
   wire                       ena_romcode; // romcode register
   wire                       rst_th; // reset high alarm trigger
   wire                       ena_th; // enable high alarm trigger
   wire                       rst_tl; // reset low alarm trigger
   wire                       ena_tl; // enable low alarm trigger
   wire                       rst_config; // reset config register
   wire                       ena_config; // enable config register
   wire                       comm_ena; // enable command register
  `else
   wire                       fetch_rst; // reset data fetch
   wire                       fetch_ena; // enable data fetch
   wire                       fetch_0;   // fetch data
   wire                       fetch_1;   // fetch data
   wire                       fetch_2;   // fetch data
   wire                       fetch_3;   // fetch data
   wire                       fetch_4;   // fetch data
   wire                       fetch_5;   // fetch data
   wire                       fetch_6;   // fetch data
   wire                       fetch_7;   // fetch data
   wire                       romcrc_cyc; // romcrc load cycle
   wire                       romcrc_fix; // romcrc error fix
  `endif
   wire                       samp_wind;  // sample window
   wire                       samp_latch; // sample latch
   wire                       samp_comm_0; // sample command
   wire                       samp_comm_1; // sample command
   wire                       samp_comm_2; // sample command
   wire                       samp_comm_3; // sample command
   wire                       samp_comm_4; // sample command
   wire                       samp_comm_5; // sample command
   wire                       samp_comm_6; // sample command
   wire                       samp_comm_7; // sample command

   //------------------------------------------------------------------
  `ifdef MONO
   wire                       samp_urom_00; // sample romcode
   wire                       samp_urom_01; // sample romcode
   wire                       samp_urom_02; // sample romcode
   wire                       samp_urom_03; // sample romcode
   wire                       samp_urom_04; // sample romcode
   wire                       samp_urom_05; // sample romcode
   wire                       samp_urom_06; // sample romcode
   wire                       samp_urom_07; // sample romcode
   wire                       samp_urom_08; // sample romcode
   wire                       samp_urom_09; // sample romcode
   wire                       samp_urom_10; // sample romcode
   wire                       samp_urom_11; // sample romcode
   wire                       samp_urom_12; // sample romcode
   wire                       samp_urom_13; // sample romcode
   wire                       samp_urom_14; // sample romcode
   wire                       samp_urom_15; // sample romcode
   wire                       samp_urom_16; // sample romcode
   wire                       samp_urom_17; // sample romcode
   wire                       samp_urom_18; // sample romcode
   wire                       samp_urom_19; // sample romcode
   wire                       samp_urom_20; // sample romcode
   wire                       samp_urom_21; // sample romcode
   wire                       samp_urom_22; // sample romcode
   wire                       samp_urom_23; // sample romcode
   wire                       samp_urom_24; // sample romcode
   wire                       samp_urom_25; // sample romcode
   wire                       samp_urom_26; // sample romcode
   wire                       samp_urom_27; // sample romcode
   wire                       samp_urom_28; // sample romcode
   wire                       samp_urom_29; // sample romcode
   wire                       samp_urom_30; // sample romcode
   wire                       samp_urom_31; // sample romcode
   wire                       samp_urom_32; // sample romcode
   wire                       samp_urom_33; // sample romcode
   wire                       samp_urom_34; // sample romcode
   wire                       samp_urom_35; // sample romcode
   wire                       samp_urom_36; // sample romcode
   wire                       samp_urom_37; // sample romcode
   wire                       samp_urom_38; // sample romcode
   wire                       samp_urom_39; // sample romcode
   wire                       samp_urom_40; // sample romcode
   wire                       samp_urom_41; // sample romcode
   wire                       samp_urom_42; // sample romcode
   wire                       samp_urom_43; // sample romcode
   wire                       samp_urom_44; // sample romcode
   wire                       samp_urom_45; // sample romcode
   wire                       samp_urom_46; // sample romcode
   wire                       samp_urom_47; // sample romcode
   wire                       samp_urom_48; // sample romcode
   wire                       samp_urom_49; // sample romcode
   wire                       samp_urom_50; // sample romcode
   wire                       samp_urom_51; // sample romcode
   wire                       samp_urom_52; // sample romcode
   wire                       samp_urom_53; // sample romcode
   wire                       samp_urom_54; // sample romcode
   wire                       samp_urom_55; // sample romcode
   wire                       samp_urom_56; // sample romcode
   wire                       samp_urom_57; // sample romcode
   wire                       samp_urom_58; // sample romcode
   wire                       samp_urom_59; // sample romcode
   wire                       samp_urom_60; // sample romcode
   wire                       samp_urom_61; // sample romcode
   wire                       samp_urom_62; // sample romcode
   wire                       samp_urom_63; // sample romcode
  `endif

   //------------------------------------------------------------------
  `ifdef MONO
   wire                       samp_th_0; // sample high alarm-trigger
   wire                       samp_th_1; // sample high alarm-trigger
   wire                       samp_th_2; // sample high alarm-trigger
   wire                       samp_th_3; // sample high alarm-trigger
   wire                       samp_th_4; // sample high alarm-trigger
   wire                       samp_th_5; // sample high alarm-trigger
   wire                       samp_th_6; // sample high alarm-trigger
   wire                       samp_th_7; // sample high alarm-trigger
   wire                       samp_tl_0; // sample low alarm-trigger
   wire                       samp_tl_1; // sample low alarm-trigger
   wire                       samp_tl_2; // sample low alarm-trigger
   wire                       samp_tl_3; // sample low alarm-trigger
   wire                       samp_tl_4; // sample low alarm-trigger
   wire                       samp_tl_5; // sample low alarm-trigger
   wire                       samp_tl_6; // sample low alarm-trigger
   wire                       samp_tl_7; // sample low alarm-trigger
   wire                       samp_cfg_0; // sample config register
   wire                       samp_cfg_1; // sample config register
   wire                       samp_cfg_2; // sample config register
   wire                       samp_cfg_3; // sample config register
   wire                       samp_cfg_4; // sample config register
   wire                       samp_cfg_5; // sample config register
   wire                       samp_cfg_6; // sample config register
   wire                       samp_cfg_7; // sample config register
  `endif

   //------------------------------------------------------------------
   wire                       phase_rcsr; // Search ROM
   wire                       phase_rcrr; // Read ROM
   wire                       phase_rcmr; // Match ROM
   wire                       phase_rckr; // Skip ROM
   wire                       phase_rcas; // Alarm Search
   wire                       phase_rcsm; // Setup ROM
   wire                       phase_fcct; // Convert T
   wire                       phase_fcwr; // Write Register
   wire                       phase_fcrr; // Read Register
   wire                       phase_fccr; // Copy Register
   wire                       phase_fcre; // Recall EEPROM
   wire                       phase_rppm; // Read PPM
   wire                       phase_alarm; // Alarm

   //------------------------------------------------------------------
   wire                       smrom_00; // setuprom cycle
   wire                       smrom_01; // setuprom cycle
   wire                       smrom_02; // setuprom cycle
   wire                       smrom_03; // setuprom cycle
   wire                       smrom_04; // setuprom cycle
   wire                       smrom_05; // setuprom cycle
   wire                       smrom_06; // setuprom cycle
   wire                       smrom_07; // setuprom cycle
   wire                       smrom_08; // setuprom cycle
   wire                       smrom_09; // setuprom cycle
   wire                       smrom_10; // setuprom cycle
   wire                       smrom_11; // setuprom cycle
   wire                       smrom_12; // setuprom cycle
   wire                       smrom_13; // setuprom cycle
   wire                       smrom_14; // setuprom cycle
   wire                       smrom_15; // setuprom cycle
   wire                       smrom_16; // setuprom cycle
   wire                       smrom_17; // setuprom cycle
   wire                       smrom_18; // setuprom cycle
   wire                       smrom_19; // setuprom cycle
   wire                       smrom_20; // setuprom cycle
   wire                       smrom_21; // setuprom cycle
   wire                       smrom_22; // setuprom cycle
   wire                       smrom_23; // setuprom cycle
   wire                       smrom_24; // setuprom cycle
   wire                       smrom_25; // setuprom cycle
   wire                       smrom_26; // setuprom cycle
   wire                       smrom_27; // setuprom cycle
   wire                       smrom_28; // setuprom cycle
   wire                       smrom_29; // setuprom cycle
   wire                       smrom_30; // setuprom cycle
   wire                       smrom_31; // setuprom cycle
   wire                       smrom_32; // setuprom cycle
   wire                       smrom_33; // setuprom cycle
   wire                       smrom_34; // setuprom cycle
   wire                       smrom_35; // setuprom cycle
   wire                       smrom_36; // setuprom cycle
   wire                       smrom_37; // setuprom cycle
   wire                       smrom_38; // setuprom cycle
   wire                       smrom_39; // setuprom cycle
   wire                       smrom_40; // setuprom cycle
   wire                       smrom_41; // setuprom cycle
   wire                       smrom_42; // setuprom cycle
   wire                       smrom_43; // setuprom cycle
   wire                       smrom_44; // setuprom cycle
   wire                       smrom_45; // setuprom cycle
   wire                       smrom_46; // setuprom cycle
   wire                       smrom_47; // setuprom cycle
   wire                       smrom_48; // setuprom cycle
   wire                       smrom_49; // setuprom cycle
   wire                       smrom_50; // setuprom cycle
   wire                       smrom_51; // setuprom cycle
   wire                       smrom_52; // setuprom cycle
   wire                       smrom_53; // setuprom cycle
   wire                       smrom_54; // setuprom cycle
   wire                       smrom_55; // setuprom cycle
   wire                       smrom_56; // setuprom cycle
   wire                       smrom_57; // setuprom cycle
   wire                       smrom_58; // setuprom cycle
   wire                       smrom_59; // setuprom cycle
   wire                       smrom_60; // setuprom cycle
   wire                       smrom_61; // setuprom cycle
   wire                       smrom_62; // setuprom cycle
   wire                       smrom_63; // setuprom cycle

   //-- unique 64bit code identify signals --
   reg                        reg_rcmiss;
   reg                        reg_alarm;
   wire                       rcmiss_rst;
   wire                       rcmiss_ena;
   wire                       rcmiss_clr;
   wire                       rcmiss_set;
   wire                       rcmiss_rom;
   wire                       rcmiss_alarm;
   wire                       search_ena;
   wire                       flag_tha;
   wire                       flag_tla;
   wire                       owam_alarm;
   wire                       alarm_rst;
   wire                       alarm_ena;

   //------------------------------------------------------------------
   wire                       mrrom_00; // matchrom cycle
   wire                       mrrom_01; // matchrom cycle
   wire                       mrrom_02; // matchrom cycle
   wire                       mrrom_03; // matchrom cycle
   wire                       mrrom_04; // matchrom cycle
   wire                       mrrom_05; // matchrom cycle
   wire                       mrrom_06; // matchrom cycle
   wire                       mrrom_07; // matchrom cycle
   wire                       mrrom_08; // matchrom cycle
   wire                       mrrom_09; // matchrom cycle
   wire                       mrrom_10; // matchrom cycle
   wire                       mrrom_11; // matchrom cycle
   wire                       mrrom_12; // matchrom cycle
   wire                       mrrom_13; // matchrom cycle
   wire                       mrrom_14; // matchrom cycle
   wire                       mrrom_15; // matchrom cycle
   wire                       mrrom_16; // matchrom cycle
   wire                       mrrom_17; // matchrom cycle
   wire                       mrrom_18; // matchrom cycle
   wire                       mrrom_19; // matchrom cycle
   wire                       mrrom_20; // matchrom cycle
   wire                       mrrom_21; // matchrom cycle
   wire                       mrrom_22; // matchrom cycle
   wire                       mrrom_23; // matchrom cycle
   wire                       mrrom_24; // matchrom cycle
   wire                       mrrom_25; // matchrom cycle
   wire                       mrrom_26; // matchrom cycle
   wire                       mrrom_27; // matchrom cycle
   wire                       mrrom_28; // matchrom cycle
   wire                       mrrom_29; // matchrom cycle
   wire                       mrrom_30; // matchrom cycle
   wire                       mrrom_31; // matchrom cycle
   wire                       mrrom_32; // matchrom cycle
   wire                       mrrom_33; // matchrom cycle
   wire                       mrrom_34; // matchrom cycle
   wire                       mrrom_35; // matchrom cycle
   wire                       mrrom_36; // matchrom cycle
   wire                       mrrom_37; // matchrom cycle
   wire                       mrrom_38; // matchrom cycle
   wire                       mrrom_39; // matchrom cycle
   wire                       mrrom_40; // matchrom cycle
   wire                       mrrom_41; // matchrom cycle
   wire                       mrrom_42; // matchrom cycle
   wire                       mrrom_43; // matchrom cycle
   wire                       mrrom_44; // matchrom cycle
   wire                       mrrom_45; // matchrom cycle
   wire                       mrrom_46; // matchrom cycle
   wire                       mrrom_47; // matchrom cycle
   wire                       mrrom_48; // matchrom cycle
   wire                       mrrom_49; // matchrom cycle
   wire                       mrrom_50; // matchrom cycle
   wire                       mrrom_51; // matchrom cycle
   wire                       mrrom_52; // matchrom cycle
   wire                       mrrom_53; // matchrom cycle
   wire                       mrrom_54; // matchrom cycle
   wire                       mrrom_55; // matchrom cycle
   wire                       mrrom_56; // matchrom cycle
   wire                       mrrom_57; // matchrom cycle
   wire                       mrrom_58; // matchrom cycle
   wire                       mrrom_59; // matchrom cycle
   wire                       mrrom_60; // matchrom cycle
   wire                       mrrom_61; // matchrom cycle
   wire                       mrrom_62; // matchrom cycle
   wire                       mrrom_63; // matchrom cycle

   //------------------------------------------------------------------
   wire                       skrom_00; // searchrom cycle
   wire                       skrom_01; // searchrom cycle
   wire                       skrom_02; // searchrom cycle
   wire                       skrom_03; // searchrom cycle
   wire                       skrom_04; // searchrom cycle
   wire                       skrom_05; // searchrom cycle
   wire                       skrom_06; // searchrom cycle
   wire                       skrom_07; // searchrom cycle
   wire                       skrom_08; // searchrom cycle
   wire                       skrom_09; // searchrom cycle
   wire                       skrom_10; // searchrom cycle
   wire                       skrom_11; // searchrom cycle
   wire                       skrom_12; // searchrom cycle
   wire                       skrom_13; // searchrom cycle
   wire                       skrom_14; // searchrom cycle
   wire                       skrom_15; // searchrom cycle
   wire                       skrom_16; // searchrom cycle
   wire                       skrom_17; // searchrom cycle
   wire                       skrom_18; // searchrom cycle
   wire                       skrom_19; // searchrom cycle
   wire                       skrom_20; // searchrom cycle
   wire                       skrom_21; // searchrom cycle
   wire                       skrom_22; // searchrom cycle
   wire                       skrom_23; // searchrom cycle
   wire                       skrom_24; // searchrom cycle
   wire                       skrom_25; // searchrom cycle
   wire                       skrom_26; // searchrom cycle
   wire                       skrom_27; // searchrom cycle
   wire                       skrom_28; // searchrom cycle
   wire                       skrom_29; // searchrom cycle
   wire                       skrom_30; // searchrom cycle
   wire                       skrom_31; // searchrom cycle
   wire                       skrom_32; // searchrom cycle
   wire                       skrom_33; // searchrom cycle
   wire                       skrom_34; // searchrom cycle
   wire                       skrom_35; // searchrom cycle
   wire                       skrom_36; // searchrom cycle
   wire                       skrom_37; // searchrom cycle
   wire                       skrom_38; // searchrom cycle
   wire                       skrom_39; // searchrom cycle
   wire                       skrom_40; // searchrom cycle
   wire                       skrom_41; // searchrom cycle
   wire                       skrom_42; // searchrom cycle
   wire                       skrom_43; // searchrom cycle
   wire                       skrom_44; // searchrom cycle
   wire                       skrom_45; // searchrom cycle
   wire                       skrom_46; // searchrom cycle
   wire                       skrom_47; // searchrom cycle
   wire                       skrom_48; // searchrom cycle
   wire                       skrom_49; // searchrom cycle
   wire                       skrom_50; // searchrom cycle
   wire                       skrom_51; // searchrom cycle
   wire                       skrom_52; // searchrom cycle
   wire                       skrom_53; // searchrom cycle
   wire                       skrom_54; // searchrom cycle
   wire                       skrom_55; // searchrom cycle
   wire                       skrom_56; // searchrom cycle
   wire                       skrom_57; // searchrom cycle
   wire                       skrom_58; // searchrom cycle
   wire                       skrom_59; // searchrom cycle
   wire                       skrom_60; // searchrom cycle
   wire                       skrom_61; // searchrom cycle
   wire                       skrom_62; // searchrom cycle
   wire                       skrom_63; // searchrom cycle

   //------------------------------------------------------------------
   wire                       urcyc_00; // compare romcode cycle
   wire                       urcyc_01; // compare romcode cycle
   wire                       urcyc_02; // compare romcode cycle
   wire                       urcyc_03; // compare romcode cycle
   wire                       urcyc_04; // compare romcode cycle
   wire                       urcyc_05; // compare romcode cycle
   wire                       urcyc_06; // compare romcode cycle
   wire                       urcyc_07; // compare romcode cycle
   wire                       urcyc_08; // compare romcode cycle
   wire                       urcyc_09; // compare romcode cycle
   wire                       urcyc_10; // compare romcode cycle
   wire                       urcyc_11; // compare romcode cycle
   wire                       urcyc_12; // compare romcode cycle
   wire                       urcyc_13; // compare romcode cycle
   wire                       urcyc_14; // compare romcode cycle
   wire                       urcyc_15; // compare romcode cycle
   wire                       urcyc_16; // compare romcode cycle
   wire                       urcyc_17; // compare romcode cycle
   wire                       urcyc_18; // compare romcode cycle
   wire                       urcyc_19; // compare romcode cycle
   wire                       urcyc_20; // compare romcode cycle
   wire                       urcyc_21; // compare romcode cycle
   wire                       urcyc_22; // compare romcode cycle
   wire                       urcyc_23; // compare romcode cycle
   wire                       urcyc_24; // compare romcode cycle
   wire                       urcyc_25; // compare romcode cycle
   wire                       urcyc_26; // compare romcode cycle
   wire                       urcyc_27; // compare romcode cycle
   wire                       urcyc_28; // compare romcode cycle
   wire                       urcyc_29; // compare romcode cycle
   wire                       urcyc_30; // compare romcode cycle
   wire                       urcyc_31; // compare romcode cycle
   wire                       urcyc_32; // compare romcode cycle
   wire                       urcyc_33; // compare romcode cycle
   wire                       urcyc_34; // compare romcode cycle
   wire                       urcyc_35; // compare romcode cycle
   wire                       urcyc_36; // compare romcode cycle
   wire                       urcyc_37; // compare romcode cycle
   wire                       urcyc_38; // compare romcode cycle
   wire                       urcyc_39; // compare romcode cycle
   wire                       urcyc_40; // compare romcode cycle
   wire                       urcyc_41; // compare romcode cycle
   wire                       urcyc_42; // compare romcode cycle
   wire                       urcyc_43; // compare romcode cycle
   wire                       urcyc_44; // compare romcode cycle
   wire                       urcyc_45; // compare romcode cycle
   wire                       urcyc_46; // compare romcode cycle
   wire                       urcyc_47; // compare romcode cycle
   wire                       urcyc_48; // compare romcode cycle
   wire                       urcyc_49; // compare romcode cycle
   wire                       urcyc_50; // compare romcode cycle
   wire                       urcyc_51; // compare romcode cycle
   wire                       urcyc_52; // compare romcode cycle
   wire                       urcyc_53; // compare romcode cycle
   wire                       urcyc_54; // compare romcode cycle
   wire                       urcyc_55; // compare romcode cycle
   wire                       urcyc_56; // compare romcode cycle
   wire                       urcyc_57; // compare romcode cycle
   wire                       urcyc_58; // compare romcode cycle
   wire                       urcyc_59; // compare romcode cycle
   wire                       urcyc_60; // compare romcode cycle
   wire                       urcyc_61; // compare romcode cycle
   wire                       urcyc_62; // compare romcode cycle
   wire                       urcyc_63; // compare romcode cycle

   //------------------------------------------------------------------
   wire                       rcmiss_00; // romcode nomatch
   wire                       rcmiss_01; // romcode nomatch
   wire                       rcmiss_02; // romcode nomatch
   wire                       rcmiss_03; // romcode nomatch
   wire                       rcmiss_04; // romcode nomatch
   wire                       rcmiss_05; // romcode nomatch
   wire                       rcmiss_06; // romcode nomatch
   wire                       rcmiss_07; // romcode nomatch
   wire                       rcmiss_08; // romcode nomatch
   wire                       rcmiss_09; // romcode nomatch
   wire                       rcmiss_10; // romcode nomatch
   wire                       rcmiss_11; // romcode nomatch
   wire                       rcmiss_12; // romcode nomatch
   wire                       rcmiss_13; // romcode nomatch
   wire                       rcmiss_14; // romcode nomatch
   wire                       rcmiss_15; // romcode nomatch
   wire                       rcmiss_16; // romcode nomatch
   wire                       rcmiss_17; // romcode nomatch
   wire                       rcmiss_18; // romcode nomatch
   wire                       rcmiss_19; // romcode nomatch
   wire                       rcmiss_20; // romcode nomatch
   wire                       rcmiss_21; // romcode nomatch
   wire                       rcmiss_22; // romcode nomatch
   wire                       rcmiss_23; // romcode nomatch
   wire                       rcmiss_24; // romcode nomatch
   wire                       rcmiss_25; // romcode nomatch
   wire                       rcmiss_26; // romcode nomatch
   wire                       rcmiss_27; // romcode nomatch
   wire                       rcmiss_28; // romcode nomatch
   wire                       rcmiss_29; // romcode nomatch
   wire                       rcmiss_30; // romcode nomatch
   wire                       rcmiss_31; // romcode nomatch
   wire                       rcmiss_32; // romcode nomatch
   wire                       rcmiss_33; // romcode nomatch
   wire                       rcmiss_34; // romcode nomatch
   wire                       rcmiss_35; // romcode nomatch
   wire                       rcmiss_36; // romcode nomatch
   wire                       rcmiss_37; // romcode nomatch
   wire                       rcmiss_38; // romcode nomatch
   wire                       rcmiss_39; // romcode nomatch
   wire                       rcmiss_40; // romcode nomatch
   wire                       rcmiss_41; // romcode nomatch
   wire                       rcmiss_42; // romcode nomatch
   wire                       rcmiss_43; // romcode nomatch
   wire                       rcmiss_44; // romcode nomatch
   wire                       rcmiss_45; // romcode nomatch
   wire                       rcmiss_46; // romcode nomatch
   wire                       rcmiss_47; // romcode nomatch
   wire                       rcmiss_48; // romcode nomatch
   wire                       rcmiss_49; // romcode nomatch
   wire                       rcmiss_50; // romcode nomatch
   wire                       rcmiss_51; // romcode nomatch
   wire                       rcmiss_52; // romcode nomatch
   wire                       rcmiss_53; // romcode nomatch
   wire                       rcmiss_54; // romcode nomatch
   wire                       rcmiss_55; // romcode nomatch
   wire                       rcmiss_56; // romcode nomatch
   wire                       rcmiss_57; // romcode nomatch
   wire                       rcmiss_58; // romcode nomatch
   wire                       rcmiss_59; // romcode nomatch
   wire                       rcmiss_60; // romcode nomatch
   wire                       rcmiss_61; // romcode nomatch
   wire                       rcmiss_62; // romcode nomatch
   wire                       rcmiss_63; // romcode nomatch

   //-- cyclic redundancy check signals --
   reg [7:0]                  reg_crc, dat_crc;
   reg [7:0]                  reg_crcreg;
   reg                        reg_crcerr;
   wire                       crc_fsncyc;
   wire                       crc_smcyc;
   wire                       crcerr_rst;
   wire                       crcerr_ena;
   wire                       crcerr_clr;
   wire                       crcerr_cyc;
   wire                       crc_err;
   wire                       crc_din;
   wire                       crc_ena;
   wire                       crc_rst;
   wire                       crc_clr;
   wire                       crc_lstcyc;
   wire                       crc_fstcyc;
   wire                       crcreg_rst;
   wire                       crcreg_ena;

   //-- dq input/output signals --
   reg                        dat_dqout;
   reg                        reg_dqout;
   reg                        reg_dqena; // 1:read 0:write(default)
  `ifdef MONO
   reg                        reg_dqin;
   wire                       dqin_rst;
   wire                       dqin_ena;
  `endif
   wire                       dqout_put;
   wire                       dqout_rec;
   wire                       dqena_set;
   wire                       dqena_clr;
   wire                       dqena_ena;
   wire                       dqena_owrc;
   wire                       dqena_search;
   wire                       dqena_skcyc;
   wire                       dqena_rdrom;
   wire                       dqena_rmcyc;
   wire                       dqena_owfc;
   wire                       dqena_rdreg;
   wire                       dqena_rgcyc;
   wire                       dqena_convt;
   wire                       dqena_copyr;
   wire                       dqena_rece2;
   wire                       dqena_rdppm;

   //-- edge detector circuit --
   assign det_pos = reg_dq_1 & !reg_dq_2;
   assign det_neg = !reg_dq_1 & reg_dq_2;
   always @(posedge clk_2m4) begin
      reg_dq_1 <= dq_in;
      reg_dq_2 <= reg_dq_1;
      reg_ctok_1 <= owam_ctok; // ConvertT done
      reg_ctok_2 <= reg_ctok_1;
      reg_crok_1 <= owam_crok; // CopyReg done
      reg_crok_2 <= reg_crok_1;
      reg_reok_1 <= owam_reok; // Recall EEPROM done
      reg_reok_2 <= reg_reok_1;
      reg_ppm  <= owam_ppm;  // parasite power mode
   end

   //------------------------------------------------------------------
   assign owam_convert = reg_convert;
   assign ctok_pos = reg_ctok_1 & !reg_ctok_2;
   assign ctok_neg = !reg_ctok_1 & reg_ctok_2;
   assign ctok_set = phase_fcct & tscnt_samp & (reg_xfcnt==COMMCYC7);
   assign ctok_clr = reg_ppm? ctok_pos : reg_ctov;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn) begin
         reg_convert <= 'b0;
      end else begin
         if (ctok_set) begin
            reg_convert <= 'b1;
         end else if (ctok_clr) begin
            reg_convert <= 'b0;
         end
      end
   end

   //------------------------------------------------------------------
   assign ctov_set = ctok_pos;
   assign ctov_end = reg_ppm? (phase_owfc & pull_end & reg_dqout &
                               phase_fcct) : ctok_neg;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn) begin
         reg_ctov <= 'b0;
      end else begin
         if (ctov_set) begin
            reg_ctov <= 'b1;
         end else if (ctov_end) begin
            reg_ctov <= 'b0;
         end
      end
   end

   //------------------------------------------------------------------
   onewire_comparator       owtha_inst
     (
      // input
      .dataa                (owam_temp[11:4]),
     `ifdef MONO
      .datab                (reg_th[7:0]),
     `else
      .datab                (owam_tha[7:0]),
     `endif
      // output
      .a_ge_b               (flag_tha)
      );
   onewire_comparator       owthl_inst
     (
      // input
     `ifdef MONO
      .dataa                (reg_tl[7:0]),
     `else
      .dataa                (owam_tla[7:0]),
     `endif
      .datab                (owam_temp[11:4]),
      // output
      .a_ge_b               (flag_tla)
      );
   assign owam_alarm = flag_tha | flag_tla;
   assign alarm_rst = !owpo_rstn;
   assign alarm_ena = reg_ctov;
   always @(posedge clk_2m4) begin
      if (alarm_rst) begin
         reg_alarm <= 'b0;
      end else if (alarm_ena) begin
         reg_alarm <= owam_alarm;
      end
   end

   //------------------------------------------------------------------
   assign owam_copyreg = reg_copyreg;
   assign crok_pos = reg_crok_1 & !reg_crok_2;
   assign crok_neg = !reg_crok_1 & reg_crok_2;
   assign crok_set = phase_fccr & tscnt_samp & (reg_xfcnt==COMMCYC7);
   assign crok_clr = reg_ppm? crok_pos : reg_crov;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn) begin
         reg_copyreg <= 'b0;
      end else begin
         if (crok_set) begin
            reg_copyreg <= 'b1;
         end else if (crok_clr) begin
            reg_copyreg <= 'b0;
         end
      end
   end

   //------------------------------------------------------------------
   assign crov_set = crok_pos;
   assign crov_end = reg_ppm? (phase_owfc & pull_end & reg_dqout &
                               phase_fccr) : crok_neg;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn) begin
         reg_crov <= 'b0;
      end else begin
         if (crov_set) begin
            reg_crov <= 'b1;
         end else if (crov_end) begin
            reg_crov <= 'b0;
         end
      end
   end

   //------------------------------------------------------------------
   assign owam_recall = reg_recall;
   assign reok_pos = reg_reok_1 & !reg_reok_2;
   assign reok_neg = !reg_reok_1 & reg_reok_2;
   assign reok_set = phase_fcre & tscnt_samp & (reg_xfcnt==COMMCYC7);
   assign reok_clr = reg_ppm? reok_pos : reg_reov;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn) begin
         reg_recall <= 'b0;
      end else begin
         if (reok_set) begin
            reg_recall <= 'b1;
         end else if (reok_clr) begin
            reg_recall <= 'b0;
         end
      end
   end

   //------------------------------------------------------------------
   assign reov_set = reok_pos;
   assign reov_end = reg_ppm? (phase_owfc & pull_end & reg_dqout &
                               phase_fcre) : reok_neg;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn) begin
         reg_reov <= 'b0;
      end else begin
         if (reov_set) begin
            reg_reov <= 'b1;
         end else if (reov_end) begin
            reg_reov <= 'b0;
         end
      end
   end

   //------------------------------------------------------------------
  `ifdef DTT //TTRIM[3:0]
   // Presence-Detect High Time: 15us('h024) -> 55us('h084)
   always @(*) begin
      case (owam_ttrim[3:0])
        4'h0000: ttrim_pdhigh = PDHCYC00; // 15  us
        4'h0001: ttrim_pdhigh = PDHCYC01; // 17.9us
        4'h0010: ttrim_pdhigh = PDHCYC02; // 20  us
        4'h0011: ttrim_pdhigh = PDHCYC03; // 22.1us
        4'h0100: ttrim_pdhigh = PDHCYC04; // 27.9us
        4'h0101: ttrim_pdhigh = PDHCYC05; // 29.1us
        4'h0110: ttrim_pdhigh = PDHCYC06; // 30  us
        4'h0111: ttrim_pdhigh = PDHCYC07; // 30.8us
        4'h1000: ttrim_pdhigh = PDHCYC08; // 31.2us
        4'h1001: ttrim_pdhigh = PDHCYC09; // 32.1us
        4'h1010: ttrim_pdhigh = PDHCYC10; // 32.9us
        4'h1011: ttrim_pdhigh = PDHCYC11; // 34.2us
        4'h1100: ttrim_pdhigh = PDHCYC12; // 35  us
        4'h1101: ttrim_pdhigh = PDHCYC13; // 40  us
        4'h1110: ttrim_pdhigh = PDHCYC14; // 47.5us
        4'h1111: ttrim_pdhigh = PDHCYC15; // 55  us
        default: ttrim_pdhigh = PDHCYC09; // 32.1us
      endcase
   end
  `endif

   //------------------------------------------------------------------
  `ifdef DTT //TTRIM[3:0]
   // Presence-Detect Low Time: 60us('h090) -> 220us('h210)
   always @(*) begin
      case (owam_ttrim[3:0])
        4'h0000: ttrim_pdlow = PDLCYC00; // 60   us
        4'h0001: ttrim_pdlow = PDLCYC01; // 70   us
        4'h0010: ttrim_pdlow = PDLCYC02; // 80   us
        4'h0011: ttrim_pdlow = PDLCYC03; // 90   us
        4'h0100: ttrim_pdlow = PDLCYC04; // 100  us
        4'h0101: ttrim_pdlow = PDLCYC05; // 102.1us
        4'h0110: ttrim_pdlow = PDLCYC06; // 103.8us
        4'h0111: ttrim_pdlow = PDLCYC07; // 105.8us
        4'h1000: ttrim_pdlow = PDLCYC08; // 107.9us
        4'h1001: ttrim_pdlow = PDLCYC09; // 110  us
        4'h1010: ttrim_pdlow = PDLCYC10; // 112.5us
        4'h1011: ttrim_pdlow = PDLCYC11; // 115  us
        4'h1100: ttrim_pdlow = PDLCYC12; // 117.5us
        4'h1101: ttrim_pdlow = PDLCYC13; // 120  us
        4'h1110: ttrim_pdlow = PDLCYC14; // 200  us
        4'h1111: ttrim_pdlow = PDLCYC15; // 220  us
        default: ttrim_pdlow = PDLCYC09; // 110  us
      endcase
   end
  `endif

   //------------------------------------------------------------------
  `ifdef DTT //TTRIM[7:4]
   // Reset-pulse Low Detect Time: 180us('h1b0) -> 440us('h420)
   always @(*) begin
      case (owam_ttrim[7:4])
        4'h0000: ttrim_rpldet = RLDCYC00; // 180us
        4'h0001: ttrim_rpldet = RLDCYC01; // 200us
        4'h0010: ttrim_rpldet = RLDCYC02; // 210us
        4'h0011: ttrim_rpldet = RLDCYC03; // 220us
        4'h0100: ttrim_rpldet = RLDCYC04; // 225us
        4'h0101: ttrim_rpldet = RLDCYC05; // 230us
        4'h0110: ttrim_rpldet = RLDCYC06; // 235us
        4'h0111: ttrim_rpldet = RLDCYC07; // 240us
        4'h1000: ttrim_rpldet = RLDCYC08; // 245us
        4'h1001: ttrim_rpldet = RLDCYC09; // 250us
        4'h1010: ttrim_rpldet = RLDCYC10; // 255us
        4'h1011: ttrim_rpldet = RLDCYC11; // 260us
        4'h1100: ttrim_rpldet = RLDCYC12; // 270us
        4'h1101: ttrim_rpldet = RLDCYC13; // 360us
        4'h1110: ttrim_rpldet = RLDCYC14; // 400us
        4'h1111: ttrim_rpldet = RLDCYC15; // 440us
        default: ttrim_rpldet = RLDCYC08; // 245us
      endcase
   end
  `endif

   //------------------------------------------------------------------
   assign phase_owlp = reg_xflow==XFLOW_OWLP;
   assign phase_owrp = reg_xflow==XFLOW_OWRP;
   assign phase_owwf = reg_xflow==XFLOW_OWWF;
   assign phase_owpp = reg_xflow==XFLOW_OWPP;
   assign phase_owrc = reg_xflow==XFLOW_OWRC;
   assign phase_owfc = reg_xflow==XFLOW_OWFC;
   assign phase_ownm = reg_xflow==XFLOW_OWNM;
   assign rcsr_end = phase_rcsr & (reg_xfcnt==bit_expect); //Search R
   assign rcrr_end = phase_rcrr & (reg_xfcnt==bit_expect); //Read ROM
   assign rcmr_end = phase_rcmr & (reg_xfcnt==bit_expect); //Match R
   assign rckr_end = phase_rckr & (reg_xfcnt==bit_expect); //Skip ROM
   assign rcas_end = phase_rcas & (reg_xfcnt==bit_expect); //Alarm S
   assign rcsm_end = phase_rcsm & (reg_xfcnt==bit_expect); //Setup R
   assign fcct_end = phase_fcct & ctov_end;                //ConvertT
   assign fcwr_end = phase_fcwr & (reg_xfcnt==bit_expect); //Wr Reg
   assign fcrr_end = phase_fcrr & (reg_xfcnt==bit_expect); //Rd Reg
   assign fccr_end = phase_fccr & crov_end;                //Copy Reg
   assign fcre_end = phase_fcre & reov_end;                //Recall
   assign rppm_end = phase_rppm & (reg_xfcnt==bit_expect); //Rd PPM
   assign owrp_end = phase_owrp & det_pos;
  `ifdef DTT
   assign owwf_end = phase_owwf & (reg_tscnt==ttrim_pdhigh); //32us
   assign owpp_end = phase_owpp & (reg_tscnt==ttrim_pdlow);  //110us
  `else
   assign owwf_end = phase_owwf & (reg_tscnt==WAITFORCYC); //32us
   assign owpp_end = phase_owpp & (reg_tscnt==PRESENTCYC); //110us
  `endif
   assign owrc_end = phase_owrc & (rcsr_end | rcrr_end | rcmr_end |
                                   rckr_end | rcas_end | rcsm_end);
   assign owrc_miss = phase_owrc & tscnt_samp & owrc_case;
   assign owrc_case = (phase_rcas & !reg_alarm) | reg_rcmiss;
   assign owrc_over = phase_rcsr | phase_alarm | phase_rcsm;
   assign owfc_end = phase_owfc & (fcct_end | fcwr_end | fcrr_end |
                                   fccr_end | fcre_end | rppm_end);
  `ifdef DTT
   assign owfc_mrst = phase_owfc & (reg_tscnt==ttrim_rpldet); //245us
   assign ownm_mrst = phase_ownm & (reg_tscnt==ttrim_rpldet); //245us
  `else
   assign owfc_mrst = phase_owfc & (reg_tscnt==RSTTRIGCYC); //245us
   assign ownm_mrst = phase_ownm & (reg_tscnt==RSTTRIGCYC); //245us
  `endif

   //-- flow machine circuit --
   always @(*) begin
      if (!owpo_rstn) begin
         nxt_xflow = XFLOW_OWFI;
      end else begin
         case (reg_xflow)
           XFLOW_OWFI: begin
              if (det_neg) begin
                 nxt_xflow = XFLOW_OWRP;
              end else begin
                 nxt_xflow = XFLOW_OWFI;
              end
           end
           XFLOW_OWLP: begin
              if (!owwu_rstn) begin
                 nxt_xflow = XFLOW_OWRP;
              end else begin
                 nxt_xflow = XFLOW_OWLP;
              end
           end
           XFLOW_OWRP: begin
              if (owrp_end) begin
                 nxt_xflow = XFLOW_OWWF;
              end else begin
                 nxt_xflow = XFLOW_OWRP;
              end
           end
           XFLOW_OWWF: begin
              if (owwf_end) begin
                 nxt_xflow = XFLOW_OWPP;
              end else begin
                 nxt_xflow = XFLOW_OWWF;
              end
           end
           XFLOW_OWPP: begin
              if (owpp_end) begin
                 nxt_xflow = XFLOW_OWRC;
              end else begin
                 nxt_xflow = XFLOW_OWPP;
              end
           end
           XFLOW_OWRC: begin
              if (owrc_end) begin
                 if (owrc_over) begin
                    nxt_xflow = XFLOW_OWFI;
                 end else begin
                    nxt_xflow = XFLOW_OWFC;
                 end
              end else begin
                 if (owrc_miss) begin
                    nxt_xflow = XFLOW_OWNM;
                 end else begin
                    nxt_xflow = XFLOW_OWRC;
                 end
              end
           end
           XFLOW_OWFC: begin
              if (owfc_end) begin
                 nxt_xflow = XFLOW_OWFI;
              end else begin
                 if (owfc_mrst) begin
                    nxt_xflow = XFLOW_OWRP;
                 end else begin
                    nxt_xflow = XFLOW_OWFC;
                 end
              end
           end
           XFLOW_OWNM: begin
              if (ownm_mrst) begin
                 nxt_xflow = XFLOW_OWRP;
              end else begin
                 nxt_xflow = XFLOW_OWNM;
              end
           end
           default: begin
              nxt_xflow = XFLOW_OWFI;
           end
         endcase
      end
   end
   always @(posedge clk_2m4) begin
      if (!owpo_rstn) begin
         reg_xflow <= XFLOW_OWFI;
      end else begin
         reg_xflow <= nxt_xflow;
      end
   end

   always @(*) begin
      case (reg_comm)
        OWRC_SearchROM: begin
           bit_expect = 'hc8; //192+8
        end
        OWRC_ReadROM: begin
           bit_expect = 'h48; //64+8
        end
        OWRC_MatchROM: begin
           bit_expect = 'h48; //64+8
        end
        OWRC_SkipROM: begin
           bit_expect = 'h8; //8
        end
        OWRC_AlarmSearch: begin
           bit_expect = 'hc8; //192+8
        end
        OWRC_SetupROM: begin
           bit_expect = 'h48; //64+8
        end
        OWFC_ConvertT: begin
           bit_expect = 'hff;
        end
        OWFC_WriteReg: begin
           bit_expect = 'h20; //24+8
        end
        OWFC_ReadReg: begin
           bit_expect = 'h50; //72+8
        end
        OWFC_CopyReg: begin
           bit_expect = 'hff;
        end
        OWFC_RecallE2: begin
           bit_expect = 'hff;
        end
        OWFC_ReadPPM: begin
           bit_expect = 'h09; //8+1
        end
        default: begin
           bit_expect = 'hff;
        end
      endcase
   end

   //-- transfer bit counter circuit --
   //assign xfcnt_rst = !owpo_rstn | !owwu_rstn | owrc_end | owfc_end |
   //                   owrc_miss | ownm_mrst | owfc_mrst;
   assign xfcnt_rst = !owpo_rstn | !owwu_rstn | owrc_end | owfc_end |
                      ownm_mrst | owfc_mrst;
   assign xfcnt_ena = (phase_owrc | phase_owfc) & (pull_end |
                      tscnt_samp);
   assign xfcnt_hld = phase_fcct | phase_fccr | phase_fcre;
   always @(posedge clk_2m4) begin
      if (xfcnt_rst) begin
         reg_xfcnt <= 'h00;
      end else begin
         if (xfcnt_ena) begin
            if (xfcnt_hld) begin
               reg_xfcnt <= reg_xfcnt;
            end else begin
               reg_xfcnt <= reg_xfcnt + 'h01;
            end
         end
      end
   end

   //------------------------------------------------------------------
  `ifdef DTT //TTRIM[11:8]
   // Read-data Pulling High Time: 11.2us('h01b) -> 40us('h060)
   always @(*) begin
      case (owam_ttrim[11:8])
        4'h0000: ttrim_rphigh = RPHCYC00; // 11.2us
        4'h0001: ttrim_rphigh = RPHCYC01; // 12.5us
        4'h0010: ttrim_rphigh = RPHCYC02; // 13.7us
        4'h0011: ttrim_rphigh = RPHCYC03; // 15  us
        4'h0100: ttrim_rphigh = RPHCYC04; // 15.8us
        4'h0101: ttrim_rphigh = RPHCYC05; // 16.6us
        4'h0110: ttrim_rphigh = RPHCYC06; // 17.5us
        4'h0111: ttrim_rphigh = RPHCYC07; // 18.3us
        4'h1000: ttrim_rphigh = RPHCYC08; // 19.1us
        4'h1001: ttrim_rphigh = RPHCYC09; // 20  us
        4'h1010: ttrim_rphigh = RPHCYC10; // 23.3us
        4'h1011: ttrim_rphigh = RPHCYC11; // 26.6us
        4'h1100: ttrim_rphigh = RPHCYC12; // 30  us
        4'h1101: ttrim_rphigh = RPHCYC13; // 33.3us
        4'h1110: ttrim_rphigh = RPHCYC14; // 36.6us
        4'h1111: ttrim_rphigh = RPHCYC15; // 40  us
        default: ttrim_rphigh = RPHCYC09; // 20  us
      endcase
   end
  `endif

   //------------------------------------------------------------------
  `ifdef DTT //TTRIM[11:8]
   // Nirvana Pulling High Time: 11.2us('h01f) -> 40us('h064)
   always @(*) begin
      case (owam_ttrim[11:8])
        4'h0000: ttrim_nphigh = NPHCYC00; // 12.9us
        4'h0001: ttrim_nphigh = NPHCYC01; // 14.1us
        4'h0010: ttrim_nphigh = NPHCYC02; // 15.4us
        4'h0011: ttrim_nphigh = NPHCYC03; // 16.6us
        4'h0100: ttrim_nphigh = NPHCYC04; // 17.5us
        4'h0101: ttrim_nphigh = NPHCYC05; // 18.3us
        4'h0110: ttrim_nphigh = NPHCYC06; // 19.1us
        4'h0111: ttrim_nphigh = NPHCYC07; // 20  us
        4'h1000: ttrim_nphigh = NPHCYC08; // 20.8us
        4'h1001: ttrim_nphigh = NPHCYC09; // 21.6us
        4'h1010: ttrim_nphigh = NPHCYC10; // 25  us
        4'h1011: ttrim_nphigh = NPHCYC11; // 28.3us
        4'h1100: ttrim_nphigh = NPHCYC12; // 31.6us
        4'h1101: ttrim_nphigh = NPHCYC13; // 35  us
        4'h1110: ttrim_nphigh = NPHCYC14; // 38.3us
        4'h1111: ttrim_nphigh = NPHCYC15; // 41.6us
        default: ttrim_nphigh = NPHCYC09; // 21.6us
      endcase
   end
  `endif

   //------------------------------------------------------------------
  `ifdef DTT //TTRIM[11:8]
   // Read-data Pulling Low Time: 20us('h030) -> 110us('h108)
   always @(*) begin
      case (owam_ttrim[11:8])
        4'h0000: ttrim_rplow = RPLCYC00; // 20  us
        4'h0001: ttrim_rplow = RPLCYC01; // 22.9us
        4'h0010: ttrim_rplow = RPLCYC02; // 25.8us
        4'h0011: ttrim_rplow = RPLCYC03; // 29.1us
        4'h0100: ttrim_rplow = RPLCYC04; // 32.1us
        4'h0101: ttrim_rplow = RPLCYC05; // 37.9us
        4'h0110: ttrim_rplow = RPLCYC06; // 43.7us
        4'h0111: ttrim_rplow = RPLCYC07; // 49.1us
        4'h1000: ttrim_rplow = RPLCYC08; // 54.6us
        4'h1001: ttrim_rplow = RPLCYC09; // 60  us
        4'h1010: ttrim_rplow = RPLCYC10; // 68.3us
        4'h1011: ttrim_rplow = RPLCYC11; // 76.6us
        4'h1100: ttrim_rplow = RPLCYC12; // 85  us
        4'h1101: ttrim_rplow = RPLCYC13; // 93.3us
        4'h1110: ttrim_rplow = RPLCYC14; //101.6us
        4'h1111: ttrim_rplow = RPLCYC15; //110  us
        default: ttrim_rplow = RPLCYC09; // 60  us
      endcase
   end
  `endif

   //------------------------------------------------------------------
  `ifdef DTT //TTRIM[11:8]
   // Nirvana Pulling Low Time: 21.6us('h034) -> 111.7us('h10c)
   always @(*) begin
      case (owam_ttrim[11:8])
        4'h0000: ttrim_nplow = NPLCYC00; // 21.6us
        4'h0001: ttrim_nplow = NPLCYC01; // 24.6us
        4'h0010: ttrim_nplow = NPLCYC02; // 27.5us
        4'h0011: ttrim_nplow = NPLCYC03; // 30.8us
        4'h0100: ttrim_nplow = NPLCYC04; // 33.7us
        4'h0101: ttrim_nplow = NPLCYC05; // 39.6us
        4'h0110: ttrim_nplow = NPLCYC06; // 45.4us
        4'h0111: ttrim_nplow = NPLCYC07; // 50.8us
        4'h1000: ttrim_nplow = NPLCYC08; // 56.2us
        4'h1001: ttrim_nplow = NPLCYC09; // 61.6us
        4'h1010: ttrim_nplow = NPLCYC10; // 70  us
        4'h1011: ttrim_nplow = NPLCYC11; // 78.3us
        4'h1100: ttrim_nplow = NPLCYC12; // 86.6us
        4'h1101: ttrim_nplow = NPLCYC13; // 95  us
        4'h1110: ttrim_nplow = NPLCYC14; //103.3us
        4'h1111: ttrim_nplow = NPLCYC15; //111.7us
        default: ttrim_nplow = NPLCYC09; // 61.6us
      endcase
   end
  `endif

   //-- timeslot machine circuit --
   assign rythm_idle = reg_tslot==TSLOT_IDLE;
   assign rythm_actv = reg_tslot==TSLOT_ACTV;
   assign rythm_init = reg_tslot==TSLOT_INIT;
   assign rythm_pull = reg_tslot==TSLOT_PULL;
   assign rythm_rena = reg_tslot==TSLOT_RENA;
   assign rythm_samp = reg_tslot==TSLOT_SAMP;
   assign rythm_tail = reg_tslot==TSLOT_TAIL;
   assign rythm_miss = reg_tslot==TSLOT_MISS;
   assign pulse_sank = reg_tslot==TSLOT_SANK;
   assign pulse_anat = reg_tslot==TSLOT_ANAT;
   assign pulse_nirv = reg_tslot==TSLOT_NIRV;
   assign xflow_init = phase_owrp | phase_owpp | phase_owwf;
  `ifdef DTT
   assign pull_fix = reg_dqout? (reg_tscnt==ttrim_rphigh) : //20us
                     (reg_tscnt==ttrim_rplow);  //60us
  `else
   assign pull_fix = reg_dqout? (reg_tscnt==PULLFIXCYC) : //20us
                     (reg_tscnt==PULLLOWCYC);  //60us
  `endif
   assign init_end = owrp_end | owpp_end | owwf_end;
   assign pull_end = rythm_pull & pull_fix;
   assign rena_end = rythm_rena & (det_pos | owfc_mrst);
  `ifdef DTT
   assign samp_end = rythm_samp & (reg_tscnt==ttrim_spkarm); //32us
  `else
   assign samp_end = rythm_samp & (reg_tscnt==SAMPENDCYC);   //32us
  `endif
   assign tail_end = rythm_tail & det_pos; //DQ posedge
   assign miss_end = ownm_mrst; //245us
   //------------------------------------------------------------------
   always @(*) begin
      if (!owpo_rstn) begin
         nxt_tslot = TSLOT_IDLE;
      end else begin
         case (reg_tslot)
           TSLOT_IDLE: begin
              if (det_neg) begin
                 if (reg_rcmiss) begin
                    nxt_tslot = TSLOT_MISS;
                 end else begin
                    if (xflow_init) begin
                       nxt_tslot = TSLOT_INIT;
                    end else begin
                       nxt_tslot = TSLOT_ACTV;
                    end
                 end
              end else begin
                 nxt_tslot = TSLOT_IDLE;
              end
           end
           TSLOT_ACTV: begin
              if (reg_dqena) begin
                 nxt_tslot = TSLOT_PULL;
              end else begin
                 nxt_tslot = TSLOT_SAMP;
              end
           end
           TSLOT_INIT: begin
              if (init_end) begin
                 nxt_tslot = TSLOT_IDLE;
              end else begin
                 nxt_tslot = TSLOT_INIT;
              end
           end
           TSLOT_PULL: begin
              if (pull_end) begin
                 if (reg_dq_1) begin
                    nxt_tslot = TSLOT_IDLE;
                 end else begin
                    nxt_tslot = TSLOT_SANK;
                 end
              end else begin
                 nxt_tslot = TSLOT_PULL;
              end
           end
           TSLOT_SANK: begin
              if (reg_dq_1) begin
                 nxt_tslot = TSLOT_IDLE;
              end else begin
                 nxt_tslot = TSLOT_ANAT;
              end
           end
           TSLOT_ANAT: begin
              if (reg_dq_1) begin
                 nxt_tslot = TSLOT_IDLE;
              end else begin
                 nxt_tslot = TSLOT_NIRV;
              end
           end
           TSLOT_NIRV: begin
              if (reg_dq_1) begin
                 nxt_tslot = TSLOT_IDLE;
              end else begin
                 nxt_tslot = TSLOT_RENA;
              end
           end
           TSLOT_RENA: begin
              if (rena_end) begin
                 nxt_tslot = TSLOT_IDLE;
              end else begin
                 nxt_tslot = TSLOT_RENA;
              end
           end
           TSLOT_SAMP: begin
              if (samp_end) begin
                 if (reg_dq_2) begin
                    nxt_tslot = TSLOT_IDLE;
                 end else begin
                    nxt_tslot = TSLOT_TAIL;
                 end
              end else begin
                 nxt_tslot = TSLOT_SAMP;
              end
           end
           TSLOT_TAIL: begin
              if (tail_end) begin
                 nxt_tslot = TSLOT_IDLE;
              end else begin
                 nxt_tslot = TSLOT_TAIL;
              end
           end
           TSLOT_MISS: begin
              if (miss_end) begin
                 nxt_tslot = TSLOT_INIT;
              end else begin
                 nxt_tslot = TSLOT_MISS;
              end
           end
           default: begin
              nxt_tslot = TSLOT_IDLE;
           end
         endcase
      end
   end
   always @(posedge clk_2m4) begin
      if (!owpo_rstn) begin
         reg_tslot <= TSLOT_IDLE;
      end else begin
         reg_tslot <= nxt_tslot;
      end
   end

   //-- timeslot counter circuit --
   //assign tscnt_rst = owrp_end | owwf_end | owpp_end | pull_end | 
   //                   !owpo_rstn | !owwu_rstn | samp_end |
   //                   tscnt_clr;
   assign tscnt_rst = owrp_end | owwf_end | owpp_end | pull_end | 
                      !owpo_rstn | !owwu_rstn | tscnt_samp |
                      tscnt_clr;
   //assign tscnt_clr = ((phase_ownm | phase_owrc | phase_owfc) &
   //                   det_pos) | ownm_mrst | owfc_mrst;
   assign tscnt_clr = phase_ownm & det_pos;
   assign tscnt_samp = reg_dq_2? samp_end : tail_end;
   //assign tscnt_ena = !reg_dq_1 | phase_owwf | rythm_pull |
   //                   rythm_samp;
   assign tscnt_ena = tscnt_ini | tscnt_cmm | tscnt_miss | tscnt_rena;
   assign tscnt_ini = ((phase_owrp | phase_owpp) & rythm_init) | 
                      phase_owwf;
   assign tscnt_cmm = (phase_owrc | phase_owfc) & (rythm_pull |
                                                   rythm_samp);
   assign tscnt_miss = phase_ownm & !reg_dq_1;
   assign tscnt_rena = (phase_owrc | phase_owfc) & !reg_dq_1 &
                       (rythm_actv | rythm_samp | rythm_tail |
                       rythm_pull | rythm_rena);
   assign tscnt_reld = pulse_nirv;
   //------------------------------------------------------------------
   always @(posedge clk_2m4) begin
      if (tscnt_rst) begin
         reg_tscnt <= 'h000;
      end else begin
         if (tscnt_reld) begin
            if (reg_dqout) begin
              `ifdef DTT
               reg_tscnt <= ttrim_nphigh;
              `else
               reg_tscnt <= PULLNPHCYC;
              `endif
            end else begin
              `ifdef DTT
               reg_tscnt <= ttrim_nplow;
              `else
               reg_tscnt <= PULLNIRCYC;
              `endif
            end
         end else if (tscnt_ena) begin
            reg_tscnt <= reg_tscnt + 'h001;
         end
      end
   end

   //-- unique 64bit code identify circuit --
   assign rcmiss_rst = !owpo_rstn | rcmiss_clr; //!owwu_rstn
   assign rcmiss_ena = phase_owrc & (rcmiss_set | rcmiss_alarm);
   assign rcmiss_clr = ownm_mrst; //reg_xflow==XFLOW_OWFI;
   assign rcmiss_set = samp_latch & rcmiss_rom;
   assign rcmiss_rom = rcmiss_00 | rcmiss_01 | rcmiss_02 | rcmiss_03 |
                       rcmiss_04 | rcmiss_05 | rcmiss_06 | rcmiss_07 |
                       rcmiss_08 | rcmiss_09 | rcmiss_10 | rcmiss_11 |
                       rcmiss_12 | rcmiss_13 | rcmiss_14 | rcmiss_15 |
                       rcmiss_16 | rcmiss_17 | rcmiss_18 | rcmiss_19 |
                       rcmiss_20 | rcmiss_21 | rcmiss_22 | rcmiss_23 |
                       rcmiss_24 | rcmiss_25 | rcmiss_26 | rcmiss_27 |
                       rcmiss_28 | rcmiss_29 | rcmiss_30 | rcmiss_31 |
                       rcmiss_32 | rcmiss_33 | rcmiss_34 | rcmiss_35 |
                       rcmiss_36 | rcmiss_37 | rcmiss_38 | rcmiss_39 |
                       rcmiss_40 | rcmiss_41 | rcmiss_42 | rcmiss_43 |
                       rcmiss_44 | rcmiss_45 | rcmiss_46 | rcmiss_47 |
                       rcmiss_48 | rcmiss_49 | rcmiss_50 | rcmiss_51 |
                       rcmiss_52 | rcmiss_53 | rcmiss_54 | rcmiss_55 |
                       rcmiss_56 | rcmiss_57 | rcmiss_58 | rcmiss_59 |
                       rcmiss_60 | rcmiss_61 | rcmiss_62 | rcmiss_63;
   assign rcmiss_alarm = phase_rcas & tscnt_samp & !reg_alarm;
   always @(posedge clk_2m4) begin
      if(rcmiss_rst) begin
         reg_rcmiss <= 0;
      end else if(rcmiss_ena) begin
         reg_rcmiss <= 1;
      end
   end

   //------------------------------------------------------------------
  `ifdef MONO
   assign rcmiss_00 = urcyc_00 & (reg_dqin^reg_romcode[00]);
   assign rcmiss_01 = urcyc_01 & (reg_dqin^reg_romcode[01]);
   assign rcmiss_02 = urcyc_02 & (reg_dqin^reg_romcode[02]);
   assign rcmiss_03 = urcyc_03 & (reg_dqin^reg_romcode[03]);
   assign rcmiss_04 = urcyc_04 & (reg_dqin^reg_romcode[04]);
   assign rcmiss_05 = urcyc_05 & (reg_dqin^reg_romcode[05]);
   assign rcmiss_06 = urcyc_06 & (reg_dqin^reg_romcode[06]);
   assign rcmiss_07 = urcyc_07 & (reg_dqin^reg_romcode[07]);
   assign rcmiss_08 = urcyc_08 & (reg_dqin^reg_romcode[08]);
   assign rcmiss_09 = urcyc_09 & (reg_dqin^reg_romcode[09]);
   assign rcmiss_10 = urcyc_10 & (reg_dqin^reg_romcode[10]);
   assign rcmiss_11 = urcyc_11 & (reg_dqin^reg_romcode[11]);
   assign rcmiss_12 = urcyc_12 & (reg_dqin^reg_romcode[12]);
   assign rcmiss_13 = urcyc_13 & (reg_dqin^reg_romcode[13]);
   assign rcmiss_14 = urcyc_14 & (reg_dqin^reg_romcode[14]);
   assign rcmiss_15 = urcyc_15 & (reg_dqin^reg_romcode[15]);
   assign rcmiss_16 = urcyc_16 & (reg_dqin^reg_romcode[16]);
   assign rcmiss_17 = urcyc_17 & (reg_dqin^reg_romcode[17]);
   assign rcmiss_18 = urcyc_18 & (reg_dqin^reg_romcode[18]);
   assign rcmiss_19 = urcyc_19 & (reg_dqin^reg_romcode[19]);
   assign rcmiss_20 = urcyc_20 & (reg_dqin^reg_romcode[20]);
   assign rcmiss_21 = urcyc_21 & (reg_dqin^reg_romcode[21]);
   assign rcmiss_22 = urcyc_22 & (reg_dqin^reg_romcode[22]);
   assign rcmiss_23 = urcyc_23 & (reg_dqin^reg_romcode[23]);
   assign rcmiss_24 = urcyc_24 & (reg_dqin^reg_romcode[24]);
   assign rcmiss_25 = urcyc_25 & (reg_dqin^reg_romcode[25]);
   assign rcmiss_26 = urcyc_26 & (reg_dqin^reg_romcode[26]);
   assign rcmiss_27 = urcyc_27 & (reg_dqin^reg_romcode[27]);
   assign rcmiss_28 = urcyc_28 & (reg_dqin^reg_romcode[28]);
   assign rcmiss_29 = urcyc_29 & (reg_dqin^reg_romcode[29]);
   assign rcmiss_30 = urcyc_30 & (reg_dqin^reg_romcode[30]);
   assign rcmiss_31 = urcyc_31 & (reg_dqin^reg_romcode[31]);
   assign rcmiss_32 = urcyc_32 & (reg_dqin^reg_romcode[32]);
   assign rcmiss_33 = urcyc_33 & (reg_dqin^reg_romcode[33]);
   assign rcmiss_34 = urcyc_34 & (reg_dqin^reg_romcode[34]);
   assign rcmiss_35 = urcyc_35 & (reg_dqin^reg_romcode[35]);
   assign rcmiss_36 = urcyc_36 & (reg_dqin^reg_romcode[36]);
   assign rcmiss_37 = urcyc_37 & (reg_dqin^reg_romcode[37]);
   assign rcmiss_38 = urcyc_38 & (reg_dqin^reg_romcode[38]);
   assign rcmiss_39 = urcyc_39 & (reg_dqin^reg_romcode[39]);
   assign rcmiss_40 = urcyc_40 & (reg_dqin^reg_romcode[40]);
   assign rcmiss_41 = urcyc_41 & (reg_dqin^reg_romcode[41]);
   assign rcmiss_42 = urcyc_42 & (reg_dqin^reg_romcode[42]);
   assign rcmiss_43 = urcyc_43 & (reg_dqin^reg_romcode[43]);
   assign rcmiss_44 = urcyc_44 & (reg_dqin^reg_romcode[44]);
   assign rcmiss_45 = urcyc_45 & (reg_dqin^reg_romcode[45]);
   assign rcmiss_46 = urcyc_46 & (reg_dqin^reg_romcode[46]);
   assign rcmiss_47 = urcyc_47 & (reg_dqin^reg_romcode[47]);
   assign rcmiss_48 = urcyc_48 & (reg_dqin^reg_romcode[48]);
   assign rcmiss_49 = urcyc_49 & (reg_dqin^reg_romcode[49]);
   assign rcmiss_50 = urcyc_50 & (reg_dqin^reg_romcode[50]);
   assign rcmiss_51 = urcyc_51 & (reg_dqin^reg_romcode[51]);
   assign rcmiss_52 = urcyc_52 & (reg_dqin^reg_romcode[52]);
   assign rcmiss_53 = urcyc_53 & (reg_dqin^reg_romcode[53]);
   assign rcmiss_54 = urcyc_54 & (reg_dqin^reg_romcode[54]);
   assign rcmiss_55 = urcyc_55 & (reg_dqin^reg_romcode[55]);
   assign rcmiss_56 = urcyc_56 & (reg_dqin^reg_romcode[56]);
   assign rcmiss_57 = urcyc_57 & (reg_dqin^reg_romcode[57]);
   assign rcmiss_58 = urcyc_58 & (reg_dqin^reg_romcode[58]);
   assign rcmiss_59 = urcyc_59 & (reg_dqin^reg_romcode[59]);
   assign rcmiss_60 = urcyc_60 & (reg_dqin^reg_romcode[60]);
   assign rcmiss_61 = urcyc_61 & (reg_dqin^reg_romcode[61]);
   assign rcmiss_62 = urcyc_62 & (reg_dqin^reg_romcode[62]);
   assign rcmiss_63 = urcyc_63 & (reg_dqin^reg_romcode[63]);
  `else
   assign rcmiss_00 = urcyc_00 & (reg_fetch[0]^owam_romcode[00]);
   assign rcmiss_01 = urcyc_01 & (reg_fetch[1]^owam_romcode[01]);
   assign rcmiss_02 = urcyc_02 & (reg_fetch[2]^owam_romcode[02]);
   assign rcmiss_03 = urcyc_03 & (reg_fetch[3]^owam_romcode[03]);
   assign rcmiss_04 = urcyc_04 & (reg_fetch[4]^owam_romcode[04]);
   assign rcmiss_05 = urcyc_05 & (reg_fetch[5]^owam_romcode[05]);
   assign rcmiss_06 = urcyc_06 & (reg_fetch[6]^owam_romcode[06]);
   assign rcmiss_07 = urcyc_07 & (reg_fetch[7]^owam_romcode[07]);
   assign rcmiss_08 = urcyc_08 & (reg_fetch[0]^owam_romcode[08]);
   assign rcmiss_09 = urcyc_09 & (reg_fetch[1]^owam_romcode[09]);
   assign rcmiss_10 = urcyc_10 & (reg_fetch[2]^owam_romcode[10]);
   assign rcmiss_11 = urcyc_11 & (reg_fetch[3]^owam_romcode[11]);
   assign rcmiss_12 = urcyc_12 & (reg_fetch[4]^owam_romcode[12]);
   assign rcmiss_13 = urcyc_13 & (reg_fetch[5]^owam_romcode[13]);
   assign rcmiss_14 = urcyc_14 & (reg_fetch[6]^owam_romcode[14]);
   assign rcmiss_15 = urcyc_15 & (reg_fetch[7]^owam_romcode[15]);
   assign rcmiss_16 = urcyc_16 & (reg_fetch[0]^owam_romcode[16]);
   assign rcmiss_17 = urcyc_17 & (reg_fetch[1]^owam_romcode[17]);
   assign rcmiss_18 = urcyc_18 & (reg_fetch[2]^owam_romcode[18]);
   assign rcmiss_19 = urcyc_19 & (reg_fetch[3]^owam_romcode[19]);
   assign rcmiss_20 = urcyc_20 & (reg_fetch[4]^owam_romcode[20]);
   assign rcmiss_21 = urcyc_21 & (reg_fetch[5]^owam_romcode[21]);
   assign rcmiss_22 = urcyc_22 & (reg_fetch[6]^owam_romcode[22]);
   assign rcmiss_23 = urcyc_23 & (reg_fetch[7]^owam_romcode[23]);
   assign rcmiss_24 = urcyc_24 & (reg_fetch[0]^owam_romcode[24]);
   assign rcmiss_25 = urcyc_25 & (reg_fetch[1]^owam_romcode[25]);
   assign rcmiss_26 = urcyc_26 & (reg_fetch[2]^owam_romcode[26]);
   assign rcmiss_27 = urcyc_27 & (reg_fetch[3]^owam_romcode[27]);
   assign rcmiss_28 = urcyc_28 & (reg_fetch[4]^owam_romcode[28]);
   assign rcmiss_29 = urcyc_29 & (reg_fetch[5]^owam_romcode[29]);
   assign rcmiss_30 = urcyc_30 & (reg_fetch[6]^owam_romcode[30]);
   assign rcmiss_31 = urcyc_31 & (reg_fetch[7]^owam_romcode[31]);
   assign rcmiss_32 = urcyc_32 & (reg_fetch[0]^owam_romcode[32]);
   assign rcmiss_33 = urcyc_33 & (reg_fetch[1]^owam_romcode[33]);
   assign rcmiss_34 = urcyc_34 & (reg_fetch[2]^owam_romcode[34]);
   assign rcmiss_35 = urcyc_35 & (reg_fetch[3]^owam_romcode[35]);
   assign rcmiss_36 = urcyc_36 & (reg_fetch[4]^owam_romcode[36]);
   assign rcmiss_37 = urcyc_37 & (reg_fetch[5]^owam_romcode[37]);
   assign rcmiss_38 = urcyc_38 & (reg_fetch[6]^owam_romcode[38]);
   assign rcmiss_39 = urcyc_39 & (reg_fetch[7]^owam_romcode[39]);
   assign rcmiss_40 = urcyc_40 & (reg_fetch[0]^owam_romcode[40]);
   assign rcmiss_41 = urcyc_41 & (reg_fetch[1]^owam_romcode[41]);
   assign rcmiss_42 = urcyc_42 & (reg_fetch[2]^owam_romcode[42]);
   assign rcmiss_43 = urcyc_43 & (reg_fetch[3]^owam_romcode[43]);
   assign rcmiss_44 = urcyc_44 & (reg_fetch[4]^owam_romcode[44]);
   assign rcmiss_45 = urcyc_45 & (reg_fetch[5]^owam_romcode[45]);
   assign rcmiss_46 = urcyc_46 & (reg_fetch[6]^owam_romcode[46]);
   assign rcmiss_47 = urcyc_47 & (reg_fetch[7]^owam_romcode[47]);
   assign rcmiss_48 = urcyc_48 & (reg_fetch[0]^owam_romcode[48]);
   assign rcmiss_49 = urcyc_49 & (reg_fetch[1]^owam_romcode[49]);
   assign rcmiss_50 = urcyc_50 & (reg_fetch[2]^owam_romcode[50]);
   assign rcmiss_51 = urcyc_51 & (reg_fetch[3]^owam_romcode[51]);
   assign rcmiss_52 = urcyc_52 & (reg_fetch[4]^owam_romcode[52]);
   assign rcmiss_53 = urcyc_53 & (reg_fetch[5]^owam_romcode[53]);
   assign rcmiss_54 = urcyc_54 & (reg_fetch[6]^owam_romcode[54]);
   assign rcmiss_55 = urcyc_55 & (reg_fetch[7]^owam_romcode[55]);
   assign rcmiss_56 = urcyc_56 & (reg_fetch[0]^owam_romcode[56]);
   assign rcmiss_57 = urcyc_57 & (reg_fetch[1]^owam_romcode[57]);
   assign rcmiss_58 = urcyc_58 & (reg_fetch[2]^owam_romcode[58]);
   assign rcmiss_59 = urcyc_59 & (reg_fetch[3]^owam_romcode[59]);
   assign rcmiss_60 = urcyc_60 & (reg_fetch[4]^owam_romcode[60]);
   assign rcmiss_61 = urcyc_61 & (reg_fetch[5]^owam_romcode[61]);
   assign rcmiss_62 = urcyc_62 & (reg_fetch[6]^owam_romcode[62]);
   assign rcmiss_63 = urcyc_63 & (reg_fetch[7]^owam_romcode[63]);
  `endif

   //------------------------------------------------------------------
   assign urcyc_00 = mrrom_00 | skrom_00;
   assign urcyc_01 = mrrom_01 | skrom_01;
   assign urcyc_02 = mrrom_02 | skrom_02;
   assign urcyc_03 = mrrom_03 | skrom_03;
   assign urcyc_04 = mrrom_04 | skrom_04;
   assign urcyc_05 = mrrom_05 | skrom_05;
   assign urcyc_06 = mrrom_06 | skrom_06;
   assign urcyc_07 = mrrom_07 | skrom_07;
   assign urcyc_08 = mrrom_08 | skrom_08;
   assign urcyc_09 = mrrom_09 | skrom_09;
   assign urcyc_10 = mrrom_10 | skrom_10;
   assign urcyc_11 = mrrom_11 | skrom_11;
   assign urcyc_12 = mrrom_12 | skrom_12;
   assign urcyc_13 = mrrom_13 | skrom_13;
   assign urcyc_14 = mrrom_14 | skrom_14;
   assign urcyc_15 = mrrom_15 | skrom_15;
   assign urcyc_16 = mrrom_16 | skrom_16;
   assign urcyc_17 = mrrom_17 | skrom_17;
   assign urcyc_18 = mrrom_18 | skrom_18;
   assign urcyc_19 = mrrom_19 | skrom_19;
   assign urcyc_20 = mrrom_20 | skrom_20;
   assign urcyc_21 = mrrom_21 | skrom_21;
   assign urcyc_22 = mrrom_22 | skrom_22;
   assign urcyc_23 = mrrom_23 | skrom_23;
   assign urcyc_24 = mrrom_24 | skrom_24;
   assign urcyc_25 = mrrom_25 | skrom_25;
   assign urcyc_26 = mrrom_26 | skrom_26;
   assign urcyc_27 = mrrom_27 | skrom_27;
   assign urcyc_28 = mrrom_28 | skrom_28;
   assign urcyc_29 = mrrom_29 | skrom_29;
   assign urcyc_30 = mrrom_30 | skrom_30;
   assign urcyc_31 = mrrom_31 | skrom_31;
   assign urcyc_32 = mrrom_32 | skrom_32;
   assign urcyc_33 = mrrom_33 | skrom_33;
   assign urcyc_34 = mrrom_34 | skrom_34;
   assign urcyc_35 = mrrom_35 | skrom_35;
   assign urcyc_36 = mrrom_36 | skrom_36;
   assign urcyc_37 = mrrom_37 | skrom_37;
   assign urcyc_38 = mrrom_38 | skrom_38;
   assign urcyc_39 = mrrom_39 | skrom_39;
   assign urcyc_40 = mrrom_40 | skrom_40;
   assign urcyc_41 = mrrom_41 | skrom_41;
   assign urcyc_42 = mrrom_42 | skrom_42;
   assign urcyc_43 = mrrom_43 | skrom_43;
   assign urcyc_44 = mrrom_44 | skrom_44;
   assign urcyc_45 = mrrom_45 | skrom_45;
   assign urcyc_46 = mrrom_46 | skrom_46;
   assign urcyc_47 = mrrom_47 | skrom_47;
   assign urcyc_48 = mrrom_48 | skrom_48;
   assign urcyc_49 = mrrom_49 | skrom_49;
   assign urcyc_50 = mrrom_50 | skrom_50;
   assign urcyc_51 = mrrom_51 | skrom_51;
   assign urcyc_52 = mrrom_52 | skrom_52;
   assign urcyc_53 = mrrom_53 | skrom_53;
   assign urcyc_54 = mrrom_54 | skrom_54;
   assign urcyc_55 = mrrom_55 | skrom_55;
   assign urcyc_56 = mrrom_56 | skrom_56;
   assign urcyc_57 = mrrom_57 | skrom_57;
   assign urcyc_58 = mrrom_58 | skrom_58;
   assign urcyc_59 = mrrom_59 | skrom_59;
   assign urcyc_60 = mrrom_60 | skrom_60;
   assign urcyc_61 = mrrom_61 | skrom_61;
   assign urcyc_62 = mrrom_62 | skrom_62;
   assign urcyc_63 = mrrom_63 | skrom_63;

   //------------------------------------------------------------------
   assign mrrom_00 = phase_rcmr & (reg_xfcnt==ROMCYC00);
   assign mrrom_01 = phase_rcmr & (reg_xfcnt==ROMCYC01);
   assign mrrom_02 = phase_rcmr & (reg_xfcnt==ROMCYC02);
   assign mrrom_03 = phase_rcmr & (reg_xfcnt==ROMCYC03);
   assign mrrom_04 = phase_rcmr & (reg_xfcnt==ROMCYC04);
   assign mrrom_05 = phase_rcmr & (reg_xfcnt==ROMCYC05);
   assign mrrom_06 = phase_rcmr & (reg_xfcnt==ROMCYC06);
   assign mrrom_07 = phase_rcmr & (reg_xfcnt==ROMCYC07);
   assign mrrom_08 = phase_rcmr & (reg_xfcnt==ROMCYC08);
   assign mrrom_09 = phase_rcmr & (reg_xfcnt==ROMCYC09);
   assign mrrom_10 = phase_rcmr & (reg_xfcnt==ROMCYC10);
   assign mrrom_11 = phase_rcmr & (reg_xfcnt==ROMCYC11);
   assign mrrom_12 = phase_rcmr & (reg_xfcnt==ROMCYC12);
   assign mrrom_13 = phase_rcmr & (reg_xfcnt==ROMCYC13);
   assign mrrom_14 = phase_rcmr & (reg_xfcnt==ROMCYC14);
   assign mrrom_15 = phase_rcmr & (reg_xfcnt==ROMCYC15);
   assign mrrom_16 = phase_rcmr & (reg_xfcnt==ROMCYC16);
   assign mrrom_17 = phase_rcmr & (reg_xfcnt==ROMCYC17);
   assign mrrom_18 = phase_rcmr & (reg_xfcnt==ROMCYC18);
   assign mrrom_19 = phase_rcmr & (reg_xfcnt==ROMCYC19);
   assign mrrom_20 = phase_rcmr & (reg_xfcnt==ROMCYC20);
   assign mrrom_21 = phase_rcmr & (reg_xfcnt==ROMCYC21);
   assign mrrom_22 = phase_rcmr & (reg_xfcnt==ROMCYC22);
   assign mrrom_23 = phase_rcmr & (reg_xfcnt==ROMCYC23);
   assign mrrom_24 = phase_rcmr & (reg_xfcnt==ROMCYC24);
   assign mrrom_25 = phase_rcmr & (reg_xfcnt==ROMCYC25);
   assign mrrom_26 = phase_rcmr & (reg_xfcnt==ROMCYC26);
   assign mrrom_27 = phase_rcmr & (reg_xfcnt==ROMCYC27);
   assign mrrom_28 = phase_rcmr & (reg_xfcnt==ROMCYC28);
   assign mrrom_29 = phase_rcmr & (reg_xfcnt==ROMCYC29);
   assign mrrom_30 = phase_rcmr & (reg_xfcnt==ROMCYC30);
   assign mrrom_31 = phase_rcmr & (reg_xfcnt==ROMCYC31);
   assign mrrom_32 = phase_rcmr & (reg_xfcnt==ROMCYC32);
   assign mrrom_33 = phase_rcmr & (reg_xfcnt==ROMCYC33);
   assign mrrom_34 = phase_rcmr & (reg_xfcnt==ROMCYC34);
   assign mrrom_35 = phase_rcmr & (reg_xfcnt==ROMCYC35);
   assign mrrom_36 = phase_rcmr & (reg_xfcnt==ROMCYC36);
   assign mrrom_37 = phase_rcmr & (reg_xfcnt==ROMCYC37);
   assign mrrom_38 = phase_rcmr & (reg_xfcnt==ROMCYC38);
   assign mrrom_39 = phase_rcmr & (reg_xfcnt==ROMCYC39);
   assign mrrom_40 = phase_rcmr & (reg_xfcnt==ROMCYC40);
   assign mrrom_41 = phase_rcmr & (reg_xfcnt==ROMCYC41);
   assign mrrom_42 = phase_rcmr & (reg_xfcnt==ROMCYC42);
   assign mrrom_43 = phase_rcmr & (reg_xfcnt==ROMCYC43);
   assign mrrom_44 = phase_rcmr & (reg_xfcnt==ROMCYC44);
   assign mrrom_45 = phase_rcmr & (reg_xfcnt==ROMCYC45);
   assign mrrom_46 = phase_rcmr & (reg_xfcnt==ROMCYC46);
   assign mrrom_47 = phase_rcmr & (reg_xfcnt==ROMCYC47);
   assign mrrom_48 = phase_rcmr & (reg_xfcnt==ROMCYC48);
   assign mrrom_49 = phase_rcmr & (reg_xfcnt==ROMCYC49);
   assign mrrom_50 = phase_rcmr & (reg_xfcnt==ROMCYC50);
   assign mrrom_51 = phase_rcmr & (reg_xfcnt==ROMCYC51);
   assign mrrom_52 = phase_rcmr & (reg_xfcnt==ROMCYC52);
   assign mrrom_53 = phase_rcmr & (reg_xfcnt==ROMCYC53);
   assign mrrom_54 = phase_rcmr & (reg_xfcnt==ROMCYC54);
   assign mrrom_55 = phase_rcmr & (reg_xfcnt==ROMCYC55);
   assign mrrom_56 = phase_rcmr & (reg_xfcnt==ROMCYC56);
   assign mrrom_57 = phase_rcmr & (reg_xfcnt==ROMCYC57);
   assign mrrom_58 = phase_rcmr & (reg_xfcnt==ROMCYC58);
   assign mrrom_59 = phase_rcmr & (reg_xfcnt==ROMCYC59);
   assign mrrom_60 = phase_rcmr & (reg_xfcnt==ROMCYC60);
   assign mrrom_61 = phase_rcmr & (reg_xfcnt==ROMCYC61);
   assign mrrom_62 = phase_rcmr & (reg_xfcnt==ROMCYC62);
   assign mrrom_63 = phase_rcmr & (reg_xfcnt==ROMCYC63);

   //------------------------------------------------------------------
   assign search_ena = phase_rcsr | phase_alarm;
   assign skrom_00 = search_ena & (reg_xfcnt==ROMBIT00W);
   assign skrom_01 = search_ena & (reg_xfcnt==ROMBIT01W);
   assign skrom_02 = search_ena & (reg_xfcnt==ROMBIT02W);
   assign skrom_03 = search_ena & (reg_xfcnt==ROMBIT03W);
   assign skrom_04 = search_ena & (reg_xfcnt==ROMBIT04W);
   assign skrom_05 = search_ena & (reg_xfcnt==ROMBIT05W);
   assign skrom_06 = search_ena & (reg_xfcnt==ROMBIT06W);
   assign skrom_07 = search_ena & (reg_xfcnt==ROMBIT07W);
   assign skrom_08 = search_ena & (reg_xfcnt==ROMBIT08W);
   assign skrom_09 = search_ena & (reg_xfcnt==ROMBIT09W);
   assign skrom_10 = search_ena & (reg_xfcnt==ROMBIT10W);
   assign skrom_11 = search_ena & (reg_xfcnt==ROMBIT11W);
   assign skrom_12 = search_ena & (reg_xfcnt==ROMBIT12W);
   assign skrom_13 = search_ena & (reg_xfcnt==ROMBIT13W);
   assign skrom_14 = search_ena & (reg_xfcnt==ROMBIT14W);
   assign skrom_15 = search_ena & (reg_xfcnt==ROMBIT15W);
   assign skrom_16 = search_ena & (reg_xfcnt==ROMBIT16W);
   assign skrom_17 = search_ena & (reg_xfcnt==ROMBIT17W);
   assign skrom_18 = search_ena & (reg_xfcnt==ROMBIT18W);
   assign skrom_19 = search_ena & (reg_xfcnt==ROMBIT19W);
   assign skrom_20 = search_ena & (reg_xfcnt==ROMBIT20W);
   assign skrom_21 = search_ena & (reg_xfcnt==ROMBIT21W);
   assign skrom_22 = search_ena & (reg_xfcnt==ROMBIT22W);
   assign skrom_23 = search_ena & (reg_xfcnt==ROMBIT23W);
   assign skrom_24 = search_ena & (reg_xfcnt==ROMBIT24W);
   assign skrom_25 = search_ena & (reg_xfcnt==ROMBIT25W);
   assign skrom_26 = search_ena & (reg_xfcnt==ROMBIT26W);
   assign skrom_27 = search_ena & (reg_xfcnt==ROMBIT27W);
   assign skrom_28 = search_ena & (reg_xfcnt==ROMBIT28W);
   assign skrom_29 = search_ena & (reg_xfcnt==ROMBIT29W);
   assign skrom_30 = search_ena & (reg_xfcnt==ROMBIT30W);
   assign skrom_31 = search_ena & (reg_xfcnt==ROMBIT31W);
   assign skrom_32 = search_ena & (reg_xfcnt==ROMBIT32W);
   assign skrom_33 = search_ena & (reg_xfcnt==ROMBIT33W);
   assign skrom_34 = search_ena & (reg_xfcnt==ROMBIT34W);
   assign skrom_35 = search_ena & (reg_xfcnt==ROMBIT35W);
   assign skrom_36 = search_ena & (reg_xfcnt==ROMBIT36W);
   assign skrom_37 = search_ena & (reg_xfcnt==ROMBIT37W);
   assign skrom_38 = search_ena & (reg_xfcnt==ROMBIT38W);
   assign skrom_39 = search_ena & (reg_xfcnt==ROMBIT39W);
   assign skrom_40 = search_ena & (reg_xfcnt==ROMBIT40W);
   assign skrom_41 = search_ena & (reg_xfcnt==ROMBIT41W);
   assign skrom_42 = search_ena & (reg_xfcnt==ROMBIT42W);
   assign skrom_43 = search_ena & (reg_xfcnt==ROMBIT43W);
   assign skrom_44 = search_ena & (reg_xfcnt==ROMBIT44W);
   assign skrom_45 = search_ena & (reg_xfcnt==ROMBIT45W);
   assign skrom_46 = search_ena & (reg_xfcnt==ROMBIT46W);
   assign skrom_47 = search_ena & (reg_xfcnt==ROMBIT47W);
   assign skrom_48 = search_ena & (reg_xfcnt==ROMBIT48W);
   assign skrom_49 = search_ena & (reg_xfcnt==ROMBIT49W);
   assign skrom_50 = search_ena & (reg_xfcnt==ROMBIT50W);
   assign skrom_51 = search_ena & (reg_xfcnt==ROMBIT51W);
   assign skrom_52 = search_ena & (reg_xfcnt==ROMBIT52W);
   assign skrom_53 = search_ena & (reg_xfcnt==ROMBIT53W);
   assign skrom_54 = search_ena & (reg_xfcnt==ROMBIT54W);
   assign skrom_55 = search_ena & (reg_xfcnt==ROMBIT55W);
   assign skrom_56 = search_ena & (reg_xfcnt==ROMBIT56W);
   assign skrom_57 = search_ena & (reg_xfcnt==ROMBIT57W);
   assign skrom_58 = search_ena & (reg_xfcnt==ROMBIT58W);
   assign skrom_59 = search_ena & (reg_xfcnt==ROMBIT59W);
   assign skrom_60 = search_ena & (reg_xfcnt==ROMBIT60W);
   assign skrom_61 = search_ena & (reg_xfcnt==ROMBIT61W);
   assign skrom_62 = search_ena & (reg_xfcnt==ROMBIT62W);
   assign skrom_63 = search_ena & (reg_xfcnt==ROMBIT63W);

   //-- dq input circuit --
  `ifdef MONO
   assign dqin_rst = !owpo_rstn; //!owwu_rstn
   assign dqin_ena = samp_wind;
   always @(posedge clk_2m4) begin
      if(dqin_rst) begin
         reg_dqin <= 0;
      end else if(dqin_ena) begin
         reg_dqin <= reg_dq_2;
      end
   end
  `else
   //------------------------------------------------------------------
   assign owam_rc0_we = samp_end & smrom_07;
   assign owam_rc1_we = samp_end & smrom_15;
   assign owam_rc2_we = samp_end & smrom_23;
   assign owam_rc3_we = samp_end & smrom_31;
   assign owam_rc4_we = samp_end & smrom_39;
   assign owam_rc5_we = samp_end & smrom_47;
   assign owam_rc6_we = samp_end & smrom_55;
   assign owam_rc7_we = samp_end & smrom_63;
   assign owam_tha_we = phase_owfc & samp_end & phase_fcwr &
                        (reg_xfcnt==THACYC7);
   assign owam_tla_we = phase_owfc & samp_end & phase_fcwr &
                        (reg_xfcnt==TLACYC7);
   assign owam_cfg_we = phase_owfc & samp_end & phase_fcwr &
                        (reg_xfcnt==CFGCYC7);
   assign owam_databus = romcrc_fix? reg_crcreg : reg_fetch;
   assign romcrc_cyc = (samp_latch | samp_end) & smrom_63;
   assign romcrc_fix = romcrc_cyc & reg_crcerr;
   assign fetch_rst = !owpo_rstn; //!owwu_rstn
   assign fetch_ena = samp_wind;
   assign fetch_0 = smrom_00 | smrom_08 | smrom_16 | smrom_24 |
                    smrom_32 | smrom_40 | smrom_48 | smrom_56 |
                    urcyc_00 | urcyc_08 | urcyc_16 | urcyc_24 |
                    urcyc_32 | urcyc_40 | urcyc_48 | urcyc_56 |
                    (phase_owfc & phase_fcwr &
                     ((reg_xfcnt==THACYC0) | (reg_xfcnt==TLACYC0) |
                      (reg_xfcnt==CFGCYC0))) | samp_comm_0;
   assign fetch_1 = smrom_01 | smrom_09 | smrom_17 | smrom_25 |
                    smrom_33 | smrom_41 | smrom_49 | smrom_57 |
                    urcyc_01 | urcyc_09 | urcyc_17 | urcyc_25 |
                    urcyc_33 | urcyc_41 | urcyc_49 | urcyc_57 |
                    (phase_owfc & phase_fcwr &
                     ((reg_xfcnt==THACYC1) | (reg_xfcnt==TLACYC1) |
                      (reg_xfcnt==CFGCYC1))) | samp_comm_1;
   assign fetch_2 = smrom_02 | smrom_10 | smrom_18 | smrom_26 |
                    smrom_34 | smrom_42 | smrom_50 | smrom_58 |
                    urcyc_02 | urcyc_10 | urcyc_18 | urcyc_26 |
                    urcyc_34 | urcyc_42 | urcyc_50 | urcyc_58 |
                    (phase_owfc & phase_fcwr &
                     ((reg_xfcnt==THACYC2) | (reg_xfcnt==TLACYC2) |
                      (reg_xfcnt==CFGCYC2))) | samp_comm_2;
   assign fetch_3 = smrom_03 | smrom_11 | smrom_19 | smrom_27 |
                    smrom_35 | smrom_43 | smrom_51 | smrom_59 |
                    urcyc_03 | urcyc_11 | urcyc_19 | urcyc_27 |
                    urcyc_35 | urcyc_43 | urcyc_51 | urcyc_59 |
                    (phase_owfc & phase_fcwr &
                     ((reg_xfcnt==THACYC3) | (reg_xfcnt==TLACYC3) |
                      (reg_xfcnt==CFGCYC3))) | samp_comm_3;
   assign fetch_4 = smrom_04 | smrom_12 | smrom_20 | smrom_28 |
                    smrom_36 | smrom_44 | smrom_52 | smrom_60 |
                    urcyc_04 | urcyc_12 | urcyc_20 | urcyc_28 |
                    urcyc_36 | urcyc_44 | urcyc_52 | urcyc_60 |
                    (phase_owfc & phase_fcwr &
                     ((reg_xfcnt==THACYC4) | (reg_xfcnt==TLACYC4) |
                      (reg_xfcnt==CFGCYC4))) | samp_comm_4;
   assign fetch_5 = smrom_05 | smrom_13 | smrom_21 | smrom_29 |
                    smrom_37 | smrom_45 | smrom_53 | smrom_61 |
                    urcyc_05 | urcyc_13 | urcyc_21 | urcyc_29 |
                    urcyc_37 | urcyc_45 | urcyc_53 | urcyc_61 |
                    (phase_owfc & phase_fcwr &
                     ((reg_xfcnt==THACYC5) | (reg_xfcnt==TLACYC5) |
                      (reg_xfcnt==CFGCYC5))) | samp_comm_5;
   assign fetch_6 = smrom_06 | smrom_14 | smrom_22 | smrom_30 |
                    smrom_38 | smrom_46 | smrom_54 | smrom_62 |
                    urcyc_06 | urcyc_14 | urcyc_22 | urcyc_30 |
                    urcyc_38 | urcyc_46 | urcyc_54 | urcyc_62 |
                    (phase_owfc & phase_fcwr &
                     ((reg_xfcnt==THACYC6) | (reg_xfcnt==TLACYC6) |
                      (reg_xfcnt==CFGCYC6))) | samp_comm_6;
   assign fetch_7 = smrom_07 | smrom_15 | smrom_23 | smrom_31 |
                    smrom_39 | smrom_47 | smrom_55 | smrom_63 |
                    urcyc_07 | urcyc_15 | urcyc_23 | urcyc_31 |
                    urcyc_39 | urcyc_47 | urcyc_55 | urcyc_63 |
                    (phase_owfc & phase_fcwr &
                     ((reg_xfcnt==THACYC7) | (reg_xfcnt==TLACYC7) |
                      (reg_xfcnt==CFGCYC7))) | samp_comm_7;
   always @(posedge clk_2m4) begin
      if(fetch_rst) begin
         reg_fetch <= COMMREG_DEF;
      end else if(fetch_ena) begin
         if (fetch_0) begin
            reg_fetch[0] <= reg_dq_2;
         end
         if (fetch_1) begin
            reg_fetch[1] <= reg_dq_2;
         end
         if (fetch_2) begin
            reg_fetch[2] <= reg_dq_2;
         end
         if (fetch_3) begin
            reg_fetch[3] <= reg_dq_2;
         end
         if (fetch_4) begin
            reg_fetch[4] <= reg_dq_2;
         end
         if (fetch_5) begin
            reg_fetch[5] <= reg_dq_2;
         end
         if (fetch_6) begin
            reg_fetch[6] <= reg_dq_2;
         end
         if (fetch_7) begin
            reg_fetch[7] <= reg_dq_2;
         end
      end
   end
  `endif

   //------------------------------------------------------------------
  `ifdef DTT //TTRIM[15:12]
   // Sample Window Tick: 11.6us('h01c) -> 89.1us('h0d6)
   always @(*) begin
      case (owam_ttrim[15:12])
        4'h0000: ttrim_swtick = SWTCYC00; // 11.6us
        4'h0001: ttrim_swtick = SWTCYC01; // 14.1us
        4'h0010: ttrim_swtick = SWTCYC02; // 16.6us
        4'h0011: ttrim_swtick = SWTCYC03; // 19.1us
        4'h0100: ttrim_swtick = SWTCYC04; // 21.6us
        4'h0101: ttrim_swtick = SWTCYC05; // 24.1us
        4'h0110: ttrim_swtick = SWTCYC06; // 26.6us
        4'h0111: ttrim_swtick = SWTCYC07; // 29.1us
        4'h1000: ttrim_swtick = SWTCYC08; // 31.2us
        4'h1001: ttrim_swtick = SWTCYC09; // 33.7us
        4'h1010: ttrim_swtick = SWTCYC10; // 36.2us
        4'h1011: ttrim_swtick = SWTCYC11; // 39.1us
        4'h1100: ttrim_swtick = SWTCYC12; // 49.1us
        4'h1101: ttrim_swtick = SWTCYC13; // 59.1us
        4'h1110: ttrim_swtick = SWTCYC14; // 69.1us
        4'h1111: ttrim_swtick = SWTCYC15; // 89.1us
        default: ttrim_swtick = SWTCYC08; // 31.2us
      endcase
   end
  `endif

   //------------------------------------------------------------------
  `ifdef DTT //TTRIM[15:12]
   // Sample Datum Process: 12.1us('h01d) -> 89.6us('h0d7)
   always @(*) begin
      case (owam_ttrim[15:12])
        4'h0000: ttrim_sdproc = SDPCYC00; // 12.1us
        4'h0001: ttrim_sdproc = SDPCYC01; // 14.6us
        4'h0010: ttrim_sdproc = SDPCYC02; // 17.1us
        4'h0011: ttrim_sdproc = SDPCYC03; // 19.6us
        4'h0100: ttrim_sdproc = SDPCYC04; // 22.1us
        4'h0101: ttrim_sdproc = SDPCYC05; // 24.6us
        4'h0110: ttrim_sdproc = SDPCYC06; // 27.1us
        4'h0111: ttrim_sdproc = SDPCYC07; // 29.6us
        4'h1000: ttrim_sdproc = SDPCYC08; // 31.6us
        4'h1001: ttrim_sdproc = SDPCYC09; // 34.1us
        4'h1010: ttrim_sdproc = SDPCYC10; // 36.6us
        4'h1011: ttrim_sdproc = SDPCYC11; // 39.6us
        4'h1100: ttrim_sdproc = SDPCYC12; // 49.6us
        4'h1101: ttrim_sdproc = SDPCYC13; // 59.6us
        4'h1110: ttrim_sdproc = SDPCYC14; // 69.6us
        4'h1111: ttrim_sdproc = SDPCYC15; // 89.6us
        default: ttrim_sdproc = SDPCYC08; // 31.6us
      endcase
   end
  `endif

   //------------------------------------------------------------------
  `ifdef DTT //TTRIM[15:12]
   // Sample Process Karma: 12.5us('h01e) -> 90us('h0d8)
   always @(*) begin
      case (owam_ttrim[15:12])
        4'h0000: ttrim_spkarm = SPKCYC00; // 12.5us
        4'h0001: ttrim_spkarm = SPKCYC01; // 15  us
        4'h0010: ttrim_spkarm = SPKCYC02; // 17.5us
        4'h0011: ttrim_spkarm = SPKCYC03; // 20  us
        4'h0100: ttrim_spkarm = SPKCYC04; // 22.5us
        4'h0101: ttrim_spkarm = SPKCYC05; // 25  us
        4'h0110: ttrim_spkarm = SPKCYC06; // 27.5us
        4'h0111: ttrim_spkarm = SPKCYC07; // 30  us
        4'h1000: ttrim_spkarm = SPKCYC08; // 32.1us
        4'h1001: ttrim_spkarm = SPKCYC09; // 34.6us
        4'h1010: ttrim_spkarm = SPKCYC10; // 37.1us
        4'h1011: ttrim_spkarm = SPKCYC11; // 40  us
        4'h1100: ttrim_spkarm = SPKCYC12; // 50  us
        4'h1101: ttrim_spkarm = SPKCYC13; // 60  us
        4'h1110: ttrim_spkarm = SPKCYC14; // 70  us
        4'h1111: ttrim_spkarm = SPKCYC15; // 90  us
        default: ttrim_spkarm = SPKCYC08; // 32.1us
      endcase
   end
  `endif

   //-- datapath & register circuit --
  `ifdef DTT
   assign samp_wind = rythm_samp & (reg_tscnt==ttrim_swtick);  //31.1us
   assign samp_latch = rythm_samp & (reg_tscnt==ttrim_sdproc); //31.6us
  `else
   assign samp_wind = rythm_samp & (reg_tscnt==SAMPWINCYC);  //31.1us
   assign samp_latch = rythm_samp & (reg_tscnt==SAMPLTHCYC); //31.6us
  `endif
   assign samp_comm_0 = samp_wind & (reg_xfcnt==COMMCYC0);  //least bit
   assign samp_comm_1 = samp_wind & (reg_xfcnt==COMMCYC1);
   assign samp_comm_2 = samp_wind & (reg_xfcnt==COMMCYC2);
   assign samp_comm_3 = samp_wind & (reg_xfcnt==COMMCYC3);
   assign samp_comm_4 = samp_wind & (reg_xfcnt==COMMCYC4);
   assign samp_comm_5 = samp_wind & (reg_xfcnt==COMMCYC5);
   assign samp_comm_6 = samp_wind & (reg_xfcnt==COMMCYC6);
   assign samp_comm_7 = samp_wind & (reg_xfcnt==COMMCYC7);
   assign comm_fth = rythm_samp & samp_latch & (reg_xfcnt==COMMCYC7);
   assign comm_rst = !owpo_rstn | owrc_end | owfc_end | comm_clr;
   //assign comm_clr = (phase_owrc & tscnt_samp & reg_rcmiss) | ownm_mrst;
   assign comm_clr = ownm_mrst;
  `ifdef MONO
   assign comm_ena = samp_comm_0 | samp_comm_1 | samp_comm_2 |
                     samp_comm_3 | samp_comm_4 | samp_comm_5 |
                     samp_comm_6 | samp_comm_7;
   always @(posedge clk_2m4) begin
      if (comm_rst) begin
         reg_fetch <= COMMREG_DEF;
      end else begin
         if (comm_ena) begin
            if (samp_comm_0) begin
               reg_fetch[0] <= reg_dq_2;
            end
            if (samp_comm_1) begin
               reg_fetch[1] <= reg_dq_2;
            end
            if (samp_comm_2) begin
               reg_fetch[2] <= reg_dq_2;
            end
            if (samp_comm_3) begin
               reg_fetch[3] <= reg_dq_2;
            end
            if (samp_comm_4) begin
               reg_fetch[4] <= reg_dq_2;
            end
            if (samp_comm_5) begin
               reg_fetch[5] <= reg_dq_2;
            end
            if (samp_comm_6) begin
               reg_fetch[6] <= reg_dq_2;
            end
            if (samp_comm_7) begin
               reg_fetch[7] <= reg_dq_2;
            end
         end
      end
   end
  `endif

   //------------------------------------------------------------------
   assign phase_rcsr = reg_comm==OWRC_SearchROM;   // Search ROM
   assign phase_rcrr = reg_comm==OWRC_ReadROM;     // Read ROM
   assign phase_rcmr = reg_comm==OWRC_MatchROM;    // Match ROM
   assign phase_rckr = reg_comm==OWRC_SkipROM;     // Skip ROM
   assign phase_rcas = reg_comm==OWRC_AlarmSearch; // Alarm Search
   assign phase_rcsm = reg_comm==OWRC_SetupROM;    // Setup ROM
   assign phase_fcct = reg_comm==OWFC_ConvertT;    // Convert T
   assign phase_fcwr = reg_comm==OWFC_WriteReg;    // Write Register
   assign phase_fcrr = reg_comm==OWFC_ReadReg;     // Read Register
   assign phase_fccr = reg_comm==OWFC_CopyReg;     // Copy Register
   assign phase_fcre = reg_comm==OWFC_RecallE2;    // Recall EEPROM
   assign phase_rppm = reg_comm==OWFC_ReadPPM;     // Read PPM
   assign phase_alarm = phase_rcas & reg_alarm;
   always @(posedge clk_2m4) begin
      if (comm_rst) begin
         reg_comm <= COMMREG_DEF;
      end else begin
         if (comm_fth) begin
            reg_comm <= reg_fetch;
         end
      end
   end

   //-- romcode[63:0] register circuit --
  `ifdef MONO
   assign samp_urom_00 = samp_latch & smrom_00;
   assign samp_urom_01 = samp_latch & smrom_01;
   assign samp_urom_02 = samp_latch & smrom_02;
   assign samp_urom_03 = samp_latch & smrom_03;
   assign samp_urom_04 = samp_latch & smrom_04;
   assign samp_urom_05 = samp_latch & smrom_05;
   assign samp_urom_06 = samp_latch & smrom_06;
   assign samp_urom_07 = samp_latch & smrom_07;
   assign samp_urom_08 = samp_latch & smrom_08;
   assign samp_urom_09 = samp_latch & smrom_09;
   assign samp_urom_10 = samp_latch & smrom_10;
   assign samp_urom_11 = samp_latch & smrom_11;
   assign samp_urom_12 = samp_latch & smrom_12;
   assign samp_urom_13 = samp_latch & smrom_13;
   assign samp_urom_14 = samp_latch & smrom_14;
   assign samp_urom_15 = samp_latch & smrom_15;
   assign samp_urom_16 = samp_latch & smrom_16;
   assign samp_urom_17 = samp_latch & smrom_17;
   assign samp_urom_18 = samp_latch & smrom_18;
   assign samp_urom_19 = samp_latch & smrom_19;
   assign samp_urom_20 = samp_latch & smrom_20;
   assign samp_urom_21 = samp_latch & smrom_21;
   assign samp_urom_22 = samp_latch & smrom_22;
   assign samp_urom_23 = samp_latch & smrom_23;
   assign samp_urom_24 = samp_latch & smrom_24;
   assign samp_urom_25 = samp_latch & smrom_25;
   assign samp_urom_26 = samp_latch & smrom_26;
   assign samp_urom_27 = samp_latch & smrom_27;
   assign samp_urom_28 = samp_latch & smrom_28;
   assign samp_urom_29 = samp_latch & smrom_29;
   assign samp_urom_30 = samp_latch & smrom_30;
   assign samp_urom_31 = samp_latch & smrom_31;
   assign samp_urom_32 = samp_latch & smrom_32;
   assign samp_urom_33 = samp_latch & smrom_33;
   assign samp_urom_34 = samp_latch & smrom_34;
   assign samp_urom_35 = samp_latch & smrom_35;
   assign samp_urom_36 = samp_latch & smrom_36;
   assign samp_urom_37 = samp_latch & smrom_37;
   assign samp_urom_38 = samp_latch & smrom_38;
   assign samp_urom_39 = samp_latch & smrom_39;
   assign samp_urom_40 = samp_latch & smrom_40;
   assign samp_urom_41 = samp_latch & smrom_41;
   assign samp_urom_42 = samp_latch & smrom_42;
   assign samp_urom_43 = samp_latch & smrom_43;
   assign samp_urom_44 = samp_latch & smrom_44;
   assign samp_urom_45 = samp_latch & smrom_45;
   assign samp_urom_46 = samp_latch & smrom_46;
   assign samp_urom_47 = samp_latch & smrom_47;
   assign samp_urom_48 = samp_latch & smrom_48;
   assign samp_urom_49 = samp_latch & smrom_49;
   assign samp_urom_50 = samp_latch & smrom_50;
   assign samp_urom_51 = samp_latch & smrom_51;
   assign samp_urom_52 = samp_latch & smrom_52;
   assign samp_urom_53 = samp_latch & smrom_53;
   assign samp_urom_54 = samp_latch & smrom_54;
   assign samp_urom_55 = samp_latch & smrom_55;
   assign samp_urom_56 = samp_latch & smrom_56;
   assign samp_urom_57 = samp_latch & smrom_57;
   assign samp_urom_58 = samp_latch & smrom_58;
   assign samp_urom_59 = samp_latch & smrom_59;
   assign samp_urom_60 = samp_latch & smrom_60;
   assign samp_urom_61 = samp_latch & smrom_61;
   assign samp_urom_62 = samp_latch & smrom_62;
   assign samp_urom_63 = samp_latch & smrom_63;
  `endif

   //------------------------------------------------------------------
   assign smrom_00 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC00);
   assign smrom_01 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC01);
   assign smrom_02 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC02);
   assign smrom_03 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC03);
   assign smrom_04 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC04);
   assign smrom_05 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC05);
   assign smrom_06 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC06);
   assign smrom_07 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC07);
   assign smrom_08 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC08);
   assign smrom_09 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC09);
   assign smrom_10 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC10);
   assign smrom_11 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC11);
   assign smrom_12 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC12);
   assign smrom_13 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC13);
   assign smrom_14 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC14);
   assign smrom_15 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC15);
   assign smrom_16 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC16);
   assign smrom_17 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC17);
   assign smrom_18 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC18);
   assign smrom_19 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC19);
   assign smrom_20 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC20);
   assign smrom_21 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC21);
   assign smrom_22 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC22);
   assign smrom_23 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC23);
   assign smrom_24 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC24);
   assign smrom_25 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC25);
   assign smrom_26 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC26);
   assign smrom_27 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC27);
   assign smrom_28 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC28);
   assign smrom_29 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC29);
   assign smrom_30 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC30);
   assign smrom_31 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC31);
   assign smrom_32 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC32);
   assign smrom_33 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC33);
   assign smrom_34 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC34);
   assign smrom_35 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC35);
   assign smrom_36 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC36);
   assign smrom_37 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC37);
   assign smrom_38 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC38);
   assign smrom_39 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC39);
   assign smrom_40 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC40);
   assign smrom_41 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC41);
   assign smrom_42 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC42);
   assign smrom_43 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC43);
   assign smrom_44 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC44);
   assign smrom_45 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC45);
   assign smrom_46 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC46);
   assign smrom_47 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC47);
   assign smrom_48 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC48);
   assign smrom_49 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC49);
   assign smrom_50 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC50);
   assign smrom_51 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC51);
   assign smrom_52 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC52);
   assign smrom_53 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC53);
   assign smrom_54 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC54);
   assign smrom_55 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC55);
   assign smrom_56 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC56);
   assign smrom_57 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC57);
   assign smrom_58 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC58);
   assign smrom_59 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC59);
   assign smrom_60 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC60);
   assign smrom_61 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC61);
   assign smrom_62 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC62);
   assign smrom_63 = phase_owrc & phase_rcsm & (reg_xfcnt==ROMCYC63);

   //------------------------------------------------------------------
  `ifdef MONO
   assign rst_romcode = !owpo_rstn; //!owwu_rstn
   assign ena_romcode = samp_urom_00 | samp_urom_01 | samp_urom_02 |
                        samp_urom_03 | samp_urom_04 | samp_urom_05 |
                        samp_urom_06 | samp_urom_07 | samp_urom_08 |
                        samp_urom_09 | samp_urom_10 | samp_urom_11 |
                        samp_urom_12 | samp_urom_13 | samp_urom_14 |
                        samp_urom_15 | samp_urom_16 | samp_urom_17 |
                        samp_urom_18 | samp_urom_19 | samp_urom_20 |
                        samp_urom_21 | samp_urom_22 | samp_urom_23 |
                        samp_urom_24 | samp_urom_25 | samp_urom_26 |
                        samp_urom_27 | samp_urom_28 | samp_urom_29 |
                        samp_urom_30 | samp_urom_31 | samp_urom_32 |
                        samp_urom_33 | samp_urom_34 | samp_urom_35 |
                        samp_urom_36 | samp_urom_37 | samp_urom_38 |
                        samp_urom_39 | samp_urom_40 | samp_urom_41 |
                        samp_urom_42 | samp_urom_43 | samp_urom_44 |
                        samp_urom_45 | samp_urom_46 | samp_urom_47 |
                        samp_urom_48 | samp_urom_49 | samp_urom_50 |
                        samp_urom_51 | samp_urom_52 | samp_urom_53 |
                        samp_urom_54 | samp_urom_55 | samp_urom_56 |
                        samp_urom_57 | samp_urom_58 | samp_urom_59 |
                        samp_urom_60 | samp_urom_61 | samp_urom_62 |
                        samp_urom_63;
   //------------------------------------------------------------------
   always @(posedge clk_2m4) begin
      if (rst_romcode) begin
         reg_romcode <= ROMCODE_DEF;
      end else begin
         if (ena_romcode) begin
            if (samp_urom_00) begin
               reg_romcode[0] <= reg_dqin;
            end
            if (samp_urom_01) begin
               reg_romcode[1] <= reg_dqin;
            end
            if (samp_urom_02) begin
               reg_romcode[2] <= reg_dqin;
            end
            if (samp_urom_03) begin
               reg_romcode[3] <= reg_dqin;
            end
            if (samp_urom_04) begin
               reg_romcode[4] <= reg_dqin;
            end
            if (samp_urom_05) begin
               reg_romcode[5] <= reg_dqin;
            end
            if (samp_urom_06) begin
               reg_romcode[6] <= reg_dqin;
            end
            if (samp_urom_07) begin
               reg_romcode[7] <= reg_dqin;
            end
            if (samp_urom_08) begin
               reg_romcode[8] <= reg_dqin;
            end
            if (samp_urom_09) begin
               reg_romcode[9] <= reg_dqin;
            end
            if (samp_urom_10) begin
               reg_romcode[10] <= reg_dqin;
            end
            if (samp_urom_11) begin
               reg_romcode[11] <= reg_dqin;
            end
            if (samp_urom_12) begin
               reg_romcode[12] <= reg_dqin;
            end
            if (samp_urom_13) begin
               reg_romcode[13] <= reg_dqin;
            end
            if (samp_urom_14) begin
               reg_romcode[14] <= reg_dqin;
            end
            if (samp_urom_15) begin
               reg_romcode[15] <= reg_dqin;
            end
            if (samp_urom_16) begin
               reg_romcode[16] <= reg_dqin;
            end
            if (samp_urom_17) begin
               reg_romcode[17] <= reg_dqin;
            end
            if (samp_urom_18) begin
               reg_romcode[18] <= reg_dqin;
            end
            if (samp_urom_19) begin
               reg_romcode[19] <= reg_dqin;
            end
            if (samp_urom_20) begin
               reg_romcode[20] <= reg_dqin;
            end
            if (samp_urom_21) begin
               reg_romcode[21] <= reg_dqin;
            end
            if (samp_urom_22) begin
               reg_romcode[22] <= reg_dqin;
            end
            if (samp_urom_23) begin
               reg_romcode[23] <= reg_dqin;
            end
            if (samp_urom_24) begin
               reg_romcode[24] <= reg_dqin;
            end
            if (samp_urom_25) begin
               reg_romcode[25] <= reg_dqin;
            end
            if (samp_urom_26) begin
               reg_romcode[26] <= reg_dqin;
            end
            if (samp_urom_27) begin
               reg_romcode[27] <= reg_dqin;
            end
            if (samp_urom_28) begin
               reg_romcode[28] <= reg_dqin;
            end
            if (samp_urom_29) begin
               reg_romcode[29] <= reg_dqin;
            end
            if (samp_urom_30) begin
               reg_romcode[30] <= reg_dqin;
            end
            if (samp_urom_31) begin
               reg_romcode[31] <= reg_dqin;
            end
            if (samp_urom_32) begin
               reg_romcode[32] <= reg_dqin;
            end
            if (samp_urom_33) begin
               reg_romcode[33] <= reg_dqin;
            end
            if (samp_urom_34) begin
               reg_romcode[34] <= reg_dqin;
            end
            if (samp_urom_35) begin
               reg_romcode[35] <= reg_dqin;
            end
            if (samp_urom_36) begin
               reg_romcode[36] <= reg_dqin;
            end
            if (samp_urom_37) begin
               reg_romcode[37] <= reg_dqin;
            end
            if (samp_urom_38) begin
               reg_romcode[38] <= reg_dqin;
            end
            if (samp_urom_39) begin
               reg_romcode[39] <= reg_dqin;
            end
            if (samp_urom_40) begin
               reg_romcode[40] <= reg_dqin;
            end
            if (samp_urom_41) begin
               reg_romcode[41] <= reg_dqin;
            end
            if (samp_urom_42) begin
               reg_romcode[42] <= reg_dqin;
            end
            if (samp_urom_43) begin
               reg_romcode[43] <= reg_dqin;
            end
            if (samp_urom_44) begin
               reg_romcode[44] <= reg_dqin;
            end
            if (samp_urom_45) begin
               reg_romcode[45] <= reg_dqin;
            end
            if (samp_urom_46) begin
               reg_romcode[46] <= reg_dqin;
            end
            if (samp_urom_47) begin
               reg_romcode[47] <= reg_dqin;
            end
            if (samp_urom_48) begin
               reg_romcode[48] <= reg_dqin;
            end
            if (samp_urom_49) begin
               reg_romcode[49] <= reg_dqin;
            end
            if (samp_urom_50) begin
               reg_romcode[50] <= reg_dqin;
            end
            if (samp_urom_51) begin
               reg_romcode[51] <= reg_dqin;
            end
            if (samp_urom_52) begin
               reg_romcode[52] <= reg_dqin;
            end
            if (samp_urom_53) begin
               reg_romcode[53] <= reg_dqin;
            end
            if (samp_urom_54) begin
               reg_romcode[54] <= reg_dqin;
            end
            if (samp_urom_55) begin
               reg_romcode[55] <= reg_dqin;
            end
            if (samp_urom_56) begin
               reg_romcode[56] <= reg_dqin;
            end
            if (samp_urom_57) begin
               reg_romcode[57] <= reg_dqin;
            end
            if (samp_urom_58) begin
               reg_romcode[58] <= reg_dqin;
            end
            if (samp_urom_59) begin
               reg_romcode[59] <= reg_dqin;
            end
            if (samp_urom_60) begin
               reg_romcode[60] <= reg_dqin;
            end
            if (samp_urom_61) begin
               reg_romcode[61] <= reg_dqin;
            end
            if (samp_urom_62) begin
               reg_romcode[62] <= reg_dqin;
            end
            if (samp_urom_63) begin
               reg_romcode[63] <= reg_dqin;
            end
         end
      end
   end
  `endif

   //-- high alarm trigger register circuit --
  `ifdef MONO
   assign samp_th_0 = phase_owfc & samp_latch & (reg_xfcnt==THACYC0);
   assign samp_th_1 = phase_owfc & samp_latch & (reg_xfcnt==THACYC1);
   assign samp_th_2 = phase_owfc & samp_latch & (reg_xfcnt==THACYC2);
   assign samp_th_3 = phase_owfc & samp_latch & (reg_xfcnt==THACYC3);
   assign samp_th_4 = phase_owfc & samp_latch & (reg_xfcnt==THACYC4);
   assign samp_th_5 = phase_owfc & samp_latch & (reg_xfcnt==THACYC5);
   assign samp_th_6 = phase_owfc & samp_latch & (reg_xfcnt==THACYC6);
   assign samp_th_7 = phase_owfc & samp_latch & (reg_xfcnt==THACYC7);
   //------------------------------------------------------------------
   assign rst_th = !owpo_rstn; //!owwu_rstn
   assign ena_th = samp_th_0 | samp_th_1 | samp_th_2 | samp_th_3 |
                   samp_th_4 | samp_th_5 | samp_th_6 | samp_th_7;
   always @(posedge clk_2m4) begin
      if (rst_th) begin
         reg_th <= THAREG_DEF;
      end else begin
         if (ena_th) begin
            if (samp_th_0) begin
               reg_th[0] <= reg_dqin;
            end
            if (samp_th_1) begin
               reg_th[1] <= reg_dqin;
            end
            if (samp_th_2) begin
               reg_th[2] <= reg_dqin;
            end
            if (samp_th_3) begin
               reg_th[3] <= reg_dqin;
            end
            if (samp_th_4) begin
               reg_th[4] <= reg_dqin;
            end
            if (samp_th_5) begin
               reg_th[5] <= reg_dqin;
            end
            if (samp_th_6) begin
               reg_th[6] <= reg_dqin;
            end
            if (samp_th_7) begin
               reg_th[7] <= reg_dqin;
            end
         end
      end
   end
  `endif

   //-- low alarm trigger register circuit --
  `ifdef MONO
   assign samp_tl_0 = phase_owfc & samp_latch & (reg_xfcnt==TLACYC0);
   assign samp_tl_1 = phase_owfc & samp_latch & (reg_xfcnt==TLACYC1);
   assign samp_tl_2 = phase_owfc & samp_latch & (reg_xfcnt==TLACYC2);
   assign samp_tl_3 = phase_owfc & samp_latch & (reg_xfcnt==TLACYC3);
   assign samp_tl_4 = phase_owfc & samp_latch & (reg_xfcnt==TLACYC4);
   assign samp_tl_5 = phase_owfc & samp_latch & (reg_xfcnt==TLACYC5);
   assign samp_tl_6 = phase_owfc & samp_latch & (reg_xfcnt==TLACYC6);
   assign samp_tl_7 = phase_owfc & samp_latch & (reg_xfcnt==TLACYC7);
   //------------------------------------------------------------------
   assign rst_tl = !owpo_rstn; //!owwu_rstn
   assign ena_tl = samp_tl_0 | samp_tl_1 | samp_tl_2 | samp_tl_3 |
                   samp_tl_4 | samp_tl_5 | samp_tl_6 | samp_tl_7;
   always @(posedge clk_2m4) begin
      if (rst_tl) begin
         reg_tl <= TLAREG_DEF;
      end else begin
         if (ena_tl) begin
            if (samp_tl_0) begin
               reg_tl[0] <= reg_dqin;
            end
            if (samp_tl_1) begin
               reg_tl[1] <= reg_dqin;
            end
            if (samp_tl_2) begin
               reg_tl[2] <= reg_dqin;
            end
            if (samp_tl_3) begin
               reg_tl[3] <= reg_dqin;
            end
            if (samp_tl_4) begin
               reg_tl[4] <= reg_dqin;
            end
            if (samp_tl_5) begin
               reg_tl[5] <= reg_dqin;
            end
            if (samp_tl_6) begin
               reg_tl[6] <= reg_dqin;
            end
            if (samp_tl_7) begin
               reg_tl[7] <= reg_dqin;
            end
         end
      end
   end
  `endif

   //-- config register circuit --
  `ifdef MONO
   assign samp_cfg_0 = phase_owfc & samp_latch & (reg_xfcnt==CFGCYC0);
   assign samp_cfg_1 = phase_owfc & samp_latch & (reg_xfcnt==CFGCYC1);
   assign samp_cfg_2 = phase_owfc & samp_latch & (reg_xfcnt==CFGCYC2);
   assign samp_cfg_3 = phase_owfc & samp_latch & (reg_xfcnt==CFGCYC3);
   assign samp_cfg_4 = phase_owfc & samp_latch & (reg_xfcnt==CFGCYC4);
   assign samp_cfg_5 = phase_owfc & samp_latch & (reg_xfcnt==CFGCYC5);
   assign samp_cfg_6 = phase_owfc & samp_latch & (reg_xfcnt==CFGCYC6);
   assign samp_cfg_7 = phase_owfc & samp_latch & (reg_xfcnt==CFGCYC7);
   //------------------------------------------------------------------
   assign rst_config = !owpo_rstn; //!owwu_rstn
   assign ena_config = samp_cfg_0 | samp_cfg_1 | samp_cfg_2 |
                       samp_cfg_3 | samp_cfg_4 | samp_cfg_5 |
                       samp_cfg_6 | samp_cfg_7;
   always @(posedge clk_2m4) begin
      if (rst_config) begin
         reg_config <= CFGREG_DEF;
      end else begin
         if (ena_config) begin
            if (samp_cfg_0) begin
               reg_config[0] <= reg_dqin;
            end
            if (samp_cfg_1) begin
               reg_config[1] <= reg_dqin;
            end
            if (samp_cfg_2) begin
               reg_config[2] <= reg_dqin;
            end
            if (samp_cfg_3) begin
               reg_config[3] <= reg_dqin;
            end
            if (samp_cfg_4) begin
               reg_config[4] <= reg_dqin;
            end
            if (samp_cfg_5) begin
               reg_config[5] <= reg_dqin;
            end
            if (samp_cfg_6) begin
               reg_config[6] <= reg_dqin;
            end
            if (samp_cfg_7) begin
               reg_config[7] <= reg_dqin;
            end
         end
      end
   end
  `endif

   //------------------------------------------------------------------
  `ifdef DTT //TTRIM[11:8]
   // Pulling High Process Time: 10.8us('h01a) -> 39.6us('h05f)
   always @(*) begin
      case (owam_ttrim[11:8])
        4'h0000: ttrim_phproc = PHPCYC00; // 10.8us
        4'h0001: ttrim_phproc = PHPCYC01; // 12.1us
        4'h0010: ttrim_phproc = PHPCYC02; // 13.3us
        4'h0011: ttrim_phproc = PHPCYC03; // 14.6us
        4'h0100: ttrim_phproc = PHPCYC04; // 15.4us
        4'h0101: ttrim_phproc = PHPCYC05; // 16.2us
        4'h0110: ttrim_phproc = PHPCYC06; // 17.1us
        4'h0111: ttrim_phproc = PHPCYC07; // 17.9us
        4'h1000: ttrim_phproc = PHPCYC08; // 18.7us
        4'h1001: ttrim_phproc = PHPCYC09; // 19.6us
        4'h1010: ttrim_phproc = PHPCYC10; // 22.9us
        4'h1011: ttrim_phproc = PHPCYC11; // 26.2us
        4'h1100: ttrim_phproc = PHPCYC12; // 29.6us
        4'h1101: ttrim_phproc = PHPCYC13; // 32.9us
        4'h1110: ttrim_phproc = PHPCYC14; // 36.2us
        4'h1111: ttrim_phproc = PHPCYC15; // 39.6us
        default: ttrim_phproc = PHPCYC09; // 19.6us
      endcase
   end
  `endif

   //------------------------------------------------------------------
  `ifdef DTT //TTRIM[11:8]
   // Pulling Low Process Time: 19.6us('h02f) -> 109.6us('h107)
   always @(*) begin
      case (owam_ttrim[11:8])
        4'h0000: ttrim_plproc = PLPCYC00; // 19.6us
        4'h0001: ttrim_plproc = PLPCYC01; // 22.5us
        4'h0010: ttrim_plproc = PLPCYC02; // 25.4us
        4'h0011: ttrim_plproc = PLPCYC03; // 28.7us
        4'h0100: ttrim_plproc = PLPCYC04; // 32.6us
        4'h0101: ttrim_plproc = PLPCYC05; // 37.5us
        4'h0110: ttrim_plproc = PLPCYC06; // 43.3us
        4'h0111: ttrim_plproc = PLPCYC07; // 48.7us
        4'h1000: ttrim_plproc = PLPCYC08; // 54.1us
        4'h1001: ttrim_plproc = PLPCYC09; // 59.6us
        4'h1010: ttrim_plproc = PLPCYC10; // 67.9us
        4'h1011: ttrim_plproc = PLPCYC11; // 76.2us
        4'h1100: ttrim_plproc = PLPCYC12; // 84.6us
        4'h1101: ttrim_plproc = PLPCYC13; // 92.9us
        4'h1110: ttrim_plproc = PLPCYC14; //101.2us
        4'h1111: ttrim_plproc = PLPCYC15; //109.6us
        default: ttrim_plproc = PLPCYC09; // 59.6us
      endcase
   end
  `endif

   //-- cyclic redundancy check circuit --
   assign crc_fsncyc = smrom_00 | smrom_01 | smrom_02 | smrom_03 |
                       smrom_04 | smrom_05 | smrom_06 | smrom_07 |
                       smrom_08 | smrom_09 | smrom_10 | smrom_11 |
                       smrom_12 | smrom_13 | smrom_14 | smrom_15 |
                       smrom_16 | smrom_17 | smrom_18 | smrom_19 |
                       smrom_20 | smrom_21 | smrom_22 | smrom_23 |
                       smrom_24 | smrom_25 | smrom_26 | smrom_27 |
                       smrom_28 | smrom_29 | smrom_30 | smrom_31 |
                       smrom_32 | smrom_33 | smrom_34 | smrom_35 |
                       smrom_36 | smrom_37 | smrom_38 | smrom_39 |
                       smrom_40 | smrom_41 | smrom_42 | smrom_43 |
                       smrom_44 | smrom_45 | smrom_46 | smrom_47 |
                       smrom_48 | smrom_49 | smrom_50 | smrom_51 |
                       smrom_52 | smrom_53 | smrom_54 | smrom_55;
   assign crc_smcyc = smrom_56 | smrom_57 | smrom_58 | smrom_59 |
                      smrom_60 | smrom_61 | smrom_62 | smrom_63 |
                      crc_fsncyc;
   assign crc_din = (phase_fcrr & dqena_rgcyc & dat_dqout) |
                    (crc_fsncyc & reg_dq_2) |
                    (smrom_56 & reg_crcreg[0]) |
                    (smrom_57 & reg_crcreg[1]) |
                    (smrom_58 & reg_crcreg[2]) |
                    (smrom_59 & reg_crcreg[3]) |
                    (smrom_60 & reg_crcreg[4]) |
                    (smrom_61 & reg_crcreg[5]) |
                    (smrom_62 & reg_crcreg[6]) |
                    (smrom_63 & reg_crcreg[7]);
   always @(*) begin
      dat_crc[0] = reg_crc[7] ^ crc_din;
      dat_crc[1] = reg_crc[0];
      dat_crc[2] = reg_crc[1];
      dat_crc[3] = reg_crc[2];
      dat_crc[4] = reg_crc[3] ^ reg_crc[7] ^ crc_din;
      dat_crc[5] = reg_crc[4] ^ reg_crc[7] ^ crc_din;
      dat_crc[6] = reg_crc[5];
      dat_crc[7] = reg_crc[6];
   end
   assign crc_rst = !owpo_rstn | crc_clr; //!owwu_rstn
  `ifdef DTT
   assign pull_proc = reg_dqout? (reg_tscnt==ttrim_phproc) :
                               (reg_tscnt==ttrim_plproc);
  `else
   assign pull_proc = reg_dqout? (reg_tscnt==PHPROCCYC) :
                               (reg_tscnt==PLPROCCYC);
  `endif
   assign crc_ena = (phase_fcrr & dqena_rgcyc & pull_proc) |
                    (crc_smcyc & samp_wind);
   assign crc_clr = crc_fstcyc & det_neg;
   assign crc_fstcyc = (phase_owfc & (reg_xfcnt==BYTE0BIT0) &
                        phase_fcrr) | smrom_00;
   always @(posedge clk_2m4) begin
      if(crc_rst) begin
         reg_crc <= 8'h00;
      end else if(crc_ena) begin
         reg_crc <= dat_crc;
      end
   end

   //------------------------------------------------------------------
   assign crcerr_cyc = smrom_56 | smrom_57 | smrom_58 | smrom_59 |
                       smrom_60 | smrom_61 | smrom_62 | smrom_63;
   assign crcerr_rst = !owpo_rstn | crcerr_clr; //!owwu_rstn
   assign crcerr_ena = crcerr_cyc & samp_wind & crc_err;
   assign crcerr_clr = smrom_00 & det_neg;
   assign crc_err = (smrom_56 & (reg_crcreg[0]^reg_dq_2)) |
                    (smrom_57 & (reg_crcreg[1]^reg_dq_2)) |
                    (smrom_58 & (reg_crcreg[2]^reg_dq_2)) |
                    (smrom_59 & (reg_crcreg[3]^reg_dq_2)) |
                    (smrom_60 & (reg_crcreg[4]^reg_dq_2)) |
                    (smrom_61 & (reg_crcreg[5]^reg_dq_2)) |
                    (smrom_62 & (reg_crcreg[6]^reg_dq_2)) |
                    (smrom_63 & (reg_crcreg[7]^reg_dq_2));
   always @(posedge clk_2m4) begin
      if(crcerr_rst) begin
         reg_crcerr <= 0;
      end else if(crcerr_ena) begin
         reg_crcerr <= 1;
      end
   end

   //------------------------------------------------------------------
   assign crc_lstcyc = (phase_owfc & (reg_xfcnt==BYTE7BIT7) &
                        phase_fcrr) | smrom_55;
   assign crcreg_rst = !owpo_rstn; //!owwu_rstn
   assign crcreg_ena = crc_lstcyc & (pull_end | samp_latch);
   always @(posedge clk_2m4) begin
      if(crcreg_rst) begin
         reg_crcreg <= 8'h00;
      end else if(crcreg_ena) begin
         reg_crcreg <= {reg_crc[0],reg_crc[1],reg_crc[2],reg_crc[3],
                        reg_crc[4],reg_crc[5],reg_crc[6],reg_crc[7]};
      end
   end

   //-- data output path circuit --
   always @(*) begin
      if (phase_owrc) begin
         case (reg_comm)
           OWRC_SearchROM,OWRC_AlarmSearch: begin
              case (reg_xfcnt)
                ROMBIT00T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[0]; //BIT0
                  `else
                   dat_dqout = owam_romcode[0]; //BIT0
                  `endif
                end
                ROMBIT00F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[0]; //!BIT0
                  `else
                   dat_dqout = !owam_romcode[0]; //!BIT0
                  `endif
                end
                ROMBIT01T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[1]; //BIT1
                  `else
                   dat_dqout = owam_romcode[1]; //BIT1
                  `endif
                end
                ROMBIT01F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[1]; //!BIT1
                  `else
                   dat_dqout = !owam_romcode[1]; //!BIT1
                  `endif
                end
                ROMBIT02T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[2]; //BIT2
                  `else
                   dat_dqout = owam_romcode[2]; //BIT2
                  `endif
                end
                ROMBIT02F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[2]; //!BIT2
                  `else
                   dat_dqout = !owam_romcode[2]; //!BIT2
                  `endif
                end
                ROMBIT03T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[3]; //BIT3
                  `else
                   dat_dqout = owam_romcode[3]; //BIT3
                  `endif
                end
                ROMBIT03F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[3]; //!BIT3
                  `else
                   dat_dqout = !owam_romcode[3]; //!BIT3
                  `endif
                end
                ROMBIT04T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[4]; //BIT4
                  `else
                   dat_dqout = owam_romcode[4]; //BIT4
                  `endif
                end
                ROMBIT04F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[4]; //!BIT4
                  `else
                   dat_dqout = !owam_romcode[4]; //!BIT4
                  `endif
                end
                ROMBIT05T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[5]; //BIT5
                  `else
                   dat_dqout = owam_romcode[5]; //BIT5
                  `endif
                end
                ROMBIT05F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[5]; //!BIT5
                  `else
                   dat_dqout = !owam_romcode[5]; //!BIT5
                  `endif
                end
                ROMBIT06T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[6]; //BIT6
                  `else
                   dat_dqout = owam_romcode[6]; //BIT6
                  `endif
                end
                ROMBIT06F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[6]; //!BIT6
                  `else
                   dat_dqout = !owam_romcode[6]; //!BIT6
                  `endif
                end
                ROMBIT07T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[7]; //BIT7
                  `else
                   dat_dqout = owam_romcode[7]; //BIT7
                  `endif
                end
                ROMBIT07F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[7]; //!BIT7
                  `else
                   dat_dqout = !owam_romcode[7]; //!BIT6
                  `endif
                end
                ROMBIT08T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[8]; //BIT8
                  `else
                   dat_dqout = owam_romcode[8]; //BIT8
                  `endif
                end
                ROMBIT08F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[8]; //!BIT8
                  `else
                   dat_dqout = !owam_romcode[8]; //!BIT8
                  `endif
                end
                ROMBIT09T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[9]; //BIT9
                  `else
                   dat_dqout = owam_romcode[9]; //BIT9
                  `endif
                end
                ROMBIT09F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[9]; //!BIT9
                  `else
                   dat_dqout = !owam_romcode[9]; //!BIT9
                  `endif
                end
                ROMBIT10T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[10]; //BIT10
                  `else
                   dat_dqout = owam_romcode[10]; //BIT10
                  `endif
                end
                ROMBIT10F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[10]; //!BIT10
                  `else
                   dat_dqout = !owam_romcode[10]; //!BIT10
                  `endif
                end
                ROMBIT11T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[11]; //BIT11
                  `else
                   dat_dqout = owam_romcode[11]; //BIT11
                  `endif
                end
                ROMBIT11F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[11]; //!BIT11
                  `else
                   dat_dqout = !owam_romcode[11]; //!BIT11
                  `endif
                end
                ROMBIT12T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[12]; //BIT12
                  `else
                   dat_dqout = owam_romcode[12]; //BIT12
                  `endif
                end
                ROMBIT12F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[12]; //!BIT12
                  `else
                   dat_dqout = !owam_romcode[12]; //!BIT12
                  `endif
                end
                ROMBIT13T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[13]; //BIT13
                  `else
                   dat_dqout = owam_romcode[13]; //BIT13
                  `endif
                end
                ROMBIT13F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[13]; //!BIT13
                  `else
                   dat_dqout = !owam_romcode[13]; //!BIT13
                  `endif
                end
                ROMBIT14T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[14]; //BIT14
                  `else
                   dat_dqout = owam_romcode[14]; //BIT14
                  `endif
                end
                ROMBIT14F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[14]; //!BIT14
                  `else
                   dat_dqout = !owam_romcode[14]; //!BIT14
                  `endif
                end
                ROMBIT15T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[15]; //BIT15
                  `else
                   dat_dqout = owam_romcode[15]; //BIT15
                  `endif
                end
                ROMBIT15F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[15]; //!BIT15
                  `else
                   dat_dqout = !owam_romcode[15]; //!BIT15
                  `endif
                end
                ROMBIT16T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[16]; //BIT16
                  `else
                   dat_dqout = owam_romcode[16]; //BIT16
                  `endif
                end
                ROMBIT16F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[16]; //!BIT16
                  `else
                   dat_dqout = !owam_romcode[16]; //!BIT16
                  `endif
                end
                ROMBIT17T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[17]; //BIT17
                  `else
                   dat_dqout = owam_romcode[17]; //BIT17
                  `endif
                end
                ROMBIT17F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[17]; //!BIT17
                  `else
                   dat_dqout = !owam_romcode[17]; //!BIT17
                  `endif
                end
                ROMBIT18T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[18]; //BIT18
                  `else
                   dat_dqout = owam_romcode[18]; //BIT18
                  `endif
                end
                ROMBIT18F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[18]; //!BIT18
                  `else
                   dat_dqout = !owam_romcode[18]; //!BIT18
                  `endif
                end
                ROMBIT19T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[19]; //BIT19
                  `else
                   dat_dqout = owam_romcode[19]; //BIT19
                  `endif
                end
                ROMBIT19F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[19]; //!BIT19
                  `else
                   dat_dqout = !owam_romcode[19]; //!BIT19
                  `endif
                end
                ROMBIT20T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[20]; //BIT20
                  `else
                   dat_dqout = owam_romcode[20]; //BIT20
                  `endif
                end
                ROMBIT20F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[20]; //!BIT20
                  `else
                   dat_dqout = !owam_romcode[20]; //!BIT20
                  `endif
                end
                ROMBIT21T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[21]; //BIT21
                  `else
                   dat_dqout = owam_romcode[21]; //BIT21
                  `endif
                end
                ROMBIT21F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[21]; //!BIT21
                  `else
                   dat_dqout = !owam_romcode[21]; //!BIT21
                  `endif
                end
                ROMBIT22T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[22]; //BIT22
                  `else
                   dat_dqout = owam_romcode[22]; //BIT22
                  `endif
                end
                ROMBIT22F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[22]; //!BIT22
                  `else
                   dat_dqout = !owam_romcode[22]; //!BIT22
                  `endif
                end
                ROMBIT23T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[23]; //BIT23
                  `else
                   dat_dqout = owam_romcode[23]; //BIT23
                  `endif
                end
                ROMBIT23F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[23]; //!BIT23
                  `else
                   dat_dqout = !owam_romcode[23]; //!BIT23
                  `endif
                end
                ROMBIT24T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[24]; //BIT24
                  `else
                   dat_dqout = owam_romcode[24]; //BIT24
                  `endif
                end
                ROMBIT24F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[24]; //!BIT24
                  `else
                   dat_dqout = !owam_romcode[24]; //!BIT24
                  `endif
                end
                ROMBIT25T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[25]; //BIT25
                  `else
                   dat_dqout = owam_romcode[25]; //BIT25
                  `endif
                end
                ROMBIT25F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[25]; //!BIT25
                  `else
                   dat_dqout = !owam_romcode[25]; //!BIT25
                  `endif
                end
                ROMBIT26T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[26]; //BIT26
                  `else
                   dat_dqout = owam_romcode[26]; //BIT26
                  `endif
                end
                ROMBIT26F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[26]; //!BIT26
                  `else
                   dat_dqout = !owam_romcode[26]; //!BIT26
                  `endif
                end
                ROMBIT27T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[27]; //BIT27
                  `else
                   dat_dqout = owam_romcode[27]; //BIT27
                  `endif
                end
                ROMBIT27F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[27]; //!BIT27
                  `else
                   dat_dqout = !owam_romcode[27]; //!BIT27
                  `endif
                end
                ROMBIT28T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[28]; //BIT28
                  `else
                   dat_dqout = owam_romcode[28]; //BIT28
                  `endif
                end
                ROMBIT28F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[28]; //!BIT28
                  `else
                   dat_dqout = !owam_romcode[28]; //!BIT28
                  `endif
                end
                ROMBIT29T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[29]; //BIT29
                  `else
                   dat_dqout = owam_romcode[29]; //BIT29
                  `endif
                end
                ROMBIT29F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[29]; //!BIT29
                  `else
                   dat_dqout = !owam_romcode[29]; //!BIT29
                  `endif
                end
                ROMBIT30T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[30]; //BIT30
                  `else
                   dat_dqout = owam_romcode[30]; //BIT30
                  `endif
                end
                ROMBIT30F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[30]; //!BIT30
                  `else
                   dat_dqout = !owam_romcode[30]; //!BIT30
                  `endif
                end
                ROMBIT31T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[31]; //BIT31
                  `else
                   dat_dqout = owam_romcode[31]; //BIT31
                  `endif
                end
                ROMBIT31F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[31]; //!BIT31
                  `else
                   dat_dqout = !owam_romcode[31]; //!BIT31
                  `endif
                end
                ROMBIT32T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[32]; //BIT32
                  `else
                   dat_dqout = owam_romcode[32]; //BIT32
                  `endif
                end
                ROMBIT32F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[32]; //!BIT32
                  `else
                   dat_dqout = !owam_romcode[32]; //!BIT32
                  `endif
                end
                ROMBIT33T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[33]; //BIT33
                  `else
                   dat_dqout = owam_romcode[33]; //BIT33
                  `endif
                end
                ROMBIT33F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[33]; //!BIT33
                  `else
                   dat_dqout = !owam_romcode[33]; //!BIT33
                  `endif
                end
                ROMBIT34T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[34]; //BIT34
                  `else
                   dat_dqout = owam_romcode[34]; //BIT34
                  `endif
                end
                ROMBIT34F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[34]; //!BIT34
                  `else
                   dat_dqout = !owam_romcode[34]; //!BIT34
                  `endif
                end
                ROMBIT35T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[35]; //BIT35
                  `else
                   dat_dqout = owam_romcode[35]; //BIT35
                  `endif
                end
                ROMBIT35F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[35]; //!BIT35
                  `else
                   dat_dqout = !owam_romcode[35]; //!BIT35
                  `endif
                end
                ROMBIT36T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[36]; //BIT36
                  `else
                   dat_dqout = owam_romcode[36]; //BIT36
                  `endif
                end
                ROMBIT36F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[36]; //!BIT36
                  `else
                   dat_dqout = !owam_romcode[36]; //!BIT36
                  `endif
                end
                ROMBIT37T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[37]; //BIT37
                  `else
                   dat_dqout = owam_romcode[37]; //BIT37
                  `endif
                end
                ROMBIT37F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[37]; //!BIT37
                  `else
                   dat_dqout = !owam_romcode[37]; //!BIT37
                  `endif
                end
                ROMBIT38T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[38]; //BIT38
                  `else
                   dat_dqout = owam_romcode[38]; //BIT38
                  `endif
                end
                ROMBIT38F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[38]; //!BIT38
                  `else
                   dat_dqout = !owam_romcode[38]; //!BIT38
                  `endif
                end
                ROMBIT39T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[39]; //BIT39
                  `else
                   dat_dqout = owam_romcode[39]; //BIT39
                  `endif
                end
                ROMBIT39F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[39]; //!BIT39
                  `else
                   dat_dqout = !owam_romcode[39]; //!BIT39
                  `endif
                end
                ROMBIT40T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[40]; //BIT40
                  `else
                   dat_dqout = owam_romcode[40]; //BIT40
                  `endif
                end
                ROMBIT40F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[40]; //!BIT40
                  `else
                   dat_dqout = !owam_romcode[40]; //!BIT40
                  `endif
                end
                ROMBIT41T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[41]; //BIT41
                  `else
                   dat_dqout = owam_romcode[41]; //BIT41
                  `endif
                end
                ROMBIT41F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[41]; //!BIT41
                  `else
                   dat_dqout = !owam_romcode[41]; //!BIT41
                  `endif
                end
                ROMBIT42T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[42]; //BIT42
                  `else
                   dat_dqout = owam_romcode[42]; //BIT42
                  `endif
                end
                ROMBIT42F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[42]; //!BIT42
                  `else
                   dat_dqout = !owam_romcode[42]; //BIT42
                  `endif
                end
                ROMBIT43T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[43]; //BIT43
                  `else
                   dat_dqout = owam_romcode[43]; //BIT43
                  `endif
                end
                ROMBIT43F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[43]; //!BIT43
                  `else
                   dat_dqout = !owam_romcode[43]; //!BIT43
                  `endif
                end
                ROMBIT44T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[44]; //BIT44
                  `else
                   dat_dqout = owam_romcode[44]; //BIT44
                  `endif
                end
                ROMBIT44F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[44]; //!BIT44
                  `else
                   dat_dqout = !owam_romcode[44]; //!BIT44
                  `endif
                end
                ROMBIT45T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[45]; //BIT45
                  `else
                   dat_dqout = owam_romcode[45]; //BIT45
                  `endif
                end
                ROMBIT45F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[45]; //!BIT45
                  `else
                   dat_dqout = !owam_romcode[45]; //!BIT45
                  `endif
                end
                ROMBIT46T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[46]; //BIT46
                  `else
                   dat_dqout = owam_romcode[46]; //BIT46
                  `endif
                end
                ROMBIT46F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[46]; //!BIT46
                  `else
                   dat_dqout = !owam_romcode[46]; //!BIT46
                  `endif
                end
                ROMBIT47T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[47]; //BIT47
                  `else
                   dat_dqout = owam_romcode[47]; //BIT47
                  `endif
                end
                ROMBIT47F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[47]; //!BIT47
                  `else
                   dat_dqout = !owam_romcode[47]; //!BIT47
                  `endif
                end
                ROMBIT48T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[48]; //BIT48
                  `else
                   dat_dqout = owam_romcode[48]; //BIT48
                  `endif
                end
                ROMBIT48F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[48]; //!BIT48
                  `else
                   dat_dqout = !owam_romcode[48]; //!BIT48
                  `endif
                end
                ROMBIT49T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[49]; //BIT49
                  `else
                   dat_dqout = owam_romcode[49]; //BIT49
                  `endif
                end
                ROMBIT49F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[49]; //!BIT49
                  `else
                   dat_dqout = !owam_romcode[49]; //!BIT49
                  `endif
                end
                ROMBIT50T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[50]; //BIT50
                  `else
                   dat_dqout = owam_romcode[50]; //BIT50
                  `endif
                end
                ROMBIT50F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[50]; //!BIT50
                  `else
                   dat_dqout = !owam_romcode[50]; //!BIT50
                  `endif
                end
                ROMBIT51T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[51]; //BIT51
                  `else
                   dat_dqout = owam_romcode[51]; //BIT51
                  `endif
                end
                ROMBIT51F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[51]; //!BIT51
                  `else
                   dat_dqout = !owam_romcode[51]; //!BIT51
                  `endif
                end
                ROMBIT52T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[52]; //BIT52
                  `else
                   dat_dqout = owam_romcode[52]; //BIT52
                  `endif
                end
                ROMBIT52F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[52]; //!BIT52
                  `else
                   dat_dqout = !owam_romcode[52]; //!BIT52
                  `endif
                end
                ROMBIT53T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[53]; //BIT53
                  `else
                   dat_dqout = owam_romcode[53]; //BIT53
                  `endif
                end
                ROMBIT53F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[53]; //!BIT53
                  `else
                   dat_dqout = !owam_romcode[53]; //!BIT53
                  `endif
                end
                ROMBIT54T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[54]; //BIT54
                  `else
                   dat_dqout = owam_romcode[54]; //BIT54
                  `endif
                end
                ROMBIT54F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[54]; //!BIT54
                  `else
                   dat_dqout = !owam_romcode[54]; //!BIT54
                  `endif
                end
                ROMBIT55T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[55]; //BIT55
                  `else
                   dat_dqout = owam_romcode[55]; //BIT55
                  `endif
                end
                ROMBIT55F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[55]; //!BIT55
                  `else
                   dat_dqout = !owam_romcode[55]; //!BIT55
                  `endif
                end
                ROMBIT56T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[56]; //BIT56
                  `else
                   dat_dqout = owam_romcode[56]; //BIT56
                  `endif
                end
                ROMBIT56F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[56]; //!BIT56
                  `else
                   dat_dqout = !owam_romcode[56]; //!BIT56
                  `endif
                end
                ROMBIT57T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[57]; //BIT57
                  `else
                   dat_dqout = owam_romcode[57]; //BIT57
                  `endif
                end
                ROMBIT57F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[57]; //!BIT57
                  `else
                   dat_dqout = !owam_romcode[57]; //!BIT57
                  `endif
                end
                ROMBIT58T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[58]; //BIT58
                  `else
                   dat_dqout = owam_romcode[58]; //BIT58
                  `endif
                end
                ROMBIT58F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[58]; //!BIT58
                  `else
                   dat_dqout = !owam_romcode[58]; //!BIT58
                  `endif
                end
                ROMBIT59T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[59]; //BIT59
                  `else
                   dat_dqout = owam_romcode[59]; //BIT59
                  `endif
                end
                ROMBIT59F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[59]; //!BIT59
                  `else
                   dat_dqout = !owam_romcode[59]; //!BIT59
                  `endif
                end
                ROMBIT60T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[60]; //BIT60
                  `else
                   dat_dqout = owam_romcode[60]; //BIT60
                  `endif
                end
                ROMBIT60F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[60]; //!BIT60
                  `else
                   dat_dqout = !owam_romcode[60]; //!BIT60
                  `endif
                end
                ROMBIT61T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[61]; //BIT61
                  `else
                   dat_dqout = owam_romcode[61]; //BIT61
                  `endif
                end
                ROMBIT61F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[61]; //!BIT61
                  `else
                   dat_dqout = !owam_romcode[61]; //!BIT61
                  `endif
                end
                ROMBIT62T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[62]; //BIT62
                  `else
                   dat_dqout = owam_romcode[62]; //BIT62
                  `endif
                end
                ROMBIT62F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[62]; //!BIT62
                  `else
                   dat_dqout = !owam_romcode[62]; //!BIT62
                  `endif
                end
                ROMBIT63T: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[63]; //BIT63
                  `else
                   dat_dqout = owam_romcode[63]; //BIT63
                  `endif
                end
                ROMBIT63F: begin
                  `ifdef MONO
                   dat_dqout = !reg_romcode[63]; //!BIT63
                  `else
                   dat_dqout = !owam_romcode[63]; //!BIT63
                  `endif
                end
                default: begin
                   dat_dqout = 1; //pull-up
                end
              endcase
           end
           OWRC_ReadROM: begin
              case (reg_xfcnt)
                ROMCYC00: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[0]; //BIT0
                  `else
                   dat_dqout = owam_romcode[0]; //BIT0
                  `endif
                end
                ROMCYC01: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[1]; //BIT1
                  `else
                   dat_dqout = owam_romcode[1]; //BIT1
                  `endif
                end
                ROMCYC02: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[2]; //BIT2
                  `else
                   dat_dqout = owam_romcode[2]; //BIT2
                  `endif
                end
                ROMCYC03: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[3]; //BIT3
                  `else
                   dat_dqout = owam_romcode[3]; //BIT3
                  `endif
                end
                ROMCYC04: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[4]; //BIT4
                  `else
                   dat_dqout = owam_romcode[4]; //BIT4
                  `endif
                end
                ROMCYC05: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[5]; //BIT5
                  `else
                   dat_dqout = owam_romcode[5]; //BIT5
                  `endif
                end
                ROMCYC06: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[6]; //BIT6
                  `else
                   dat_dqout = owam_romcode[6]; //BIT6
                  `endif
                end
                ROMCYC07: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[7]; //BIT7
                  `else
                   dat_dqout = owam_romcode[7]; //BIT7
                  `endif
                end
                ROMCYC08: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[8]; //BIT8
                  `else
                   dat_dqout = owam_romcode[8]; //BIT8
                  `endif
                end
                ROMCYC09: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[9]; //BIT9
                  `else
                   dat_dqout = owam_romcode[9]; //BIT9
                  `endif
                end
                ROMCYC10: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[10]; //BIT10
                  `else
                   dat_dqout = owam_romcode[10]; //BIT10
                  `endif
                end
                ROMCYC11: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[11]; //BIT11
                  `else
                   dat_dqout = owam_romcode[11]; //BIT11
                  `endif
                end
                ROMCYC12: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[12]; //BIT12
                  `else
                   dat_dqout = owam_romcode[12]; //BIT12
                  `endif
                end
                ROMCYC13: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[13]; //BIT13
                  `else
                   dat_dqout = owam_romcode[13]; //BIT13
                  `endif
                end
                ROMCYC14: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[14]; //BIT14
                  `else
                   dat_dqout = owam_romcode[14]; //BIT14
                  `endif
                end
                ROMCYC15: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[15]; //BIT15
                  `else
                   dat_dqout = owam_romcode[15]; //BIT15
                  `endif
                end
                ROMCYC16: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[16]; //BIT16
                  `else
                   dat_dqout = owam_romcode[16]; //BIT16
                  `endif
                end
                ROMCYC17: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[17]; //BIT17
                  `else
                   dat_dqout = owam_romcode[17]; //BIT17
                  `endif
                end
                ROMCYC18: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[18]; //BIT18
                  `else
                   dat_dqout = owam_romcode[18]; //BIT18
                  `endif
                end
                ROMCYC19: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[19]; //BIT19
                  `else
                   dat_dqout = owam_romcode[19]; //BIT19
                  `endif
                end
                ROMCYC20: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[20]; //BIT20
                  `else
                   dat_dqout = owam_romcode[20]; //BIT20
                  `endif
                end
                ROMCYC21: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[21]; //BIT21
                  `else
                   dat_dqout = owam_romcode[21]; //BIT21
                  `endif
                end
                ROMCYC22: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[22]; //BIT22
                  `else
                   dat_dqout = owam_romcode[22]; //BIT22
                  `endif
                end
                ROMCYC23: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[23]; //BIT23
                  `else
                   dat_dqout = owam_romcode[23]; //BIT23
                  `endif
                end
                ROMCYC24: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[24]; //BIT24
                  `else
                   dat_dqout = owam_romcode[24]; //BIT24
                  `endif
                end
                ROMCYC25: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[25]; //BIT25
                  `else
                   dat_dqout = owam_romcode[25]; //BIT25
                  `endif
                end
                ROMCYC26: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[26]; //BIT26
                  `else
                   dat_dqout = owam_romcode[26]; //BIT26
                  `endif
                end
                ROMCYC27: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[27]; //BIT27
                  `else
                   dat_dqout = owam_romcode[27]; //BIT27
                  `endif
                end
                ROMCYC28: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[28]; //BIT28
                  `else
                   dat_dqout = owam_romcode[28]; //BIT28
                  `endif
                end
                ROMCYC29: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[29]; //BIT29
                  `else
                   dat_dqout = owam_romcode[29]; //BIT29
                  `endif
                end
                ROMCYC30: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[30]; //BIT30
                  `else
                   dat_dqout = owam_romcode[30]; //BIT30
                  `endif
                end
                ROMCYC31: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[31]; //BIT31
                  `else
                   dat_dqout = owam_romcode[31]; //BIT31
                  `endif
                end
                ROMCYC32: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[32]; //BIT32
                  `else
                   dat_dqout = owam_romcode[32]; //BIT32
                  `endif
                end
                ROMCYC33: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[33]; //BIT33
                  `else
                   dat_dqout = owam_romcode[33]; //BIT33
                  `endif
                end
                ROMCYC34: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[34]; //BIT34
                  `else
                   dat_dqout = owam_romcode[34]; //BIT34
                  `endif
                end
                ROMCYC35: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[35]; //BIT35
                  `else
                   dat_dqout = owam_romcode[35]; //BIT35
                  `endif
                end
                ROMCYC36: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[36]; //BIT36
                  `else
                   dat_dqout = owam_romcode[36]; //BIT36
                  `endif
                end
                ROMCYC37: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[37]; //BIT37
                  `else
                   dat_dqout = owam_romcode[37]; //BIT37
                  `endif
                end
                ROMCYC38: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[38]; //BIT38
                  `else
                   dat_dqout = owam_romcode[38]; //BIT38
                  `endif
                end
                ROMCYC39: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[39]; //BIT39
                  `else
                   dat_dqout = owam_romcode[39]; //BIT39
                  `endif
                end
                ROMCYC40: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[40]; //BIT40
                  `else
                   dat_dqout = owam_romcode[40]; //BIT40
                  `endif
                end
                ROMCYC41: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[41]; //BIT41
                  `else
                   dat_dqout = owam_romcode[41]; //BIT41
                  `endif
                end
                ROMCYC42: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[42]; //BIT42
                  `else
                   dat_dqout = owam_romcode[42]; //BIT42
                  `endif
                end
                ROMCYC43: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[43]; //BIT43
                  `else
                   dat_dqout = owam_romcode[43]; //BIT43
                  `endif
                end
                ROMCYC44: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[44]; //BIT44
                  `else
                   dat_dqout = owam_romcode[44]; //BIT44
                  `endif
                end
                ROMCYC45: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[45]; //BIT45
                  `else
                   dat_dqout = owam_romcode[45]; //BIT45
                  `endif
                end
                ROMCYC46: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[46]; //BIT46
                  `else
                   dat_dqout = owam_romcode[46]; //BIT46
                  `endif
                end
                ROMCYC47: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[47]; //BIT47
                  `else
                   dat_dqout = owam_romcode[47]; //BIT47
                  `endif
                end
                ROMCYC48: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[48]; //BIT48
                  `else
                   dat_dqout = owam_romcode[48]; //BIT48
                  `endif
                end
                ROMCYC49: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[49]; //BIT49
                  `else
                   dat_dqout = owam_romcode[49]; //BIT49
                  `endif
                end
                ROMCYC50: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[50]; //BIT50
                  `else
                   dat_dqout = owam_romcode[50]; //BIT50
                  `endif
                end
                ROMCYC51: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[51]; //BIT51
                  `else
                   dat_dqout = owam_romcode[51]; //BIT51
                  `endif
                end
                ROMCYC52: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[52]; //BIT52
                  `else
                   dat_dqout = owam_romcode[52]; //BIT52
                  `endif
                end
                ROMCYC53: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[53]; //BIT53
                  `else
                   dat_dqout = owam_romcode[53]; //BIT53
                  `endif
                end
                ROMCYC54: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[54]; //BIT54
                  `else
                   dat_dqout = owam_romcode[54]; //BIT54
                  `endif
                end
                ROMCYC55: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[55]; //BIT55
                  `else
                   dat_dqout = owam_romcode[55]; //BIT55
                  `endif
                end
                ROMCYC56: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[56]; //BIT56
                  `else
                   dat_dqout = owam_romcode[56]; //BIT56
                  `endif
                end
                ROMCYC57: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[57]; //BIT57
                  `else
                   dat_dqout = owam_romcode[57]; //BIT57
                  `endif
                end
                ROMCYC58: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[58]; //BIT58
                  `else
                   dat_dqout = owam_romcode[58]; //BIT58
                  `endif
                end
                ROMCYC59: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[59]; //BIT59
                  `else
                   dat_dqout = owam_romcode[59]; //BIT59
                  `endif
                end
                ROMCYC60: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[60]; //BIT60
                  `else
                   dat_dqout = owam_romcode[60]; //BIT60
                  `endif
                end
                ROMCYC61: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[61]; //BIT61
                  `else
                   dat_dqout = owam_romcode[61]; //BIT61
                  `endif
                end
                ROMCYC62: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[62]; //BIT62
                  `else
                   dat_dqout = owam_romcode[62]; //BIT62
                  `endif
                end
                ROMCYC63: begin
                  `ifdef MONO
                   dat_dqout = reg_romcode[63]; //BIT63
                  `else
                   dat_dqout = owam_romcode[63]; //BIT63
                  `endif
                end
                default: begin
                   dat_dqout = 1; //pull-up
                end
              endcase
           end
           default: begin
              dat_dqout = 1; //pull-up
           end
         endcase
      end else if (phase_owfc) begin
         case (reg_comm)
           OWFC_ReadReg: begin
              case (reg_xfcnt)
                BYTE0BIT0: begin
                   dat_dqout = owam_temp[0]; //Byte0-Bit0
                end
                BYTE0BIT1: begin
                   dat_dqout = owam_temp[1]; //Byte0-Bit1
                end
                BYTE0BIT2: begin
                   dat_dqout = owam_temp[2]; //Byte0-Bit2
                end
                BYTE0BIT3: begin
                   dat_dqout = owam_temp[3]; //Byte0-Bit3
                end
                BYTE0BIT4: begin
                   dat_dqout = owam_temp[4]; //Byte0-Bit4
                end
                BYTE0BIT5: begin
                   dat_dqout = owam_temp[5]; //Byte0-Bit5
                end
                BYTE0BIT6: begin
                   dat_dqout = owam_temp[6]; //Byte0-Bit6
                end
                BYTE0BIT7: begin
                   dat_dqout = owam_temp[7]; //Byte0-Bit7
                end
                BYTE1BIT0: begin
                   dat_dqout = owam_temp[8]; //Byte1-Bit0
                end
                BYTE1BIT1: begin
                   dat_dqout = owam_temp[9]; //Byte1-Bit1
                end
                BYTE1BIT2: begin
                   dat_dqout = owam_temp[10]; //Byte1-Bit2
                end
                BYTE1BIT3: begin
                   dat_dqout = owam_temp[11]; //Byte1-Bit3
                end
                BYTE1BIT4: begin
                   dat_dqout = owam_temp[12]; //Byte1-Bit4
                end
                BYTE1BIT5: begin
                   dat_dqout = owam_temp[13]; //Byte1-Bit5
                end
                BYTE1BIT6: begin
                   dat_dqout = owam_temp[14]; //Byte1-Bit6
                end
                BYTE1BIT7: begin
                   dat_dqout = owam_temp[15]; //Byte1-Bit7
                end
                BYTE2BIT0: begin
                  `ifdef MONO
                   dat_dqout = reg_th[0]; //Byte2-Bit0
                  `else
                   dat_dqout = owam_tha[0]; //Byte2-BIT0
                  `endif
                end
                BYTE2BIT1: begin
                  `ifdef MONO
                   dat_dqout = reg_th[1]; //Byte2-Bit1
                  `else
                   dat_dqout = owam_tha[1]; //Byte2-BIT1
                  `endif
                end
                BYTE2BIT2: begin
                  `ifdef MONO
                   dat_dqout = reg_th[2]; //Byte2-Bit2
                  `else
                   dat_dqout = owam_tha[2]; //Byte2-BIT2
                  `endif
                end
                BYTE2BIT3: begin
                  `ifdef MONO
                   dat_dqout = reg_th[3]; //Byte2-Bit3
                  `else
                   dat_dqout = owam_tha[3]; //Byte2-BIT3
                  `endif
                end
                BYTE2BIT4: begin
                  `ifdef MONO
                   dat_dqout = reg_th[4]; //Byte2-Bit4
                  `else
                   dat_dqout = owam_tha[4]; //Byte2-BIT4
                  `endif
                end
                BYTE2BIT5: begin
                  `ifdef MONO
                   dat_dqout = reg_th[5]; //Byte2-Bit5
                  `else
                   dat_dqout = owam_tha[5]; //Byte2-BIT5
                  `endif
                end
                BYTE2BIT6: begin
                  `ifdef MONO
                   dat_dqout = reg_th[6]; //Byte2-Bit6
                  `else
                   dat_dqout = owam_tha[6]; //Byte2-BIT6
                  `endif
                end
                BYTE2BIT7: begin
                  `ifdef MONO
                   dat_dqout = reg_th[7]; //Byte2-Bit7
                  `else
                   dat_dqout = owam_tha[7]; //Byte2-BIT7
                  `endif
                end
                BYTE3BIT0: begin
                  `ifdef MONO
                   dat_dqout = reg_tl[0]; //Byte3-Bit0
                  `else
                   dat_dqout = owam_tla[0]; //Byte3-BIT0
                  `endif
                end
                BYTE3BIT1: begin
                  `ifdef MONO
                   dat_dqout = reg_tl[1]; //Byte3-Bit1
                  `else
                   dat_dqout = owam_tla[1]; //Byte3-BIT1
                  `endif
                end
                BYTE3BIT2: begin
                  `ifdef MONO
                   dat_dqout = reg_tl[2]; //Byte3-Bit2
                  `else
                   dat_dqout = owam_tla[2]; //Byte3-BIT2
                  `endif
                end
                BYTE3BIT3: begin
                  `ifdef MONO
                   dat_dqout = reg_tl[3]; //Byte3-Bit3
                  `else
                   dat_dqout = owam_tla[3]; //Byte3-BIT3
                  `endif
                end
                BYTE3BIT4: begin
                  `ifdef MONO
                   dat_dqout = reg_tl[4]; //Byte3-Bit4
                  `else
                   dat_dqout = owam_tla[4]; //Byte3-BIT4
                  `endif
                end
                BYTE3BIT5: begin
                  `ifdef MONO
                   dat_dqout = reg_tl[5]; //Byte3-Bit5
                  `else
                   dat_dqout = owam_tla[5]; //Byte3-BIT5
                  `endif
                end
                BYTE3BIT6: begin
                  `ifdef MONO
                   dat_dqout = reg_tl[6]; //Byte3-Bit6
                  `else
                   dat_dqout = owam_tla[6]; //Byte3-BIT6
                  `endif
                end
                BYTE3BIT7: begin
                  `ifdef MONO
                   dat_dqout = reg_tl[7]; //Byte3-Bit7
                  `else
                   dat_dqout = owam_tla[7]; //Byte3-BIT7
                  `endif
                end
                BYTE4BIT0: begin
                  `ifdef MONO
                   dat_dqout = reg_config[0]; //Byte4-Bit0
                  `else
                   dat_dqout = owam_cfg[0]; //Byte4-BIT0
                  `endif
                end
                BYTE4BIT1: begin
                  `ifdef MONO
                   dat_dqout = reg_config[1]; //Byte4-Bit1
                  `else
                   dat_dqout = owam_cfg[1]; //Byte4-BIT1
                  `endif
                end
                BYTE4BIT2: begin
                  `ifdef MONO
                   dat_dqout = reg_config[2]; //Byte4-Bit2
                  `else
                   dat_dqout = owam_cfg[2]; //Byte4-BIT2
                  `endif
                end
                BYTE4BIT3: begin
                  `ifdef MONO
                   dat_dqout = reg_config[3]; //Byte4-Bit3
                  `else
                   dat_dqout = owam_cfg[3]; //Byte4-BIT3
                  `endif
                end
                BYTE4BIT4: begin
                  `ifdef MONO
                   dat_dqout = reg_config[4]; //Byte4-Bit4
                  `else
                   dat_dqout = owam_cfg[4]; //Byte4-BIT4
                  `endif
                end
                BYTE4BIT5: begin
                  `ifdef MONO
                   dat_dqout = reg_config[5]; //Byte4-Bit5
                  `else
                   dat_dqout = owam_cfg[5]; //Byte4-BIT5
                  `endif
                end
                BYTE4BIT6: begin
                  `ifdef MONO
                   dat_dqout = reg_config[6]; //Byte4-Bit6
                  `else
                   dat_dqout = owam_cfg[6]; //Byte4-BIT6
                  `endif
                end
                BYTE4BIT7: begin
                  `ifdef MONO
                   dat_dqout = reg_config[7]; //Byte4-Bit7
                  `else
                   dat_dqout = owam_cfg[7]; //Byte4-BIT7
                  `endif
                end
                BYTE5BIT0: begin
                   dat_dqout = owam_byte5[0]; //Byte5-Bit0
                end
                BYTE5BIT1: begin
                   dat_dqout = owam_byte5[1]; //Byte5-Bit1
                end
                BYTE5BIT2: begin
                   dat_dqout = owam_byte5[2]; //Byte5-Bit2
                end
                BYTE5BIT3: begin
                   dat_dqout = owam_byte5[3]; //Byte5-Bit3
                end
                BYTE5BIT4: begin
                   dat_dqout = owam_byte5[4]; //Byte5-Bit4
                end
                BYTE5BIT5: begin
                   dat_dqout = owam_byte5[5]; //Byte5-Bit5
                end
                BYTE5BIT6: begin
                   dat_dqout = owam_byte5[6]; //Byte5-Bit6
                end
                BYTE5BIT7: begin
                   dat_dqout = owam_byte5[7]; //Byte5-Bit7
                end
                BYTE6BIT0: begin
                   dat_dqout = owam_byte6[0]; //Byte6-Bit0
                end
                BYTE6BIT1: begin
                   dat_dqout = owam_byte6[1]; //Byte6-Bit1
                end
                BYTE6BIT2: begin
                   dat_dqout = owam_byte6[2]; //Byte6-Bit2
                end
                BYTE6BIT3: begin
                   dat_dqout = owam_byte6[3]; //Byte6-Bit3
                end
                BYTE6BIT4: begin
                   dat_dqout = owam_byte6[4]; //Byte6-Bit4
                end
                BYTE6BIT5: begin
                   dat_dqout = owam_byte6[5]; //Byte6-Bit5
                end
                BYTE6BIT6: begin
                   dat_dqout = owam_byte6[6]; //Byte6-Bit6
                end
                BYTE6BIT7: begin
                   dat_dqout = owam_byte6[7]; //Byte6-Bit7
                end
                BYTE7BIT0: begin
                   dat_dqout = owam_byte7[0]; //Byte7-Bit0
                end
                BYTE7BIT1: begin
                   dat_dqout = owam_byte7[1]; //Byte7-Bit1
                end
                BYTE7BIT2: begin
                   dat_dqout = owam_byte7[2]; //Byte7-Bit2
                end
                BYTE7BIT3: begin
                   dat_dqout = owam_byte7[3]; //Byte7-Bit3
                end
                BYTE7BIT4: begin
                   dat_dqout = owam_byte7[4]; //Byte7-Bit4
                end
                BYTE7BIT5: begin
                   dat_dqout = owam_byte7[5]; //Byte7-Bit5
                end
                BYTE7BIT6: begin
                   dat_dqout = owam_byte7[6]; //Byte7-Bit6
                end
                BYTE7BIT7: begin
                   dat_dqout = owam_byte7[7]; //Byte7-Bit7
                end
                BYTE8BIT0: begin
                   dat_dqout = reg_crcreg[0]; //Byte8-Bit0
                end
                BYTE8BIT1: begin
                   dat_dqout = reg_crcreg[1]; //Byte8-Bit1
                end
                BYTE8BIT2: begin
                   dat_dqout = reg_crcreg[2]; //Byte8-Bit2
                end
                BYTE8BIT3: begin
                   dat_dqout = reg_crcreg[3]; //Byte8-Bit3
                end
                BYTE8BIT4: begin
                   dat_dqout = reg_crcreg[4]; //Byte8-Bit4
                end
                BYTE8BIT5: begin
                   dat_dqout = reg_crcreg[5]; //Byte8-Bit5
                end
                BYTE8BIT6: begin
                   dat_dqout = reg_crcreg[6]; //Byte8-Bit6
                end
                BYTE8BIT7: begin
                   dat_dqout = reg_crcreg[7]; //Byte8-Bit7
                end
                default: begin
                   dat_dqout = 1; //pull-up
                end
              endcase
           end
           OWFC_ConvertT: begin
              dat_dqout = !reg_convert; //ConvertT:0=in progress,1=done
           end
           OWFC_CopyReg: begin
              dat_dqout = reg_crok_2;  //CopyReg:0=in progress,1=done
           end
           OWFC_RecallE2: begin
              dat_dqout = reg_reok_2; //RecallE2:0=in progress,1=done
           end
           OWFC_ReadPPM: begin
              dat_dqout = reg_ppm; //parasite power mode:1=VDD,0=PPM
           end
           default: begin
              dat_dqout = 1; //pull-up
           end
         endcase
      end else begin
         dat_dqout = 1; //pull-up
      end
   end

   //-- dq output circuit --
   assign dq_out = reg_dqout;
   assign dqout_put = owwf_end;
   assign dqout_rec = owpp_end | (dqena_ena & det_neg);
   always @(posedge clk_2m4) begin
      if (!owpo_rstn) begin
         reg_dqout <= dat_dqout;
      end else begin
         if (dqout_put) begin
            reg_dqout <= 0;
         end else if (dqout_rec) begin
            reg_dqout <= dat_dqout;
         end
      end
   end

   //-- dq enable circuit --
   assign dq_ena = reg_dqena;
   assign dqena_set = owwf_end | (dqena_ena & det_neg);
   assign dqena_clr = owpp_end | (dqena_ena & pull_end);
   assign dqena_ena = dqena_owrc | dqena_owfc;
   always @(posedge clk_2m4) begin
      if (!owpo_rstn) begin
         reg_dqena <= 0;
      end else begin
         if (dqena_set) begin
            reg_dqena <= 1;
         end else if (dqena_clr) begin
            reg_dqena <= 0;
         end
      end
   end

   //------------------------------------------------------------------
   assign dqena_owrc = phase_owrc & (dqena_search | dqena_rdrom);
   assign dqena_search = (phase_rcsr | phase_alarm) & dqena_skcyc;
   assign dqena_skcyc = (reg_xfcnt==ROMBIT00T)|(reg_xfcnt==ROMBIT00F)|
                        (reg_xfcnt==ROMBIT01T)|(reg_xfcnt==ROMBIT01F)|
                        (reg_xfcnt==ROMBIT02T)|(reg_xfcnt==ROMBIT02F)|
                        (reg_xfcnt==ROMBIT03T)|(reg_xfcnt==ROMBIT03F)|
                        (reg_xfcnt==ROMBIT04T)|(reg_xfcnt==ROMBIT04F)|
                        (reg_xfcnt==ROMBIT05T)|(reg_xfcnt==ROMBIT05F)|
                        (reg_xfcnt==ROMBIT06T)|(reg_xfcnt==ROMBIT06F)|
                        (reg_xfcnt==ROMBIT07T)|(reg_xfcnt==ROMBIT07F)|
                        (reg_xfcnt==ROMBIT08T)|(reg_xfcnt==ROMBIT08F)|
                        (reg_xfcnt==ROMBIT09T)|(reg_xfcnt==ROMBIT09F)|
                        (reg_xfcnt==ROMBIT10T)|(reg_xfcnt==ROMBIT10F)|
                        (reg_xfcnt==ROMBIT11T)|(reg_xfcnt==ROMBIT11F)|
                        (reg_xfcnt==ROMBIT12T)|(reg_xfcnt==ROMBIT12F)|
                        (reg_xfcnt==ROMBIT13T)|(reg_xfcnt==ROMBIT13F)|
                        (reg_xfcnt==ROMBIT14T)|(reg_xfcnt==ROMBIT14F)|
                        (reg_xfcnt==ROMBIT15T)|(reg_xfcnt==ROMBIT15F)|
                        (reg_xfcnt==ROMBIT16T)|(reg_xfcnt==ROMBIT16F)|
                        (reg_xfcnt==ROMBIT17T)|(reg_xfcnt==ROMBIT17F)|
                        (reg_xfcnt==ROMBIT18T)|(reg_xfcnt==ROMBIT18F)|
                        (reg_xfcnt==ROMBIT19T)|(reg_xfcnt==ROMBIT19F)|
                        (reg_xfcnt==ROMBIT20T)|(reg_xfcnt==ROMBIT20F)|
                        (reg_xfcnt==ROMBIT21T)|(reg_xfcnt==ROMBIT21F)|
                        (reg_xfcnt==ROMBIT22T)|(reg_xfcnt==ROMBIT22F)|
                        (reg_xfcnt==ROMBIT23T)|(reg_xfcnt==ROMBIT23F)|
                        (reg_xfcnt==ROMBIT24T)|(reg_xfcnt==ROMBIT24F)|
                        (reg_xfcnt==ROMBIT25T)|(reg_xfcnt==ROMBIT25F)|
                        (reg_xfcnt==ROMBIT26T)|(reg_xfcnt==ROMBIT26F)|
                        (reg_xfcnt==ROMBIT27T)|(reg_xfcnt==ROMBIT27F)|
                        (reg_xfcnt==ROMBIT28T)|(reg_xfcnt==ROMBIT28F)|
                        (reg_xfcnt==ROMBIT29T)|(reg_xfcnt==ROMBIT29F)|
                        (reg_xfcnt==ROMBIT30T)|(reg_xfcnt==ROMBIT30F)|
                        (reg_xfcnt==ROMBIT31T)|(reg_xfcnt==ROMBIT31F)|
                        (reg_xfcnt==ROMBIT32T)|(reg_xfcnt==ROMBIT32F)|
                        (reg_xfcnt==ROMBIT33T)|(reg_xfcnt==ROMBIT33F)|
                        (reg_xfcnt==ROMBIT34T)|(reg_xfcnt==ROMBIT34F)|
                        (reg_xfcnt==ROMBIT35T)|(reg_xfcnt==ROMBIT35F)|
                        (reg_xfcnt==ROMBIT36T)|(reg_xfcnt==ROMBIT36F)|
                        (reg_xfcnt==ROMBIT37T)|(reg_xfcnt==ROMBIT37F)|
                        (reg_xfcnt==ROMBIT38T)|(reg_xfcnt==ROMBIT38F)|
                        (reg_xfcnt==ROMBIT39T)|(reg_xfcnt==ROMBIT39F)|
                        (reg_xfcnt==ROMBIT40T)|(reg_xfcnt==ROMBIT40F)|
                        (reg_xfcnt==ROMBIT41T)|(reg_xfcnt==ROMBIT41F)|
                        (reg_xfcnt==ROMBIT42T)|(reg_xfcnt==ROMBIT42F)|
                        (reg_xfcnt==ROMBIT43T)|(reg_xfcnt==ROMBIT43F)|
                        (reg_xfcnt==ROMBIT44T)|(reg_xfcnt==ROMBIT44F)|
                        (reg_xfcnt==ROMBIT45T)|(reg_xfcnt==ROMBIT45F)|
                        (reg_xfcnt==ROMBIT46T)|(reg_xfcnt==ROMBIT46F)|
                        (reg_xfcnt==ROMBIT47T)|(reg_xfcnt==ROMBIT47F)|
                        (reg_xfcnt==ROMBIT48T)|(reg_xfcnt==ROMBIT48F)|
                        (reg_xfcnt==ROMBIT49T)|(reg_xfcnt==ROMBIT49F)|
                        (reg_xfcnt==ROMBIT50T)|(reg_xfcnt==ROMBIT50F)|
                        (reg_xfcnt==ROMBIT51T)|(reg_xfcnt==ROMBIT51F)|
                        (reg_xfcnt==ROMBIT52T)|(reg_xfcnt==ROMBIT52F)|
                        (reg_xfcnt==ROMBIT53T)|(reg_xfcnt==ROMBIT53F)|
                        (reg_xfcnt==ROMBIT54T)|(reg_xfcnt==ROMBIT54F)|
                        (reg_xfcnt==ROMBIT55T)|(reg_xfcnt==ROMBIT55F)|
                        (reg_xfcnt==ROMBIT56T)|(reg_xfcnt==ROMBIT56F)|
                        (reg_xfcnt==ROMBIT57T)|(reg_xfcnt==ROMBIT57F)|
                        (reg_xfcnt==ROMBIT58T)|(reg_xfcnt==ROMBIT58F)|
                        (reg_xfcnt==ROMBIT59T)|(reg_xfcnt==ROMBIT59F)|
                        (reg_xfcnt==ROMBIT60T)|(reg_xfcnt==ROMBIT60F)|
                        (reg_xfcnt==ROMBIT61T)|(reg_xfcnt==ROMBIT61F)|
                        (reg_xfcnt==ROMBIT62T)|(reg_xfcnt==ROMBIT62F)|
                        (reg_xfcnt==ROMBIT63T)|(reg_xfcnt==ROMBIT63F);
   assign dqena_rdrom = phase_rcrr & dqena_rmcyc;
   assign dqena_rmcyc = (reg_xfcnt==ROMCYC00) | (reg_xfcnt==ROMCYC01) |
                        (reg_xfcnt==ROMCYC02) | (reg_xfcnt==ROMCYC03) |
                        (reg_xfcnt==ROMCYC04) | (reg_xfcnt==ROMCYC05) |
                        (reg_xfcnt==ROMCYC06) | (reg_xfcnt==ROMCYC07) |
                        (reg_xfcnt==ROMCYC08) | (reg_xfcnt==ROMCYC09) |
                        (reg_xfcnt==ROMCYC10) | (reg_xfcnt==ROMCYC11) |
                        (reg_xfcnt==ROMCYC12) | (reg_xfcnt==ROMCYC13) |
                        (reg_xfcnt==ROMCYC14) | (reg_xfcnt==ROMCYC15) |
                        (reg_xfcnt==ROMCYC16) | (reg_xfcnt==ROMCYC17) |
                        (reg_xfcnt==ROMCYC18) | (reg_xfcnt==ROMCYC19) |
                        (reg_xfcnt==ROMCYC20) | (reg_xfcnt==ROMCYC21) |
                        (reg_xfcnt==ROMCYC22) | (reg_xfcnt==ROMCYC23) |
                        (reg_xfcnt==ROMCYC24) | (reg_xfcnt==ROMCYC25) |
                        (reg_xfcnt==ROMCYC26) | (reg_xfcnt==ROMCYC27) |
                        (reg_xfcnt==ROMCYC28) | (reg_xfcnt==ROMCYC29) |
                        (reg_xfcnt==ROMCYC30) | (reg_xfcnt==ROMCYC31) |
                        (reg_xfcnt==ROMCYC32) | (reg_xfcnt==ROMCYC33) |
                        (reg_xfcnt==ROMCYC34) | (reg_xfcnt==ROMCYC35) |
                        (reg_xfcnt==ROMCYC36) | (reg_xfcnt==ROMCYC37) |
                        (reg_xfcnt==ROMCYC38) | (reg_xfcnt==ROMCYC39) |
                        (reg_xfcnt==ROMCYC40) | (reg_xfcnt==ROMCYC41) |
                        (reg_xfcnt==ROMCYC42) | (reg_xfcnt==ROMCYC43) |
                        (reg_xfcnt==ROMCYC44) | (reg_xfcnt==ROMCYC45) |
                        (reg_xfcnt==ROMCYC46) | (reg_xfcnt==ROMCYC47) |
                        (reg_xfcnt==ROMCYC48) | (reg_xfcnt==ROMCYC49) |
                        (reg_xfcnt==ROMCYC50) | (reg_xfcnt==ROMCYC51) |
                        (reg_xfcnt==ROMCYC52) | (reg_xfcnt==ROMCYC53) |
                        (reg_xfcnt==ROMCYC54) | (reg_xfcnt==ROMCYC55) |
                        (reg_xfcnt==ROMCYC56) | (reg_xfcnt==ROMCYC57) |
                        (reg_xfcnt==ROMCYC58) | (reg_xfcnt==ROMCYC59) |
                        (reg_xfcnt==ROMCYC60) | (reg_xfcnt==ROMCYC61) |
                        (reg_xfcnt==ROMCYC62) | (reg_xfcnt==ROMCYC63);

   //------------------------------------------------------------------
   assign dqena_owfc = phase_owfc & (dqena_rdreg | dqena_convt |
                                     dqena_copyr | dqena_rece2 |
                                     dqena_rdppm);
   assign dqena_rdreg = phase_fcrr & dqena_rgcyc;
   assign dqena_rgcyc = (reg_xfcnt==BYTE0BIT0)|(reg_xfcnt==BYTE0BIT1)|
                        (reg_xfcnt==BYTE0BIT2)|(reg_xfcnt==BYTE0BIT3)|
                        (reg_xfcnt==BYTE0BIT4)|(reg_xfcnt==BYTE0BIT5)|
                        (reg_xfcnt==BYTE0BIT6)|(reg_xfcnt==BYTE0BIT7)|
                        (reg_xfcnt==BYTE1BIT0)|(reg_xfcnt==BYTE1BIT1)|
                        (reg_xfcnt==BYTE1BIT2)|(reg_xfcnt==BYTE1BIT3)|
                        (reg_xfcnt==BYTE1BIT4)|(reg_xfcnt==BYTE1BIT5)|
                        (reg_xfcnt==BYTE1BIT6)|(reg_xfcnt==BYTE1BIT7)|
                        (reg_xfcnt==BYTE2BIT0)|(reg_xfcnt==BYTE2BIT1)|
                        (reg_xfcnt==BYTE2BIT2)|(reg_xfcnt==BYTE2BIT3)|
                        (reg_xfcnt==BYTE2BIT4)|(reg_xfcnt==BYTE2BIT5)|
                        (reg_xfcnt==BYTE2BIT6)|(reg_xfcnt==BYTE2BIT7)|
                        (reg_xfcnt==BYTE3BIT0)|(reg_xfcnt==BYTE3BIT1)|
                        (reg_xfcnt==BYTE3BIT2)|(reg_xfcnt==BYTE3BIT3)|
                        (reg_xfcnt==BYTE3BIT4)|(reg_xfcnt==BYTE3BIT5)|
                        (reg_xfcnt==BYTE3BIT6)|(reg_xfcnt==BYTE3BIT7)|
                        (reg_xfcnt==BYTE4BIT0)|(reg_xfcnt==BYTE4BIT1)|
                        (reg_xfcnt==BYTE4BIT2)|(reg_xfcnt==BYTE4BIT3)|
                        (reg_xfcnt==BYTE4BIT4)|(reg_xfcnt==BYTE4BIT5)|
                        (reg_xfcnt==BYTE4BIT6)|(reg_xfcnt==BYTE4BIT7)|
                        (reg_xfcnt==BYTE5BIT0)|(reg_xfcnt==BYTE5BIT1)|
                        (reg_xfcnt==BYTE5BIT2)|(reg_xfcnt==BYTE5BIT3)|
                        (reg_xfcnt==BYTE5BIT4)|(reg_xfcnt==BYTE5BIT5)|
                        (reg_xfcnt==BYTE5BIT6)|(reg_xfcnt==BYTE5BIT7)|
                        (reg_xfcnt==BYTE6BIT0)|(reg_xfcnt==BYTE6BIT1)|
                        (reg_xfcnt==BYTE6BIT2)|(reg_xfcnt==BYTE6BIT3)|
                        (reg_xfcnt==BYTE6BIT4)|(reg_xfcnt==BYTE6BIT5)|
                        (reg_xfcnt==BYTE6BIT6)|(reg_xfcnt==BYTE6BIT7)|
                        (reg_xfcnt==BYTE7BIT0)|(reg_xfcnt==BYTE7BIT1)|
                        (reg_xfcnt==BYTE7BIT2)|(reg_xfcnt==BYTE7BIT3)|
                        (reg_xfcnt==BYTE7BIT4)|(reg_xfcnt==BYTE7BIT5)|
                        (reg_xfcnt==BYTE7BIT6)|(reg_xfcnt==BYTE7BIT7)|
                        (reg_xfcnt==BYTE8BIT0)|(reg_xfcnt==BYTE8BIT1)|
                        (reg_xfcnt==BYTE8BIT2)|(reg_xfcnt==BYTE8BIT3)|
                        (reg_xfcnt==BYTE8BIT4)|(reg_xfcnt==BYTE8BIT5)|
                        (reg_xfcnt==BYTE8BIT6)|(reg_xfcnt==BYTE8BIT7);
   assign dqena_convt = phase_fcct;
   assign dqena_copyr = phase_fccr;
   assign dqena_rece2 = phase_fcre;
   assign dqena_rdppm = phase_rppm;

endmodule //onewire_adapter
