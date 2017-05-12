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
// File name            : onewire_params.v
// File contents        : Parameter of One-Wire-Bus Adapter
// Purpose              : Preferences
//                        Patameter File
// Destination project  : N20
// Destination library  : N20_LIB
//---------------------------------------------------------------------
// File Revision        : $Revision$
// File Author          : $Author$
// Last modification    : $Date$
//---------------------------------------------------------------------
parameter OWRC_SearchROM   = 8'hf0;
parameter OWRC_ReadROM     = 8'h33;
parameter OWRC_MatchROM    = 8'h55;
parameter OWRC_SkipROM     = 8'hcc;
parameter OWRC_AlarmSearch = 8'hec;
parameter OWRC_SetupROM    = 8'ha6;

parameter OWFC_ConvertT    = 8'h44;
parameter OWFC_WriteReg    = 8'h4e;
parameter OWFC_ReadReg     = 8'hbe;
parameter OWFC_CopyReg     = 8'h48;
parameter OWFC_RecallE2    = 8'hb8;
parameter OWFC_ReadPPM     = 8'hb4;
//parameter OWFC_FixTiming = 8'h;
//parameter OWFC_ReadTiming = 8'h;
//parameter OWFC_SaveTiming = 8'h;

//---------------------------------------------------------------------
parameter XFLOWWIDTH = 3;
parameter XFLOW_OWFI = 'h0; // idle
parameter XFLOW_OWLP = 'h1; // low power
parameter XFLOW_OWRP = 'h2; // reset pulse
parameter XFLOW_OWWF = 'h3; // wait for
parameter XFLOW_OWPP = 'h4; // presence pulse
parameter XFLOW_OWRC = 'h5; // rom command
parameter XFLOW_OWFC = 'h6; // function command
parameter XFLOW_OWNM = 'h7; // no match

parameter TSLOTWIDTH = 4;
parameter TSLOT_IDLE = 'h0; // timing idle
parameter TSLOT_ACTV = 'h1; // timing start
parameter TSLOT_INIT = 'h2; // initial rhythm
parameter TSLOT_PULL = 'h3; // pulling rhythm
parameter TSLOT_SANK = 'h4; // sankhara gap
parameter TSLOT_ANAT = 'h5; // anatta gap
parameter TSLOT_NIRV = 'h6; // nirvana gap
parameter TSLOT_RENA = 'h7; // renascence slot
parameter TSLOT_SAMP = 'h8; // samples rhythm
parameter TSLOT_TAIL = 'h9; // length slot
parameter TSLOT_MISS = 'ha; // nomatch rhythm

//---------------------------------------------------------------------
parameter XFCNTWIDTH = 8;  // flowchat counter width
parameter TSCNTWIDTH = 12; // timeslot counter width
`ifdef DTT //TTRIM[3:0] -> ttrim_pdhigh
// Presence-Detect High Time: 15us('h024) -> 55us('h084)
parameter PDHCYC00 = 12'h024;   // waitfor 15  us
parameter PDHCYC01 = 12'h02b;   // waitfor 17.9us
parameter PDHCYC02 = 12'h030;   // waitfor 20  us
parameter PDHCYC03 = 12'h035;   // waitfor 22.1us
parameter PDHCYC04 = 12'h043;   // waitfor 27.9us
parameter PDHCYC05 = 12'h046;   // waitfor 29.1us
parameter PDHCYC06 = 12'h048;   // waitfor 30  us
parameter PDHCYC07 = 12'h04a;   // waitfor 30.8us
parameter PDHCYC08 = 12'h04b;   // waitfor 31.2us
parameter PDHCYC09 = 12'h04d;   // waitfor 32.1us (def)
parameter PDHCYC10 = 12'h04f;   // waitfor 32.9us
parameter PDHCYC11 = 12'h052;   // waitfor 34.2us
parameter PDHCYC12 = 12'h054;   // waitfor 35  us
parameter PDHCYC13 = 12'h060;   // waitfor 40  us
parameter PDHCYC14 = 12'h072;   // waitfor 47.5us
parameter PDHCYC15 = 12'h084;   // waitfor 55  us
`else
parameter WAITFORCYC = 12'h04d; // waitfor time 32us
`endif
`ifdef DTT //TTRIM[3:0] -> ttrim_pdlow
// Presence-Detect Low Time: 60us('h090) -> 220us('h210)
parameter PDLCYC00 = 12'h090;   // present 60   us
parameter PDLCYC01 = 12'h0a8;   // present 70   us
parameter PDLCYC02 = 12'h0c0;   // present 80   us
parameter PDLCYC03 = 12'h0d8;   // present 90   us
parameter PDLCYC04 = 12'h0f0;   // present 100  us
parameter PDLCYC05 = 12'h0f5;   // present 102.1us
parameter PDLCYC06 = 12'h0f9;   // present 103.8us
parameter PDLCYC07 = 12'h0fe;   // present 105.8us
parameter PDLCYC08 = 12'h103;   // present 107.9us
parameter PDLCYC09 = 12'h108;   // present 110  us (def)
parameter PDLCYC10 = 12'h10e;   // present 112.5us
parameter PDLCYC11 = 12'h114;   // present 115  us
parameter PDLCYC12 = 12'h11a;   // present 117.5us
parameter PDLCYC13 = 12'h120;   // present 120  us
parameter PDLCYC14 = 12'h1e0;   // present 200  us
parameter PDLCYC15 = 12'h210;   // present 220  us
`else
parameter PRESENTCYC = 12'h108; // present time 110us
`endif

