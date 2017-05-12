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
