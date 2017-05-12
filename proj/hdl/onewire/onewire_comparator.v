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
// File name            : onewire_comparator.v
// File contents        : Module 8-bit Comparator
// Purpose              : Realization One-wire protocol/1-wire subset
//                        Behavior level HDL Core
// Destination project  : N20
// Destination library  : N20_LIB
//---------------------------------------------------------------------
// File Revision        : $Revision$
// File Author          : $Author$
// Last modification    : $Date$
//---------------------------------------------------------------------
module onewire_comparator(
			  dataa, // data A
			  datab, // data B
			  a_ge_b // great-equal
			  );

`include "onewire_params.v"

   input [7:0]                dataa;  // data A
   input [7:0] 		      datab;  // data B
   output                     a_ge_b; // great-equal

   //--  --
   reg                        c;

   //-- edge detector circuit --
   assign a_ge_b = c;
   always @(*) begin
      case ({dataa[7],datab[7]})
	2'b00: begin
	   if (dataa[6:0]>=datab[6:0]) begin
              c = 1;
	   end else begin
              c = 0;
	   end
	end
	2'b01: begin
	   c = 1;
	end
	2'b10: begin
	   c = 0;
	end
	2'b11: begin
	   if (datab[6:0]>=dataa[6:0]) begin
              c = 1;
	   end else begin
              c = 0;
	   end
	end
	//default: begin
	//end
      endcase
   end

endmodule //onewire_comparator