//---------------------------------------------------------------------
`ifdef DTT //TTRIM[7:4] -> ttrim_rpldet
// Reset-pulse Low Detect Time: 180us('h1b0) -> 440us('h420)
parameter RLDCYC00 = 12'h1b0;   // resetpulse > 180us
parameter RLDCYC01 = 12'h1e0;   // resetpulse > 200us
parameter RLDCYC02 = 12'h1f8;   // resetpulse > 210us
parameter RLDCYC03 = 12'h210;   // resetpulse > 220us
parameter RLDCYC04 = 12'h21c;   // resetpulse > 225us
parameter RLDCYC05 = 12'h228;   // resetpulse > 230us
parameter RLDCYC06 = 12'h234;   // resetpulse > 235us
parameter RLDCYC07 = 12'h240;   // resetpulse > 240us
parameter RLDCYC08 = 12'h24c;   // resetpulse > 245us (def)
parameter RLDCYC09 = 12'h258;   // resetpulse > 250us
parameter RLDCYC10 = 12'h264;   // resetpulse > 255us
parameter RLDCYC11 = 12'h270;   // resetpulse > 260us
parameter RLDCYC12 = 12'h288;   // resetpulse > 270us
parameter RLDCYC13 = 12'h360;   // resetpulse > 360us
parameter RLDCYC14 = 12'h3c0;   // resetpulse > 400us
parameter RLDCYC15 = 12'h420;   // resetpulse > 440us
`else
parameter RSTTRIGCYC = 12'h24c; // resetpulse > 245us
`endif

//---------------------------------------------------------------------
`ifdef DTT //TTRIM[11:8] -> ttrim_phproc
// Pulling High Process Time: 10.8us('h01a) -> 39.6us('h05f)
parameter PHPCYC00 = 12'h01a;   // pullhigh process time 10.8us
parameter PHPCYC01 = 12'h01d;   // pullhigh process time 12.1us
parameter PHPCYC02 = 12'h020;   // pullhigh process time 13.3us
parameter PHPCYC03 = 12'h023;   // pullhigh process time 14.6us
parameter PHPCYC04 = 12'h025;   // pullhigh process time 15.4us
parameter PHPCYC05 = 12'h027;   // pullhigh process time 16.2us
parameter PHPCYC06 = 12'h029;   // pullhigh process time 17.1us
parameter PHPCYC07 = 12'h02b;   // pullhigh process time 17.9us
parameter PHPCYC08 = 12'h02d;   // pullhigh process time 18.7us
parameter PHPCYC09 = 12'h02f;   // pullhigh process time 19.6us (def)
parameter PHPCYC10 = 12'h037;   // pullhigh process time 22.9us
parameter PHPCYC11 = 12'h03f;   // pullhigh process time 26.2us
parameter PHPCYC12 = 12'h047;   // pullhigh process time 29.6us
parameter PHPCYC13 = 12'h04f;   // pullhigh process time 32.9us
parameter PHPCYC14 = 12'h057;   // pullhigh process time 36.2us
parameter PHPCYC15 = 12'h05f;   // pullhigh process time 39.6us
`else
parameter PHPROCCYC = 12'h02f;  // pullhigh process time 19.6us
`endif
`ifdef DTT //TTRIM[11:8] -> ttrim_rphigh
// Read-data Pulling High Time: 11.2us('h01b) -> 40us('h060)
parameter RPHCYC00 = 12'h01b;   // pullhigh fix time 11.2us
parameter RPHCYC01 = 12'h01e;   // pullhigh fix time 12.5us
parameter RPHCYC02 = 12'h021;   // pullhigh fix time 13.7us
parameter RPHCYC03 = 12'h024;   // pullhigh fix time 15  us
parameter RPHCYC04 = 12'h026;   // pullhigh fix time 15.8us
parameter RPHCYC05 = 12'h028;   // pullhigh fix time 16.6us
parameter RPHCYC06 = 12'h02a;   // pullhigh fix time 17.5us
parameter RPHCYC07 = 12'h02c;   // pullhigh fix time 18.3us
parameter RPHCYC08 = 12'h02e;   // pullhigh fix time 19.1us
parameter RPHCYC09 = 12'h030;   // pullhigh fix time 20  us (def)
parameter RPHCYC10 = 12'h038;   // pullhigh fix time 23.3us
parameter RPHCYC11 = 12'h040;   // pullhigh fix time 26.6us
parameter RPHCYC12 = 12'h048;   // pullhigh fix time 30  us
parameter RPHCYC13 = 12'h050;   // pullhigh fix time 33.3us
parameter RPHCYC14 = 12'h058;   // pullhigh fix time 36.6us
parameter RPHCYC15 = 12'h060;   // pullhigh fix time 40  us
`else
parameter PULLFIXCYC = 12'h030; // pullhigh fix time 20us
`endif
`ifdef DTT //TTRIM[11:8] -> ttrim_nphigh
// Nirvana Pulling High Time: 11.2us('h01f) -> 40us('h064)
parameter NPHCYC00 = 12'h01f;   // nirvana pullhigh 12.9us
parameter NPHCYC01 = 12'h022;   // nirvana pullhigh 14.1us
parameter NPHCYC02 = 12'h025;   // nirvana pullhigh 15.4us
parameter NPHCYC03 = 12'h028;   // nirvana pullhigh 16.6us
parameter NPHCYC04 = 12'h02a;   // nirvana pullhigh 17.5us
parameter NPHCYC05 = 12'h02c;   // nirvana pullhigh 18.3us
parameter NPHCYC06 = 12'h02e;   // nirvana pullhigh 19.1us
parameter NPHCYC07 = 12'h030;   // nirvana pullhigh 20  us
parameter NPHCYC08 = 12'h032;   // nirvana pullhigh 20.8us
parameter NPHCYC09 = 12'h034;   // nirvana pullhigh 21.6us (def)
parameter NPHCYC10 = 12'h03c;   // nirvana pullhigh 25  us
parameter NPHCYC11 = 12'h044;   // nirvana pullhigh 28.3us
parameter NPHCYC12 = 12'h04c;   // nirvana pullhigh 31.6us
parameter NPHCYC13 = 12'h054;   // nirvana pullhigh 35  us
parameter NPHCYC14 = 12'h05c;   // nirvana pullhigh 38.3us
parameter NPHCYC15 = 12'h064;   // nirvana pullhigh 41.6us
`else
parameter PULLNPHCYC = 12'h034; // nirvana pullhigh reload 20us
`endif

