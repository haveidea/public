//-----------------------------------------------------------------------------
// CRC module for data[7:0] ,   crc[7:0]=1+x^4+x^5+x^8;
//-----------------------------------------------------------------------------
module crc8_lfsr(
  input [7:0] data_in,
  input crc_en,
  output [7:0] crc_out,
  output [7:0] crc_oth,
  input rst,
  input clk);

  reg [7:0] lfsr_q,lfsr_c;
  reg [7:0] lfsr_p,lfsr_t;

  assign crc_out = lfsr_q;
  assign crc_oth = lfsr_p;

  always @(*) begin
    lfsr_c[0] = lfsr_q[0] ^ lfsr_q[3] ^ lfsr_q[4] ^ lfsr_q[6] ^ data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[6];
    lfsr_c[1] = lfsr_q[1] ^ lfsr_q[4] ^ lfsr_q[5] ^ lfsr_q[7] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[7];
    lfsr_c[2] = lfsr_q[2] ^ lfsr_q[5] ^ lfsr_q[6] ^ data_in[2] ^ data_in[5] ^ data_in[6];
    lfsr_c[3] = lfsr_q[3] ^ lfsr_q[6] ^ lfsr_q[7] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    lfsr_c[4] = lfsr_q[0] ^ lfsr_q[3] ^ lfsr_q[6] ^ lfsr_q[7] ^ data_in[0] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    lfsr_c[5] = lfsr_q[0] ^ lfsr_q[1] ^ lfsr_q[3] ^ lfsr_q[6] ^ lfsr_q[7] ^ data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    lfsr_c[6] = lfsr_q[1] ^ lfsr_q[2] ^ lfsr_q[4] ^ lfsr_q[7] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[7];
    lfsr_c[7] = lfsr_q[2] ^ lfsr_q[3] ^ lfsr_q[5] ^ data_in[2] ^ data_in[3] ^ data_in[5];

  end // always

  always @(*) begin
    lfsr_t[0] = lfsr_p[0] ^ lfsr_p[3] ^ lfsr_p[4] ^ lfsr_p[6] ^ data_in[0] ^ data_in[3] ^ data_in[4] ^ data_in[6];
    lfsr_t[1] = lfsr_p[1] ^ lfsr_p[4] ^ lfsr_p[5] ^ lfsr_p[7] ^ data_in[1] ^ data_in[4] ^ data_in[5] ^ data_in[7];
    lfsr_t[2] = lfsr_p[2] ^ lfsr_p[5] ^ lfsr_p[6] ^ data_in[2] ^ data_in[5] ^ data_in[6];
    lfsr_t[3] = lfsr_p[3] ^ lfsr_p[6] ^ lfsr_p[7] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    lfsr_t[4] = lfsr_p[0] ^ lfsr_p[3] ^ lfsr_p[6] ^ lfsr_p[7] ^ data_in[0] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    lfsr_t[5] = lfsr_p[0] ^ lfsr_p[1] ^ lfsr_p[3] ^ lfsr_p[6] ^ lfsr_p[7] ^ data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[6] ^ data_in[7];
    lfsr_t[6] = lfsr_p[1] ^ lfsr_p[2] ^ lfsr_p[4] ^ lfsr_p[7] ^ data_in[1] ^ data_in[2] ^ data_in[4] ^ data_in[7];
    lfsr_t[7] = lfsr_p[2] ^ lfsr_p[3] ^ lfsr_p[5] ^ data_in[2] ^ data_in[3] ^ data_in[5];

  end // always

  always @(posedge clk, posedge rst) begin
    if(rst) begin
      lfsr_q <= {8{1'b1}};
    end
    else begin
      lfsr_q <= crc_en ? lfsr_c : lfsr_q;
    end
  end // always

  always @(posedge clk, posedge rst) begin
    if(rst) begin
      lfsr_p <= {8{1'b0}};
    end
    else begin
      lfsr_p <= crc_en ? lfsr_t : lfsr_p;
    end
  end // always
endmodule // crc8_lfsr