`timescale 1ns / 1ps

module intraffic_tb;

	// Inputs
	reg RESET;
	reg CS;
	reg RW;
	reg IFCLK;
	reg FLAGB;
	reg FLAGC;
	reg [15:0] FD_R;

	// Outputs
	wire SLOE;
	wire SLRD;
	wire SLWR;
	wire FIFOADR0;
	wire FIFOADR1;
	wire PKTEND;

	// Bidirs
	wire [15:0] FD;

	// Instantiate the Unit Under Test (UUT)
	intraffic uut (
		.RESET(RESET), 
		.CS(CS), 
		.RW(RW), 
		.IFCLK(IFCLK), 
		.FD(FD), 
		.SLOE(SLOE), 
		.SLRD(SLRD), 
		.SLWR(SLWR), 
		.FIFOADR0(FIFOADR0), 
		.FIFOADR1(FIFOADR1), 
		.PKTEND(PKTEND), 
		.FLAGB(FLAGB), 
		.FLAGC(FLAGC)
	);
	
	assign FD = (RW == 0) ? FD_R : 16'bz;

	initial begin
		// Initialize Inputs
		RESET = 1;
		CS = 0;
		RW = 0;
		IFCLK = 0;
		FLAGB = 0;
		FLAGC = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		RESET = 0;
		CS = 1;
		FLAGB = 1;
		FLAGC = 1;
	end
	
	always begin
		#0.5 IFCLK <= ~IFCLK;
	end
	
	always @(posedge IFCLK)
	begin
		if(RESET == 1) begin
			FD_R <= 0;
		end
		else begin
			FD_R <= FD_R + 16'd1;
		end
	end
      
endmodule