//---------------------------------------------------------------------
`ifdef DTT //TTRIM[11:8] -> ttrim_plproc
// Pulling Low Process Time: 19.6us('h02f) -> 109.6us('h107)
parameter PLPCYC00 = 12'h02f;   // pulllow process time 19.6us
parameter PLPCYC01 = 12'h036;   // pulllow process time 22.5us
parameter PLPCYC02 = 12'h03d;   // pulllow process time 25.4us
parameter PLPCYC03 = 12'h045;   // pulllow process time 28.7us
parameter PLPCYC04 = 12'h04c;   // pulllow process time 32.6us
parameter PLPCYC05 = 12'h05a;   // pulllow process time 37.5us
parameter PLPCYC06 = 12'h068;   // pulllow process time 43.3us
parameter PLPCYC07 = 12'h075;   // pulllow process time 48.7us
parameter PLPCYC08 = 12'h082;   // pulllow process time 54.1us
parameter PLPCYC09 = 12'h08f;   // pulllow process time 59.6us (def)
parameter PLPCYC10 = 12'h0a3;   // pulllow process time 67.9us
parameter PLPCYC11 = 12'h0b7;   // pulllow process time 76.2us
parameter PLPCYC12 = 12'h0cb;   // pulllow process time 84.6us
parameter PLPCYC13 = 12'h0df;   // pulllow process time 92.9us
parameter PLPCYC14 = 12'h0f3;   // pulllow process time101.2us
parameter PLPCYC15 = 12'h107;   // pulllow process time109.6us
`else
parameter PLPROCCYC = 12'h08f;  // pulllow process time 60us
`endif
`ifdef DTT //TTRIM[11:8] -> ttrim_rplow
// Read-data Pulling Low Time: 20us('h030) -> 110us('h108)
parameter RPLCYC00 = 12'h030;   // pulllow time 20  us
parameter RPLCYC01 = 12'h037;   // pulllow time 22.9us
parameter RPLCYC02 = 12'h03e;   // pulllow time 25.8us
parameter RPLCYC03 = 12'h046;   // pulllow time 29.1us
parameter RPLCYC04 = 12'h04d;   // pulllow time 32.1us
parameter RPLCYC05 = 12'h05b;   // pulllow time 37.9us
parameter RPLCYC06 = 12'h069;   // pulllow time 43.7us
parameter RPLCYC07 = 12'h076;   // pulllow time 49.1us
parameter RPLCYC08 = 12'h083;   // pulllow time 54.6us
parameter RPLCYC09 = 12'h090;   // pulllow time 60  us (def)
parameter RPLCYC10 = 12'h0a4;   // pulllow time 68.3us
parameter RPLCYC11 = 12'h0b8;   // pulllow time 76.6us
parameter RPLCYC12 = 12'h0cc;   // pulllow time 85  us
parameter RPLCYC13 = 12'h0e0;   // pulllow time 93.3us
parameter RPLCYC14 = 12'h0f4;   // pulllow time101.6us
parameter RPLCYC15 = 12'h108;   // pulllow time110  us
`else
parameter PULLLOWCYC = 12'h090; // pulllow type time 60us
`endif
`ifdef DTT //TTRIM[11:8] -> ttrim_nplow
// Nirvana Pulling Low Time: 21.6us('h034) -> 111.7us('h10c)
parameter NPLCYC00 = 12'h034;   // nirvana pulllow 21.6us
parameter NPLCYC01 = 12'h03b;   // nirvana pulllow 24.6us
parameter NPLCYC02 = 12'h042;   // nirvana pulllow 27.5us
parameter NPLCYC03 = 12'h04a;   // nirvana pulllow 30.8us
parameter NPLCYC04 = 12'h051;   // nirvana pulllow 33.7us
parameter NPLCYC05 = 12'h05f;   // nirvana pulllow 39.6us
parameter NPLCYC06 = 12'h06d;   // nirvana pulllow 45.4us
parameter NPLCYC07 = 12'h07a;   // nirvana pulllow 50.8us
parameter NPLCYC08 = 12'h087;   // nirvana pulllow 56.2us
parameter NPLCYC09 = 12'h094;   // nirvana pulllow 61.6us (def)
parameter NPLCYC10 = 12'h0a8;   // nirvana pulllow 70  us
parameter NPLCYC11 = 12'h0bc;   // nirvana pulllow 78.3us
parameter NPLCYC12 = 12'h0d0;   // nirvana pulllow 86.6us
parameter NPLCYC13 = 12'h0e4;   // nirvana pulllow 95  us
parameter NPLCYC14 = 12'h0f8;   // nirvana pulllow103.3us
parameter NPLCYC15 = 12'h10c;   // nirvana pulllow111.7us
`else
parameter PULLNIRCYC = 12'h094; // nirvana pulllow reload 61.6us
`endif

//---------------------------------------------------------------------
`ifdef DTT //TTRIM[15:12] -> ttrim_swtick
// Sample Window Tick: 11.6us('h01c) -> 89.1us('h0d6)
parameter SWTCYC00 = 12'h01c;   // sample window 11.6us
parameter SWTCYC01 = 12'h022;   // sample window 14.1us
parameter SWTCYC02 = 12'h028;   // sample window 16.6us
parameter SWTCYC03 = 12'h02e;   // sample window 19.1us
parameter SWTCYC04 = 12'h034;   // sample window 21.6us
parameter SWTCYC05 = 12'h03a;   // sample window 24.1us
parameter SWTCYC06 = 12'h040;   // sample window 26.6us
parameter SWTCYC07 = 12'h046;   // sample window 29.1us
parameter SWTCYC08 = 12'h04b;   // sample window 31.2us (def)
parameter SWTCYC09 = 12'h051;   // sample window 33.7us
parameter SWTCYC10 = 12'h057;   // sample window 36.2us
parameter SWTCYC11 = 12'h05e;   // sample window 39.1us
parameter SWTCYC12 = 12'h076;   // sample window 49.1us
parameter SWTCYC13 = 12'h08e;   // sample window 59.1us
parameter SWTCYC14 = 12'h0a6;   // sample window 69.1us
parameter SWTCYC15 = 12'h0d6;   // sample window 89.1us
`else
parameter SAMPWINCYC = 12'h04b; // samplewindow 31.1us
`endif
`ifdef DTT //TTRIM[15:12] -> ttrim_sdproc
// Sample Datum Process: 12.1us('h01d) -> 89.6us('h0d7)
parameter SDPCYC00 = 12'h01d;   // sampledatum process 12.1us
parameter SDPCYC01 = 12'h023;   // sampledatum process 14.6us
parameter SDPCYC02 = 12'h029;   // sampledatum process 17.1us
parameter SDPCYC03 = 12'h02f;   // sampledatum process 19.6us
parameter SDPCYC04 = 12'h035;   // sampledatum process 22.1us
parameter SDPCYC05 = 12'h03b;   // sampledatum process 24.6us
parameter SDPCYC06 = 12'h041;   // sampledatum process 27.1us
parameter SDPCYC07 = 12'h047;   // sampledatum process 29.6us
parameter SDPCYC08 = 12'h04c;   // sampledatum process 31.6us (def)
parameter SDPCYC09 = 12'h052;   // sampledatum process 34.1us
parameter SDPCYC10 = 12'h058;   // sampledatum process 36.6us
parameter SDPCYC11 = 12'h05f;   // sampledatum process 39.6us
parameter SDPCYC12 = 12'h077;   // sampledatum process 49.6us
parameter SDPCYC13 = 12'h08f;   // sampledatum process 59.6us
parameter SDPCYC14 = 12'h0a7;   // sampledatum process 69.6us
parameter SDPCYC15 = 12'h0d7;   // sampledatum process 89.6us
`else
parameter SAMPLTHCYC = 12'h04c; // samplelatch 31.6us
`endif
`ifdef DTT //TTRIM[15:12] -> ttrim_spkarm
// Sample Process Karma: 12.5us('h01e) -> 90us('h0d8)
parameter SPKCYC00 = 12'h01e;   // sampleprocess karma 12.5us
parameter SPKCYC01 = 12'h024;   // sampleprocess karma 15  us
parameter SPKCYC02 = 12'h02a;   // sampleprocess karma 17.5us
parameter SPKCYC03 = 12'h030;   // sampleprocess karma 20  us
parameter SPKCYC04 = 12'h036;   // sampleprocess karma 22.5us
parameter SPKCYC05 = 12'h03c;   // sampleprocess karma 25  us
parameter SPKCYC06 = 12'h042;   // sampleprocess karma 27.5us
parameter SPKCYC07 = 12'h048;   // sampleprocess karma 30  us
parameter SPKCYC08 = 12'h04d;   // sampleprocess karma 32.1us (def)
parameter SPKCYC09 = 12'h053;   // sampleprocess karma 34.6us
parameter SPKCYC10 = 12'h059;   // sampleprocess karma 37.1us
parameter SPKCYC11 = 12'h060;   // sampleprocess karma 40  us
parameter SPKCYC12 = 12'h078;   // sampleprocess karma 50  us
parameter SPKCYC13 = 12'h090;   // sampleprocess karma 60  us
parameter SPKCYC14 = 12'h0a8;   // sampleprocess karma 70  us
parameter SPKCYC15 = 12'h0d8;   // sampleprocess karma 90  us
`else
parameter SAMPENDCYC = 12'h04d; // samplecycle end 32us
`endif

