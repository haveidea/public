task INIT_OWBUS;
   begin
      `TB_ONEWIRE.DQ_DRIVE = 'b1;
   end
endtask

task DRIVE_DQ_0;
   begin
      `TB_ONEWIRE.DQ_DRIVE = 'b0;
   end
endtask

task DRIVE_DQ_1;
   begin
      `TB_ONEWIRE.DQ_DRIVE = 'b1;
   end
endtask

task DRIVE_DQ_Z;
   begin
      `TB_ONEWIRE.DQ_DRIVE = 'bz;
   end
endtask

task RESET_PULSE;
   begin
      `TB_ONEWIRE.DQ_DRIVE = 'b0;
      #(RSTPULSEMIN*1000);
      `TB_ONEWIRE.DQ_DRIVE = 'b1;
   end
endtask

task WRITE_0_SLOT_MIN;
   begin
      `TB_ONEWIRE.DQ_DRIVE = 'b0;
      #(TSLOTINITMIN*1000);
      #(TSLOTINITMAX*1000);
      #(TSLOTREMMIN*1000);
      `TB_ONEWIRE.DQ_DRIVE = 'b1;
   end
endtask

task WRITE_0_SLOT_MAX;
   begin
      `TB_ONEWIRE.DQ_DRIVE = 'b0;
      #(TSLOTINITMIN*1000);
      #(TSLOTINITMAX*1000);
      #(TSLOTREMMAX*1000);
      `TB_ONEWIRE.DQ_DRIVE = 'b1;
   end
endtask

task WRITE_1_SLOT_MIN;
   begin
      `TB_ONEWIRE.DQ_DRIVE = 'b0;
      #(TSLOTINITMIN*1000);
      //`TB_ONEWIRE.DQ_DRIVE = 'bz;
      #(TSLOTINITMAX*1000);
      `TB_ONEWIRE.DQ_DRIVE = 'b1;
      #(TSLOTREMMIN*1000);
      //`TB_ONEWIRE.DQ_DRIVE = 'b1;
   end
endtask

task WRITE_1_SLOT_MAX;
   begin
      `TB_ONEWIRE.DQ_DRIVE = 'b0;
      #(TSLOTINITMIN*1000);
      `TB_ONEWIRE.DQ_DRIVE = 'bz;
      #(TSLOTINITMAX*1000);
      `TB_ONEWIRE.DQ_DRIVE = 'b1;
      #(TSLOTREMMAX*1000);
      //`TB_ONEWIRE.DQ_DRIVE = 'b1;
   end
endtask

task READ_SLOT_MIN;
   output dataout;
   begin
      `TB_ONEWIRE.DQ_DRIVE = 'b0;
      #(TSLOTINITMIN*1000);
      `TB_ONEWIRE.DQ_DRIVE = 'bz;
      #(TSLOTINITMAX*1000);
      dataout = `TB_ONEWIRE.__DQ__;
      #(TSLOTREMMIN*1000);
      //`TB_ONEWIRE.DQ_DRIVE = 'b1;
   end
endtask

task READ_SLOT_MAX;
   output dataout;
   begin
      `TB_ONEWIRE.DQ_DRIVE = 'b0;
      #(TSLOTINITMAX*1000);
      `TB_ONEWIRE.DQ_DRIVE = 'bz;
      #(TSLOTINITMIN*1000);
      dataout = `TB_ONEWIRE.__DQ__;
      #(TSLOTREMMAX*1000);
      //`TB_ONEWIRE.DQ_DRIVE = 'b1;
   end
endtask

task WRITE_ONE_BYTE;
   input [7:0] onebyte;
   integer     i;
   reg 	       dat;
   begin
      for (i=0; i<8; i=i+1) begin
	 dat = onebyte[i];
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
      end
   end
endtask
