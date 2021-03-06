`define DTT //Digital-circuit Timing Adjust
`define TB_ONEWIRE tb_onewire
`define DUT  `TB_ONEWIRE.u_dut
`define OWAM `DUT.owam_inst
`define CONF `DUT.u_conf_dummy
`define LOAD_EEPROM

`define    TSLOTINITMIN    1     //us
`define    TSLOTINITMAX    14    //us
`define    TSLOTREMMIN     45    //us
`define    TSLOTRCMIN      1     //us
`define    TSLOTRCMAX      3     //us
`define    TSLOTREMMAX     105   //us

`define    RSTPULSEMIN     480   //us
`define    RSTPULSEMAX     960   //us

`define    RECOVERYMIN     1     //us
`define    RECOVERYMAX     15    //us

`define    POS125DEGREE    8'h7d //Celsius degree
`define    POS105DEGREE    8'h69 //Celsius degree
`define    POS85DEGREE     8'h55 //Celsius degree
`define    POS25DEGREE     8'h19 //Celsius degree
`define    POS10DEGREE     8'h0a //Celsius degree
`define    POS1DEGREE      8'h01 //Celsius degree

`define    NEG1DEGREE      8'hfe //Celsius degree
`define    NEG10DEGREE     8'hf5 //Celsius degree
`define    NEG25DEGREE     8'he6 //Celsius degree
`define    NEG55DEGREE     8'hc8 //Celsius degree
`define    NEG85DEGREE     8'haa //Celsius degree
`define    NEG105DEGREE    8'h96 //Celsius degree
`define    NEG125DEGREE    8'h82 //Celsius degree