//---------------------------------------------------------------------
parameter COMMREG_DEF = 8'h00;
parameter COMMCYC0 = 8'h00; // command timeslot
parameter COMMCYC1 = 8'h01; // command timeslot
parameter COMMCYC2 = 8'h02; // command timeslot
parameter COMMCYC3 = 8'h03; // command timeslot
parameter COMMCYC4 = 8'h04; // command timeslot
parameter COMMCYC5 = 8'h05; // command timeslot
parameter COMMCYC6 = 8'h06; // command timeslot
parameter COMMCYC7 = 8'h07; // command timeslot

//---------------------------------------------------------------------
//parameter ROMCODE_DEF = 64'h0000_0000_0000_0000;
parameter ROMCODE_DEF = 64'h8300_0008_73B3_F528;
parameter ROMCYC00 = 8'h08; // romcode timeslot
parameter ROMCYC01 = 8'h09; // romcode timeslot
parameter ROMCYC02 = 8'h0a; // romcode timeslot
parameter ROMCYC03 = 8'h0b; // romcode timeslot
parameter ROMCYC04 = 8'h0c; // romcode timeslot
parameter ROMCYC05 = 8'h0d; // romcode timeslot
parameter ROMCYC06 = 8'h0e; // romcode timeslot
parameter ROMCYC07 = 8'h0f; // romcode timeslot
parameter ROMCYC08 = 8'h10; // romcode timeslot
parameter ROMCYC09 = 8'h11; // romcode timeslot
parameter ROMCYC10 = 8'h12; // romcode timeslot
parameter ROMCYC11 = 8'h13; // romcode timeslot
parameter ROMCYC12 = 8'h14; // romcode timeslot
parameter ROMCYC13 = 8'h15; // romcode timeslot
parameter ROMCYC14 = 8'h16; // romcode timeslot
parameter ROMCYC15 = 8'h17; // romcode timeslot
parameter ROMCYC16 = 8'h18; // romcode timeslot
parameter ROMCYC17 = 8'h19; // romcode timeslot
parameter ROMCYC18 = 8'h1a; // romcode timeslot
parameter ROMCYC19 = 8'h1b; // romcode timeslot
parameter ROMCYC20 = 8'h1c; // romcode timeslot
parameter ROMCYC21 = 8'h1d; // romcode timeslot
parameter ROMCYC22 = 8'h1e; // romcode timeslot
parameter ROMCYC23 = 8'h1f; // romcode timeslot
parameter ROMCYC24 = 8'h20; // romcode timeslot
parameter ROMCYC25 = 8'h21; // romcode timeslot
parameter ROMCYC26 = 8'h22; // romcode timeslot
parameter ROMCYC27 = 8'h23; // romcode timeslot
parameter ROMCYC28 = 8'h24; // romcode timeslot
parameter ROMCYC29 = 8'h25; // romcode timeslot
parameter ROMCYC30 = 8'h26; // romcode timeslot
parameter ROMCYC31 = 8'h27; // romcode timeslot
parameter ROMCYC32 = 8'h28; // romcode timeslot
parameter ROMCYC33 = 8'h29; // romcode timeslot
parameter ROMCYC34 = 8'h2a; // romcode timeslot
parameter ROMCYC35 = 8'h2b; // romcode timeslot
parameter ROMCYC36 = 8'h2c; // romcode timeslot
parameter ROMCYC37 = 8'h2d; // romcode timeslot
parameter ROMCYC38 = 8'h2e; // romcode timeslot
parameter ROMCYC39 = 8'h2f; // romcode timeslot
parameter ROMCYC40 = 8'h30; // romcode timeslot
parameter ROMCYC41 = 8'h31; // romcode timeslot
parameter ROMCYC42 = 8'h32; // romcode timeslot
parameter ROMCYC43 = 8'h33; // romcode timeslot
parameter ROMCYC44 = 8'h34; // romcode timeslot
parameter ROMCYC45 = 8'h35; // romcode timeslot
parameter ROMCYC46 = 8'h36; // romcode timeslot
parameter ROMCYC47 = 8'h37; // romcode timeslot
parameter ROMCYC48 = 8'h38; // romcode timeslot
parameter ROMCYC49 = 8'h39; // romcode timeslot
parameter ROMCYC50 = 8'h3a; // romcode timeslot
parameter ROMCYC51 = 8'h3b; // romcode timeslot
parameter ROMCYC52 = 8'h3c; // romcode timeslot
parameter ROMCYC53 = 8'h3d; // romcode timeslot
parameter ROMCYC54 = 8'h3e; // romcode timeslot
parameter ROMCYC55 = 8'h3f; // romcode timeslot
parameter ROMCYC56 = 8'h40; // romcode timeslot
parameter ROMCYC57 = 8'h41; // romcode timeslot
parameter ROMCYC58 = 8'h42; // romcode timeslot
parameter ROMCYC59 = 8'h43; // romcode timeslot
parameter ROMCYC60 = 8'h44; // romcode timeslot
parameter ROMCYC61 = 8'h45; // romcode timeslot
parameter ROMCYC62 = 8'h46; // romcode timeslot
parameter ROMCYC63 = 8'h47; // romcode timeslot

