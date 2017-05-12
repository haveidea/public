`timescale 1us / 1ns 

module crc8_31_tb();
 
   parameter SPEED = 2; //MHZ
   parameter CLK_T = 1000/(SPEED*2);
   //parameter SRC_CODE = "./SIEVE.BIN";
   reg G_DQ;
   `include "tb_define.v"
   `include "tb_tasks.v"
 
   reg clk;
   reg rst_in_n;
   reg [7:0] rom_crc, rom_family;
   reg [47:0] rom_sn;
   reg [63:0] rom_code;
   //`include "crc8_func.v"
   `include "crc8_lfsr.v"
  function [7:0] crc8_swap;
    input [7:0] Data;
    reg [7:0] d;
    reg [7:0] s;
  begin
    d = Data;
    s[0] = d[7];
    s[1] = d[6];
    s[2] = d[5];
    s[3] = d[4];
    s[4] = d[3];
    s[5] = d[2];
    s[6] = d[1];
    s[7] = d[0];
    crc8_swap = s;
  end
  endfunction
  // polynomial: x^8 + x^5 + x^4 + 1
  // data width: 8
  // convention: the first serial bit is D[7]
  function [7:0] nextCRC8_D8;
    input [7:0] Data;
    input [7:0] crc;
    reg [7:0] d;
    reg [7:0] c;
    reg [7:0] newcrc;
  begin
    d = Data;
    c = crc;
    newcrc[0] = d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[3] ^ c[4] ^ c[6];
    newcrc[1] = d[7] ^ d[5] ^ d[4] ^ d[1] ^ c[1] ^ c[4] ^ c[5] ^ c[7];
    newcrc[2] = d[6] ^ d[5] ^ d[2] ^ c[2] ^ c[5] ^ c[6];
    newcrc[3] = d[7] ^ d[6] ^ d[3] ^ c[3] ^ c[6] ^ c[7];
    newcrc[4] = d[7] ^ d[6] ^ d[3] ^ d[0] ^ c[0] ^ c[3] ^ c[6] ^ c[7];
    newcrc[5] = d[7] ^ d[6] ^ d[3] ^ d[1] ^ d[0] ^ c[0] ^ c[1] ^ c[3] ^ c[6] ^ c[7];
    newcrc[6] = d[7] ^ d[4] ^ d[2] ^ d[1] ^ c[1] ^ c[2] ^ c[4] ^ c[7];
    newcrc[7] = d[5] ^ d[3] ^ d[2] ^ c[2] ^ c[3] ^ c[5];
    nextCRC8_D8 = newcrc;
  end
  endfunction
  // polynomial: x^8 + x^5 + x^4 + 1
  // data width: 1
  // convention: the first serial bit is D[0]
  function [7:0] nextCRC8_D1;
    input Data;
    input [7:0] crc;
    reg [0:0] d;
    reg [7:0] c;
    reg [7:0] newcrc;
  begin
    d[0] = Data;
    c = crc;
    newcrc[0] = d[0] ^ c[7];
    newcrc[1] = c[0];
    newcrc[2] = c[1];
    newcrc[3] = c[2];
    newcrc[4] = d[0] ^ c[3] ^ c[7];
    newcrc[5] = d[0] ^ c[4] ^ c[7];
    newcrc[6] = c[5];
    newcrc[7] = c[6];
    nextCRC8_D1 = newcrc;
  end
  endfunction
   
   // clock generation
   initial begin
      clk=0;
      forever
	#CLK_T clk=~clk;
   end

   // reset initial
   initial begin
      rst_in_n = 0;
      #1000;
      //repeat (100) #CLK_T;
      rst_in_n = 1;
   end

   // rom code initial
   /////////////////////////////
   initial begin
      INIT_OWBUS;
      rom_code[63:0] = 64'h8300_0008_73B3_F528;
      $display("ROM Code[63: 0] = 64'h%04H_%04H_%04h_%04H",rom_code[63:48],
	       rom_code[47:32],rom_code[31:16],rom_code[15:0]);
      rom_crc[7:0] = rom_code[63:56];
      $display("ROM  CRC[63:56] = 8'h%02H",rom_crc);
      rom_sn[47:0] = rom_code[55:8];
      $display("ROM   SN[55: 8] = 48'h%04H_%04H_%04h",rom_sn[47:32],rom_sn[31:16],rom_sn[15:0]);
      rom_family[7:0] = rom_code[7:0];
      $display("ROM   FC[ 7: 0] = 8'h%02H",rom_family);
      #1000;
      RESET_PULSE;
      #1000;
      WRITE_0_SLOT;
      #1000;
      WRITE_1_SLOT;
   end

   // crc module instantiation
   /*
   CRC8_D8 u_CRC8_D8(
		    );
   CRC8_D1 u_CRC8_D1(
		    );
    */
   reg [7:0] crc8d8, crc8d1, crc8_count, crc8_byte;
   reg [7:0] crc8d8_old, crc8d1_old;
   reg [7:0] crc8d8_din, crc8d8_crc, crc8d1_crc;
   reg 	     crc8lfsr_en;
   wire [7:0] crc8lfsr_crc, crc8lfsr_old;
   wire [7:0] crc8lfsr_rep, crc8lfsr_oth;
   assign crc8lfsr_crc = crc8_swap(crc8lfsr_old);
   assign crc8lfsr_rep = crc8_swap(crc8lfsr_oth);
   crc8_lfsr u_crc8_lfsr_1(
	.data_in    (crc8d8_din),
	.crc_en     (crc8lfsr_en),
	.crc_out    (crc8lfsr_old),
	.crc_oth    (crc8lfsr_oth),
	.rst        (!rst_in_n),
	.clk        (clk)
		    );
   reg [7:0] crc8lfsr_din;
   wire [7:0] crc8lfsr_2crc, crc8lfsr_2old;
   wire [7:0] crc8lfsr_2rep, crc8lfsr_2oth;
   assign crc8lfsr_2crc = crc8_swap(crc8lfsr_2old);
   assign crc8lfsr_2rep = crc8_swap(crc8lfsr_2oth);
   crc8_lfsr u_crc8_lfsr_2(
	.data_in    (crc8lfsr_din),
	.crc_en     (crc8lfsr_en),
	.crc_out    (crc8lfsr_2old),
	.crc_oth    (crc8lfsr_2oth),
	.rst        (!rst_in_n),
	.clk        (clk)
		    );

   initial begin
      $dumpfile("crc8-31_test.vcd");
      $dumpvars;
      $fsdbDumpfile("crc8-31_test.fsdb");
      $fsdbDumpvars(0,crc8_31_tb);
   end

   //////////////////////////////
   // CRC-8 (0x31) D8 & D1
   initial begin
      crc8_count = 8'h00;
      crc8_byte = 8'h00;
      crc8d8 = 8'h00;
      crc8d1 = 8'h00;
      crc8d8_old = 8'h00;
      crc8d1_old = 8'h00;
      crc8d8_din = 8'h00;
      crc8d8_crc = 8'h00;
      crc8d1_crc = 8'h00;
      crc8lfsr_din = 8'h00;
      crc8lfsr_en = 0;
      $monitor("--- simulation start from %d ----",$time);
      repeat (2) #CLK_T;
      $display("CRC8-D8: 8'h%02H->8'h%02H",crc8d8_old,crc8d8);
      $display("CRC8-D1: 8'h%02H->8'h%02H",crc8d1_old,crc8d1);
      // initial CRC8-D8/D1 function
      crc8d8 = nextCRC8_D8(8'h00,8'h00);
      crc8d1 = nextCRC8_D1(1'b0,8'h00);
      repeat (2) #CLK_T;
      crc8d8_old = crc8d8;
      crc8d1_old = crc8d1;
      $display("CRC8-D8: 8'h%02H->8'h%02H",crc8d8_old,crc8d8);
      $display("CRC8-D1: 8'h%02H->8'h%02H",crc8d1_old,crc8d1);

      // calculating CRC8-D8/D1 - rom_code[7:0]
      repeat (2) #CLK_T;
      $display("\ndatain  = [7:0]-8'h%02H",rom_code[7:0]);
      crc8_count = crc8_count + 8'h1;
      crc8_byte = crc8_byte + 8'h1;
      crc8d8_din = crc8_swap(rom_code[7:0]);
      crc8lfsr_din = rom_code[7:0];
      crc8d8_old = crc8d8;
      crc8d1_old = crc8d1;
      crc8d8 = nextCRC8_D8(crc8d8_din,crc8d8_old);
      crc8d1 = nextCRC8_D1(rom_code[0],crc8d1_old);
      crc8d8_crc = crc8_swap(crc8d8);
      crc8d1_crc = crc8_swap(crc8d1);
      crc8lfsr_en = 1;
      $display("CRC8-D8: 8'h%02H->8'h%02H-(%02H)",crc8d8_old,crc8d8,crc8d8_crc);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8lfsr_en = 0;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[1],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[2],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[3],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[4],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[5],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[6],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[7],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);

      // calculating CRC8-D8/D1 - rom_code[15:8]
      repeat (2) #CLK_T;
      $display("\ndatain = [15:8]-8'h%02H",rom_code[15:8]);
      crc8_count = crc8_count + 8'h1;
      crc8_byte = crc8_byte + 8'h1;
      crc8d8_din = crc8_swap(rom_code[15:8]);
      crc8lfsr_din = rom_code[15:8];
      crc8d8_old = crc8d8;
      crc8d1_old = crc8d1;
      crc8d8 = nextCRC8_D8(crc8d8_din,crc8d8_old);
      crc8d1 = nextCRC8_D1(rom_code[8],crc8d1_old);
      crc8d8_crc = crc8_swap(crc8d8);
      crc8d1_crc = crc8_swap(crc8d1);
      crc8lfsr_en = 1;
      $display("CRC8-D8: 8'h%02H->8'h%02H-(%02H)",crc8d8_old,crc8d8,crc8d8_crc);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8lfsr_en = 0;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[9],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[10],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[11],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[12],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[13],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[14],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[15],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);

      // calculating CRC8-D8/D1 - rom_code[23:16]
      repeat (2) #CLK_T;
      $display("\ndatin = [23:16]-8'h%02H",rom_code[23:16]);
      crc8_count = crc8_count + 8'h1;
      crc8_byte = crc8_byte + 8'h1;
      crc8d8_din = crc8_swap(rom_code[23:16]);
      crc8lfsr_din = rom_code[23:16];
      crc8d8_old = crc8d8;
      crc8d1_old = crc8d1;
      crc8d8 = nextCRC8_D8(crc8d8_din,crc8d8_old);
      crc8d1 = nextCRC8_D1(rom_code[16],crc8d1_old);
      crc8d8_crc = crc8_swap(crc8d8);
      crc8d1_crc = crc8_swap(crc8d1);
      crc8lfsr_en = 1;
      $display("CRC8-D8: 8'h%02H->8'h%02H-(%02H)",crc8d8_old,crc8d8,crc8d8_crc);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8lfsr_en = 0;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[17],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[18],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[19],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[20],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[21],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[22],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[23],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);

      // calculating CRC8-D8/D1 - rom_code[31:24]
      repeat (2) #CLK_T;
      $display("\ndatin = [31:24]-8'h%02H",rom_code[31:24]);
      crc8_count = crc8_count + 8'h1;
      crc8_byte = crc8_byte + 8'h1;
      crc8d8_din = crc8_swap(rom_code[31:24]);
      crc8lfsr_din = rom_code[31:24];
      crc8d8_old = crc8d8;
      crc8d1_old = crc8d1;
      crc8d8 = nextCRC8_D8(crc8d8_din,crc8d8_old);
      crc8d1 = nextCRC8_D1(rom_code[24],crc8d1_old);
      crc8d8_crc = crc8_swap(crc8d8);
      crc8d1_crc = crc8_swap(crc8d1);
      crc8lfsr_en = 1;
      $display("CRC8-D8: 8'h%02H->8'h%02H-(%02H)",crc8d8_old,crc8d8,crc8d8_crc);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8lfsr_en = 0;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[25],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[26],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[27],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[28],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[29],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[30],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[31],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);

      // calculating CRC8-D8/D1 - rom_code[39:32]
      repeat (2) #CLK_T;
      $display("\ndatin = [39:24]-8'h%02H",rom_code[39:24]);
      crc8_count = crc8_count + 8'h1;
      crc8_byte = crc8_byte + 8'h1;
      crc8d8_din = crc8_swap(rom_code[39:32]);
      crc8lfsr_din = rom_code[39:32];
      crc8d8_old = crc8d8;
      crc8d1_old = crc8d1;
      crc8d8 = nextCRC8_D8(crc8d8_din,crc8d8_old);
      crc8d1 = nextCRC8_D1(rom_code[32],crc8d1_old);
      crc8d8_crc = crc8_swap(crc8d8);
      crc8d1_crc = crc8_swap(crc8d1);
      crc8lfsr_en = 1;
      $display("CRC8-D8: 8'h%02H->8'h%02H-(%02H)",crc8d8_old,crc8d8,crc8d8_crc);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8lfsr_en = 0;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[33],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[34],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[35],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[36],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[37],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[38],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[39],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);

      // calculating CRC8-D8/D1 - rom_code[47:40]
      repeat (2) #CLK_T;
      $display("\ndatin = [47:40]-8'h%02H",rom_code[47:40]);
      crc8_count = crc8_count + 8'h1;
      crc8_byte = crc8_byte + 8'h1;
      crc8d8_din = crc8_swap(rom_code[47:40]);
      crc8lfsr_din = rom_code[47:40];
      crc8d8_old = crc8d8;
      crc8d1_old = crc8d1;
      crc8d8 = nextCRC8_D8(crc8d8_din,crc8d8_old);
      crc8d1 = nextCRC8_D1(rom_code[40],crc8d1_old);
      crc8d8_crc = crc8_swap(crc8d8);
      crc8d1_crc = crc8_swap(crc8d1);
      crc8lfsr_en = 1;
      $display("CRC8-D8: 8'h%02H->8'h%02H-(%02H)",crc8d8_old,crc8d8,crc8d8_crc);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8lfsr_en = 0;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[41],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[42],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[43],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[44],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[45],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[46],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[47],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);

      // calculating CRC8-D8/D1 - rom_code[55:48]
      repeat (2) #CLK_T;
      $display("\ndatin = [55:48]-8'h%02H",rom_code[55:48]);
      crc8_count = crc8_count + 8'h1;
      crc8_byte = crc8_byte + 8'h1;
      crc8d8_din = crc8_swap(rom_code[55:48]);
      crc8lfsr_din = rom_code[55:48];
      crc8d8_old = crc8d8;
      crc8d1_old = crc8d1;
      crc8d8 = nextCRC8_D8(crc8d8_din,crc8d8_old);
      crc8d1 = nextCRC8_D1(rom_code[48],crc8d1_old);
      crc8d8_crc = crc8_swap(crc8d8);
      crc8d1_crc = crc8_swap(crc8d1);
      crc8lfsr_en = 1;
      $display("CRC8-D8: 8'h%02H->8'h%02H-(%02H)",crc8d8_old,crc8d8,crc8d8_crc);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8lfsr_en = 0;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[49],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[50],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[51],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[52],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[53],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[54],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[55],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);

      // calculating CRC8-D8/D1 - rom_code[63:56]
      repeat (2) #CLK_T;
      $display("\ndatin = [63:56]-8'h%02H",rom_code[63:56]);
      crc8_count = crc8_count + 8'h1;
      crc8_byte = crc8_byte + 8'h1;
      crc8d8_din = crc8_swap(rom_code[63:56]);
      crc8lfsr_din = rom_code[63:56];
      crc8d8_old = crc8d8;
      crc8d1_old = crc8d1;
      crc8d8 = nextCRC8_D8(crc8d8_din,crc8d8_old);
      crc8d1 = nextCRC8_D1(rom_code[56],crc8d1_old);
      crc8d8_crc = crc8_swap(crc8d8);
      crc8d1_crc = crc8_swap(crc8d1);
      crc8lfsr_en = 1;
      $display("CRC8-D8: 8'h%02H->8'h%02H-(%02H)",crc8d8_old,crc8d8,crc8d8_crc);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8lfsr_en = 0;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[57],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[58],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[59],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[60],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[61],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[62],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      repeat (2) #CLK_T;
      crc8_count = crc8_count + 8'h1;
      crc8d1_old = crc8d1;
      crc8d1 = nextCRC8_D1(rom_code[63],crc8d1_old);
      crc8d1_crc = crc8_swap(crc8d1);
      $display("CRC8-%02d: 8'h%02H->8'h%02H-(%02H)",crc8_count,crc8d1_old,crc8d1,crc8d1_crc);
      #1000;
      crc8_count = crc8_count + 8'h1;
      crc8_byte = crc8_byte + 8'h1;
      $monitor("--- simulation end to here %d ----",$time);
      repeat (10) #CLK_T;
      #CLK_T $finish;
   end // initial begin
   
   //////////////////////////////
   /*
   initial begin
      uart0_file = $fopen("../modelsim_fpga/uart0.dat","w");
      forever begin 
         @(negedge clk);
	 if (uart0_en) begin
	    $fwrite(uart0_file,"%c",uart0_data);;
	    $fflush(uart0_file);
            $fclose(uart0_file);
            uart0_file = $fopen("../modelsim_fpga/uart0.dat","a+");
            @(posedge clk); #1; 
         end
      end
   end // initial begin
    */

endmodule // crc8_31_tb
