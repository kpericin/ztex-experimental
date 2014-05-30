module intraffic (
	input RESET,
	input CS,
	input RW,
	input IFCLK,
	inout [15:0] FD,
	output SLOE,
	output SLRD,
	output SLWR,
	output FIFOADR0,
	output FIFOADR1,
	output PKTEND,
	input FLAGB,
	input FLAGC
);

reg [255:0] data;
reg [255:0] data_out;

reg SLOE_R, SLRD_R, SLWR_R, PKTEND_R;
reg [15:0] FD_R;
reg fr_or_sec;
reg [4:0] cnt;

reg [6:0] INT_CNT;

assign SLOE = (CS == 1'b1) ? SLOE_R : 1'bZ;
assign SLRD = (CS == 1'b1) ? SLRD_R : 1'bZ;
assign SLWR = (CS == 1'b1) ? SLWR_R : 1'bZ;
assign FIFOADR0 = (CS == 1'b1) ? 1'b0 : 1'bZ;
assign FIFOADR1 = (CS == 1'b1) ? ((RW == 1'b1) ? 1'b0 : 1'b1) : 1'bZ;
assign PKTEND = (CS == 1'b1) ? PKTEND_R : 1'bZ;
assign FD = (RW == 1'b1 && CS == 1'b1) ? FD_R : 16'bZ;
    
always @(posedge IFCLK)
begin
	if (RESET == 1) begin
		cnt <= 0;
		PKTEND_R <= 1;
		fr_or_sec <= 0;
	end
	else begin
//		if(RW == 0) begin
//			SLOE_R <= 1'b0;
//			if (FLAGC == 1) begin
//				data[255:240] <= FD;
//				data[239:0] <= data[255:16];
//				SLRD_R <= 1'b0;
//			end
//			data_out <= data;
//			SLWR_R <= 1'b1;
//			PKTEND_R <= 1'b1;
//		end
		if(RW == 0) begin
			SLOE_R <= 1'b0;
			if(FLAGC == 1) begin
				if(fr_or_sec == 1'b0) begin
					SLRD_R <= 1'b1;
					fr_or_sec <= 1'b1;
					data[255:240] <= FD;
				end
				else begin
					data[255:240] <= FD;
					data[239:0] <= data[255:16];
					SLRD_R <= 1'b0;
					fr_or_sec <= 1'b0;
				end
			end
			data_out <= data;
//			data_out <= 256'hd1310ba698dfb5ac2ffd72dbd01adfb7b8e1afed6a267e96ba7c9045f12c7f99;
			SLWR_R <= 1'b1;
			PKTEND_R <= 1'b1;
		end
		else begin
			if(FLAGB == 1) begin
				if(fr_or_sec == 0) begin
					FD_R <= data_out[15:0];
					SLWR_R <= 1'b0;
					fr_or_sec <= 1'b1;
				end
				else begin
					FD_R <= FD_R;
					data_out[239:0] <= data_out[255:16];
					SLWR_R <= 1'b1;
					fr_or_sec <= 0;
					cnt <= cnt + 5'd1;
				end
			end
			PKTEND_R <= 1'b1;
			SLRD_R <= 1'b1;
			SLOE_R <= 1'b1;
		end
		
		if(cnt >= 5'd16) begin
			PKTEND_R <= 1'b0;
			cnt <= 5'd0;
		end
	end
end

endmodule