//---------------------------------------------------------------------
parameter ROMBIT00T = 8'h08; // romcode timeslot
parameter ROMBIT00F = 8'h09; // romcode timeslot
parameter ROMBIT00W = 8'h0a; // romcode timeslot
parameter ROMBIT01T = 8'h0b; // romcode timeslot
parameter ROMBIT01F = 8'h0c; // romcode timeslot
parameter ROMBIT01W = 8'h0d; // romcode timeslot
parameter ROMBIT02T = 8'h0e; // romcode timeslot
parameter ROMBIT02F = 8'h0f; // romcode timeslot
parameter ROMBIT02W = 8'h10; // romcode timeslot
parameter ROMBIT03T = 8'h11; // romcode timeslot
parameter ROMBIT03F = 8'h12; // romcode timeslot
parameter ROMBIT03W = 8'h13; // romcode timeslot
parameter ROMBIT04T = 8'h14; // romcode timeslot
parameter ROMBIT04F = 8'h15; // romcode timeslot
parameter ROMBIT04W = 8'h16; // romcode timeslot
parameter ROMBIT05T = 8'h17; // romcode timeslot
parameter ROMBIT05F = 8'h18; // romcode timeslot
parameter ROMBIT05W = 8'h19; // romcode timeslot
parameter ROMBIT06T = 8'h1a; // romcode timeslot
parameter ROMBIT06F = 8'h1b; // romcode timeslot
parameter ROMBIT06W = 8'h1c; // romcode timeslot
parameter ROMBIT07T = 8'h1d; // romcode timeslot
parameter ROMBIT07F = 8'h1e; // romcode timeslot
parameter ROMBIT07W = 8'h1f; // romcode timeslot
parameter ROMBIT08T = 8'h20; // romcode timeslot
parameter ROMBIT08F = 8'h21; // romcode timeslot
parameter ROMBIT08W = 8'h22; // romcode timeslot
parameter ROMBIT09T = 8'h23; // romcode timeslot
parameter ROMBIT09F = 8'h24; // romcode timeslot
parameter ROMBIT09W = 8'h25; // romcode timeslot
parameter ROMBIT10T = 8'h26; // romcode timeslot
parameter ROMBIT10F = 8'h27; // romcode timeslot
parameter ROMBIT10W = 8'h28; // romcode timeslot
parameter ROMBIT11T = 8'h29; // romcode timeslot
parameter ROMBIT11F = 8'h2a; // romcode timeslot
parameter ROMBIT11W = 8'h2b; // romcode timeslot
parameter ROMBIT12T = 8'h2c; // romcode timeslot
parameter ROMBIT12F = 8'h2d; // romcode timeslot
parameter ROMBIT12W = 8'h2e; // romcode timeslot
parameter ROMBIT13T = 8'h2f; // romcode timeslot
parameter ROMBIT13F = 8'h30; // romcode timeslot
parameter ROMBIT13W = 8'h31; // romcode timeslot
parameter ROMBIT14T = 8'h32; // romcode timeslot
parameter ROMBIT14F = 8'h33; // romcode timeslot
parameter ROMBIT14W = 8'h34; // romcode timeslot
parameter ROMBIT15T = 8'h35; // romcode timeslot
parameter ROMBIT15F = 8'h36; // romcode timeslot
parameter ROMBIT15W = 8'h37; // romcode timeslot
parameter ROMBIT16T = 8'h38; // romcode timeslot
parameter ROMBIT16F = 8'h39; // romcode timeslot
parameter ROMBIT16W = 8'h3a; // romcode timeslot
parameter ROMBIT17T = 8'h3b; // romcode timeslot
parameter ROMBIT17F = 8'h3c; // romcode timeslot
parameter ROMBIT17W = 8'h3d; // romcode timeslot
parameter ROMBIT18T = 8'h3e; // romcode timeslot
parameter ROMBIT18F = 8'h3f; // romcode timeslot
parameter ROMBIT18W = 8'h40; // romcode timeslot
parameter ROMBIT19T = 8'h41; // romcode timeslot
parameter ROMBIT19F = 8'h42; // romcode timeslot
parameter ROMBIT19W = 8'h43; // romcode timeslot
parameter ROMBIT20T = 8'h44; // romcode timeslot
parameter ROMBIT20F = 8'h45; // romcode timeslot
parameter ROMBIT20W = 8'h46; // romcode timeslot
parameter ROMBIT21T = 8'h47; // romcode timeslot
parameter ROMBIT21F = 8'h48; // romcode timeslot
parameter ROMBIT21W = 8'h49; // romcode timeslot
parameter ROMBIT22T = 8'h4a; // romcode timeslot
parameter ROMBIT22F = 8'h4b; // romcode timeslot
parameter ROMBIT22W = 8'h4c; // romcode timeslot
parameter ROMBIT23T = 8'h4d; // romcode timeslot
parameter ROMBIT23F = 8'h4e; // romcode timeslot
parameter ROMBIT23W = 8'h4f; // romcode timeslot
parameter ROMBIT24T = 8'h50; // romcode timeslot
parameter ROMBIT24F = 8'h51; // romcode timeslot
parameter ROMBIT24W = 8'h52; // romcode timeslot
parameter ROMBIT25T = 8'h53; // romcode timeslot
parameter ROMBIT25F = 8'h54; // romcode timeslot
parameter ROMBIT25W = 8'h55; // romcode timeslot
parameter ROMBIT26T = 8'h56; // romcode timeslot
parameter ROMBIT26F = 8'h57; // romcode timeslot
parameter ROMBIT26W = 8'h58; // romcode timeslot
parameter ROMBIT27T = 8'h59; // romcode timeslot
parameter ROMBIT27F = 8'h5a; // romcode timeslot
parameter ROMBIT27W = 8'h5b; // romcode timeslot
parameter ROMBIT28T = 8'h5c; // romcode timeslot
parameter ROMBIT28F = 8'h5d; // romcode timeslot
parameter ROMBIT28W = 8'h5e; // romcode timeslot
parameter ROMBIT29T = 8'h5f; // romcode timeslot
parameter ROMBIT29F = 8'h60; // romcode timeslot
parameter ROMBIT29W = 8'h61; // romcode timeslot
parameter ROMBIT30T = 8'h62; // romcode timeslot
parameter ROMBIT30F = 8'h63; // romcode timeslot
parameter ROMBIT30W = 8'h64; // romcode timeslot
parameter ROMBIT31T = 8'h65; // romcode timeslot
parameter ROMBIT31F = 8'h66; // romcode timeslot
parameter ROMBIT31W = 8'h67; // romcode timeslot
parameter ROMBIT32T = 8'h68; // romcode timeslot
parameter ROMBIT32F = 8'h69; // romcode timeslot
parameter ROMBIT32W = 8'h6a; // romcode timeslot
parameter ROMBIT33T = 8'h6b; // romcode timeslot
parameter ROMBIT33F = 8'h6c; // romcode timeslot
parameter ROMBIT33W = 8'h6d; // romcode timeslot
parameter ROMBIT34T = 8'h6e; // romcode timeslot
parameter ROMBIT34F = 8'h6f; // romcode timeslot
parameter ROMBIT34W = 8'h70; // romcode timeslot
parameter ROMBIT35T = 8'h71; // romcode timeslot
parameter ROMBIT35F = 8'h72; // romcode timeslot
parameter ROMBIT35W = 8'h73; // romcode timeslot
parameter ROMBIT36T = 8'h74; // romcode timeslot
parameter ROMBIT36F = 8'h75; // romcode timeslot
parameter ROMBIT36W = 8'h76; // romcode timeslot
parameter ROMBIT37T = 8'h77; // romcode timeslot
parameter ROMBIT37F = 8'h78; // romcode timeslot
parameter ROMBIT37W = 8'h79; // romcode timeslot
parameter ROMBIT38T = 8'h7a; // romcode timeslot
parameter ROMBIT38F = 8'h7b; // romcode timeslot
parameter ROMBIT38W = 8'h7c; // romcode timeslot
parameter ROMBIT39T = 8'h7d; // romcode timeslot
parameter ROMBIT39F = 8'h7e; // romcode timeslot
parameter ROMBIT39W = 8'h7f; // romcode timeslot
parameter ROMBIT40T = 8'h80; // romcode timeslot
parameter ROMBIT40F = 8'h81; // romcode timeslot
parameter ROMBIT40W = 8'h82; // romcode timeslot
parameter ROMBIT41T = 8'h83; // romcode timeslot
parameter ROMBIT41F = 8'h84; // romcode timeslot
parameter ROMBIT41W = 8'h85; // romcode timeslot
parameter ROMBIT42T = 8'h86; // romcode timeslot
parameter ROMBIT42F = 8'h87; // romcode timeslot
parameter ROMBIT42W = 8'h88; // romcode timeslot
parameter ROMBIT43T = 8'h89; // romcode timeslot
parameter ROMBIT43F = 8'h8a; // romcode timeslot
parameter ROMBIT43W = 8'h8b; // romcode timeslot
parameter ROMBIT44T = 8'h8c; // romcode timeslot
parameter ROMBIT44F = 8'h8d; // romcode timeslot
parameter ROMBIT44W = 8'h8e; // romcode timeslot
parameter ROMBIT45T = 8'h8f; // romcode timeslot
parameter ROMBIT45F = 8'h90; // romcode timeslot
parameter ROMBIT45W = 8'h91; // romcode timeslot
parameter ROMBIT46T = 8'h92; // romcode timeslot
parameter ROMBIT46F = 8'h93; // romcode timeslot
parameter ROMBIT46W = 8'h94; // romcode timeslot
parameter ROMBIT47T = 8'h95; // romcode timeslot
parameter ROMBIT47F = 8'h96; // romcode timeslot
parameter ROMBIT47W = 8'h97; // romcode timeslot
parameter ROMBIT48T = 8'h98; // romcode timeslot
parameter ROMBIT48F = 8'h99; // romcode timeslot
parameter ROMBIT48W = 8'h9a; // romcode timeslot
parameter ROMBIT49T = 8'h9b; // romcode timeslot
parameter ROMBIT49F = 8'h9c; // romcode timeslot
parameter ROMBIT49W = 8'h9d; // romcode timeslot
parameter ROMBIT50T = 8'h9e; // romcode timeslot
parameter ROMBIT50F = 8'h9f; // romcode timeslot
parameter ROMBIT50W = 8'ha0; // romcode timeslot
parameter ROMBIT51T = 8'ha1; // romcode timeslot
parameter ROMBIT51F = 8'ha2; // romcode timeslot
parameter ROMBIT51W = 8'ha3; // romcode timeslot
parameter ROMBIT52T = 8'ha4; // romcode timeslot
parameter ROMBIT52F = 8'ha5; // romcode timeslot
parameter ROMBIT52W = 8'ha6; // romcode timeslot
parameter ROMBIT53T = 8'ha7; // romcode timeslot
parameter ROMBIT53F = 8'ha8; // romcode timeslot
parameter ROMBIT53W = 8'ha9; // romcode timeslot
parameter ROMBIT54T = 8'haa; // romcode timeslot
parameter ROMBIT54F = 8'hab; // romcode timeslot
parameter ROMBIT54W = 8'hac; // romcode timeslot
parameter ROMBIT55T = 8'had; // romcode timeslot
parameter ROMBIT55F = 8'hae; // romcode timeslot
parameter ROMBIT55W = 8'haf; // romcode timeslot
parameter ROMBIT56T = 8'hb0; // romcode timeslot
parameter ROMBIT56F = 8'hb1; // romcode timeslot
parameter ROMBIT56W = 8'hb2; // romcode timeslot
parameter ROMBIT57T = 8'hb3; // romcode timeslot
parameter ROMBIT57F = 8'hb4; // romcode timeslot
parameter ROMBIT57W = 8'hb5; // romcode timeslot
parameter ROMBIT58T = 8'hb6; // romcode timeslot
parameter ROMBIT58F = 8'hb7; // romcode timeslot
parameter ROMBIT58W = 8'hb8; // romcode timeslot
parameter ROMBIT59T = 8'hb9; // romcode timeslot
parameter ROMBIT59F = 8'hba; // romcode timeslot
parameter ROMBIT59W = 8'hbb; // romcode timeslot
parameter ROMBIT60T = 8'hbc; // romcode timeslot
parameter ROMBIT60F = 8'hbd; // romcode timeslot
parameter ROMBIT60W = 8'hbe; // romcode timeslot
parameter ROMBIT61T = 8'hbf; // romcode timeslot
parameter ROMBIT61F = 8'hc0; // romcode timeslot
parameter ROMBIT61W = 8'hc1; // romcode timeslot
parameter ROMBIT62T = 8'hc2; // romcode timeslot
parameter ROMBIT62F = 8'hc3; // romcode timeslot
parameter ROMBIT62W = 8'hc4; // romcode timeslot
parameter ROMBIT63T = 8'hc5; // romcode timeslot
parameter ROMBIT63F = 8'hc6; // romcode timeslot
parameter ROMBIT63W = 8'hc7; // romcode timeslot

