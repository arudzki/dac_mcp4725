module dac_mcp4725 (
    input i_clk,
    input reset,
    output o_scl,
    output o_sca
);

reg [6:0] r_count = 7'b0;
reg [7:0] r_scount = 8'b0;     // counter for I2C sclk ticks

reg r_sclk;
reg r_sca;
reg [31:0] r_status = 99999999;	
	
parameter [7:0] dac_addr = 8'b11000010; // address of dac + write bit (0)
parameter [7:0] high_byte = 8'b00000111; // fast mode (00) + no power down (00) + bits D11 thru D8
parameter [7:0] low_byte = 8'b11111111; // low byte.   hi+low bytes set dac to mid range (3V3/2)


localparam [4:0]    POWERUP = 5'h00;
                    START   = 5'h01;


reg [4:0] r_state <= POWERUP;      // our state machine


always @ (posedge i_clk or posedge reset) begin
        if (reset) begin
            r_count <= 0;
        end
        else if (r_count == 124) begin
				r_count <= 0;               //reset counter
				r_sclk <= ~r_sclk;			// toggle slow clock 2.5uS tick (400KHz.  I2C clock is 100KHz)
			end 
		    else 
				r_count <= r_count + 1;		// Keep counting
end 

assign o_scl = r_sclk;

always @ (posedge r_sclk or posedge reset) begin
        if (reset) begin
            r_state <= POWERUP;
            r_scount <= 8'b0;
        end else begin
            r_scount = r_scount + 1;

            case (r_state) begin
                POWERUP : begin
                    if (r_scount == d'02)       // 2x 2.5uS = 5uS start up time for mcp4725 
                    r_state <= START;
                end
                START   : begin
                    
                end
            end
            endcase
        end
        

 

end



assign o_sca = r_sca ? 1'bz: 1'b0;		// If r_sca = 1 then highZ makes it a 1, otherwise a 0

endmodule