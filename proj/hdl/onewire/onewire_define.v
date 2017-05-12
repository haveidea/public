`define DTT //Digital-circuit Timing Adjust
   reg                         DQ_DRIVE;
`define TB_ONEWIRE tb_onewire
`define OWAM tb_onewire.owam_inst
`define LOAD_EEPROM

module owpad(
	     __dq__,           // DQ ioout
	     dq_in,            // DQ input
	     dq_out,           // DQ output
	     dq_ena            // DQ enable
	     );
   inout                       __dq__; // DQ inout
   output                      dq_in;  // DQ input
   input                       dq_out; // DQ output
   input                       dq_ena; // DQ enable
   wire                        __dq__;
   wire                        dq_in;
   assign dq_in = __dq__;
   assign __dq__ = (dq_ena & !dq_out)? 'b0 : 'bz; //open driven
endmodule //owpad

module owand(
	     __dq__,           // DQ ioout
	     dq_pad,           // DQ drive
	     dq_drive          // DQ drive
	     );
   inout                       __dq__;   // DQ inout
   inout                       dq_pad;   // DQ PAD
   input                       dq_drive; // DQ drive
   wire                        __dq__;
   wire                        dq_pad;
   wire                        dq_drive;
   assign __dq__ = dq_drive;
   assign dq_pad = __dq__;
endmodule //owand