//---------------------------------------------------------------------
parameter THAREG_DEF = 8'h7d; //+125
parameter THACYC0 = 8'h08; // high alarm trigger timeslot
parameter THACYC1 = 8'h09; // high alarm trigger timeslot
parameter THACYC2 = 8'h0a; // high alarm trigger timeslot
parameter THACYC3 = 8'h0b; // high alarm trigger timeslot
parameter THACYC4 = 8'h0c; // high alarm trigger timeslot
parameter THACYC5 = 8'h0d; // high alarm trigger timeslot
parameter THACYC6 = 8'h0e; // high alarm trigger timeslot
parameter THACYC7 = 8'h0f; // high alarm trigger timeslot

//---------------------------------------------------------------------
parameter TLAREG_DEF = 8'hc9; //-55
parameter TLACYC0 = 8'h10; // low alarm trigger timeslot
parameter TLACYC1 = 8'h11; // low alarm trigger timeslot
parameter TLACYC2 = 8'h12; // low alarm trigger timeslot
parameter TLACYC3 = 8'h13; // low alarm trigger timeslot
parameter TLACYC4 = 8'h14; // low alarm trigger timeslot
parameter TLACYC5 = 8'h15; // low alarm trigger timeslot
parameter TLACYC6 = 8'h16; // low alarm trigger timeslot
parameter TLACYC7 = 8'h17; // low alarm trigger timeslot

//---------------------------------------------------------------------
parameter CFGREG_DEF = 8'hbf; //R2:R0=101,14-bit resolution
parameter CFGCYC0 = 8'h18; // config register timeslot
parameter CFGCYC1 = 8'h19; // config register timeslot
parameter CFGCYC2 = 8'h1a; // config register timeslot
parameter CFGCYC3 = 8'h1b; // config register timeslot
parameter CFGCYC4 = 8'h1c; // config register timeslot
parameter CFGCYC5 = 8'h1d; // config register timeslot
parameter CFGCYC6 = 8'h1e; // config register timeslot
parameter CFGCYC7 = 8'h1f; // config register timeslot

//---------------------------------------------------------------------
parameter BYTE0BIT0 = 8'h08; // register timeslot
parameter BYTE0BIT1 = 8'h09; // register timeslot
parameter BYTE0BIT2 = 8'h0a; // register timeslot
parameter BYTE0BIT3 = 8'h0b; // register timeslot
parameter BYTE0BIT4 = 8'h0c; // register timeslot
parameter BYTE0BIT5 = 8'h0d; // register timeslot
parameter BYTE0BIT6 = 8'h0e; // register timeslot
parameter BYTE0BIT7 = 8'h0f; // register timeslot
parameter BYTE1BIT0 = 8'h10; // register timeslot
parameter BYTE1BIT1 = 8'h11; // register timeslot
parameter BYTE1BIT2 = 8'h12; // register timeslot
parameter BYTE1BIT3 = 8'h13; // register timeslot
parameter BYTE1BIT4 = 8'h14; // register timeslot
parameter BYTE1BIT5 = 8'h15; // register timeslot
parameter BYTE1BIT6 = 8'h16; // register timeslot
parameter BYTE1BIT7 = 8'h17; // register timeslot
parameter BYTE2BIT0 = 8'h18; // register timeslot
parameter BYTE2BIT1 = 8'h19; // register timeslot
parameter BYTE2BIT2 = 8'h1a; // register timeslot
parameter BYTE2BIT3 = 8'h1b; // register timeslot
parameter BYTE2BIT4 = 8'h1c; // register timeslot
parameter BYTE2BIT5 = 8'h1d; // register timeslot
parameter BYTE2BIT6 = 8'h1e; // register timeslot
parameter BYTE2BIT7 = 8'h1f; // register timeslot
parameter BYTE3BIT0 = 8'h20; // register timeslot
parameter BYTE3BIT1 = 8'h21; // register timeslot
parameter BYTE3BIT2 = 8'h22; // register timeslot
parameter BYTE3BIT3 = 8'h23; // register timeslot
parameter BYTE3BIT4 = 8'h24; // register timeslot
parameter BYTE3BIT5 = 8'h25; // register timeslot
parameter BYTE3BIT6 = 8'h26; // register timeslot
parameter BYTE3BIT7 = 8'h27; // register timeslot
parameter BYTE4BIT0 = 8'h28; // register timeslot
parameter BYTE4BIT1 = 8'h29; // register timeslot
parameter BYTE4BIT2 = 8'h2a; // register timeslot
parameter BYTE4BIT3 = 8'h2b; // register timeslot
parameter BYTE4BIT4 = 8'h2c; // register timeslot
parameter BYTE4BIT5 = 8'h2d; // register timeslot
parameter BYTE4BIT6 = 8'h2e; // register timeslot
parameter BYTE4BIT7 = 8'h2f; // register timeslot
parameter BYTE5BIT0 = 8'h30; // register timeslot
parameter BYTE5BIT1 = 8'h31; // register timeslot
parameter BYTE5BIT2 = 8'h32; // register timeslot
parameter BYTE5BIT3 = 8'h33; // register timeslot
parameter BYTE5BIT4 = 8'h34; // register timeslot
parameter BYTE5BIT5 = 8'h35; // register timeslot
parameter BYTE5BIT6 = 8'h36; // register timeslot
parameter BYTE5BIT7 = 8'h37; // register timeslot
parameter BYTE6BIT0 = 8'h38; // register timeslot
parameter BYTE6BIT1 = 8'h39; // register timeslot
parameter BYTE6BIT2 = 8'h3a; // register timeslot
parameter BYTE6BIT3 = 8'h3b; // register timeslot
parameter BYTE6BIT4 = 8'h3c; // register timeslot
parameter BYTE6BIT5 = 8'h3d; // register timeslot
parameter BYTE6BIT6 = 8'h3e; // register timeslot
parameter BYTE6BIT7 = 8'h3f; // register timeslot
parameter BYTE7BIT0 = 8'h40; // register timeslot
parameter BYTE7BIT1 = 8'h41; // register timeslot
parameter BYTE7BIT2 = 8'h42; // register timeslot
parameter BYTE7BIT3 = 8'h43; // register timeslot
parameter BYTE7BIT4 = 8'h44; // register timeslot
parameter BYTE7BIT5 = 8'h45; // register timeslot
parameter BYTE7BIT6 = 8'h46; // register timeslot
parameter BYTE7BIT7 = 8'h47; // register timeslot
parameter BYTE8BIT0 = 8'h48; // register timeslot
parameter BYTE8BIT1 = 8'h49; // register timeslot
parameter BYTE8BIT2 = 8'h4a; // register timeslot
parameter BYTE8BIT3 = 8'h4b; // register timeslot
parameter BYTE8BIT4 = 8'h4c; // register timeslot
parameter BYTE8BIT5 = 8'h4d; // register timeslot
parameter BYTE8BIT6 = 8'h4e; // register timeslot
parameter BYTE8BIT7 = 8'h4f; // register timeslot
