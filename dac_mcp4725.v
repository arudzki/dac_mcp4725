module dac_mcp4725 (
    input i_clk,
    input reset,
    output o_scl,
    inout o_sda
);

reg [6:0] r_count = 7'b0;
reg [7:0] r_scount = 8'b0;     // counter for I2C sclk ticks

reg r_sclk = 1'b1;
reg r_sda  = 1'bz;
reg r_clk = 1'bz;
reg [31:0] r_status = 99999999;	
	
parameter [7:0] dac_addr = 8'b11000010; // address of dac + write bit (0)
parameter [7:0] high_byte = 8'b00000111; // fast mode (00) + no power down (00) + bits D11 thru D8
parameter [7:0] low_byte = 8'b11111111; // low byte.   hi+low bytes set dac to mid range (3V3/2)


localparam [4:0]    POWERUP = 5'h00;
                    START   = 5'h01;
                    DACADR7 = 5'h02;
                    DACADR6 = 5'h03;
                    DACADR5 = 5'h04;
                    DACADR4 = 5'h05;
                    DACADR3 = 5'h06;
                    DACADR2 = 5'h07;
                    DACADR1 = 5'h08;
                    DACADR0 = 5'h09;        // R/W bit
                    REC_ACK = 5'h0A;
                    SENDHI7 = 5'h0B;
                    SENDHI6 = 5'h0C;
                    SENDHI5 = 5'h0D;
                    SENDHI4 = 5'h0E;
                    SENDHI3 = 5'h0F;
                    SENDHI2 = 5'h10;
                    SENDHI1 = 5'h11;
                    SENDHI0 = 5'h12;        // R/W bit
                    REC_ACK = 5'h13;
                    SENDLO7 = 5'h14;
                    SENDLO6 = 5'h15;
                    SENDLO5 = 5'h16;
                    SENDLO4 = 5'h17;
                    SENDLO3 = 5'h18;
                    SENDLO2 = 5'h19;
                    SENDLO1 = 5'h1A;
                    SENDLO0 = 5'h1B;        // R/W bit
                    REC_ACK = 5'h1C;


    // Start condition is H to L transition on SDA while SCK is H
    // Stop condition is L to H transition on SDA while SCK is H
    // Data on SDA can only change during SCK L time



reg [4:0] r_state <= POWERUP;      // our state machine


always @ (posedge i_clk or posedge reset) begin
        if (reset) begin
            r_count <= 0;
        end
        else if (r_count == 124) begin
				r_count <= 7'b0;            //reset counter
				r_sclk <= ~r_sclk;			// toggle slow clock 1uS tick (400KHz.  I2C clock is 100KHz)
			end 
		    else 
				r_count <= r_count + 1;		// Keep counting
end 

assign o_scl = r_clk;                      // output I2C Clock
assign o_sda = r_sda ? 1'bz: 1'b0;		    // If r_sca = 1 then highZ makes it a 1, otherwise a 0

always @ (posedge r_sclk or posedge reset) begin
        if (reset) begin
            r_state <= POWERUP;
            r_scount <= 8'b0;
        end else begin
            r_scount = r_scount + 1;

            case (r_state) begin
                POWERUP : begin
                    if (r_scount == d'05)       // 5x 1uS = 5uS start up time for mcp4725 
                    r_sda <= 1'b0;              // SCA goes L while SCK is H
                    r_state <= START;
                end
                START   : begin
                    r_clk <= 1'b0;
                    if (r_scount == d'07)       // 5x 1uS = 5uS start up time for mcp4725 
                    r_sda = dac_addr[7] ? 1'b1: 1'b0;
                    r_state <= DACADR7;                    
                end
                DACADR7 : begin
                    r_clk <= 1'bz;
                    if (r_scount == d'010)       // 5x 1uS = 5uS start up time for mcp4725 
                     r_clk <= 1'b0;                   
                     r_state <= DACADR6;                    
                end
               DACADR6 : begin
                    r_sda = dac_addr[6] ? 1'b1: 1'b0;
                    if (r_scount == d'014)       // 5x 1uS = 5uS start up time for mcp4725 
                     r_clk <= 1'bz;                   
                     r_state <= DACADR5;                    
                end
                DACADR5 : begin
                    if (r_scount == d'018)       // 5x 1uS = 5uS start up time for mcp4725 
                     r_clk <= 1'b0;                   
                     r_state <= DACADR4;                    
                end
               DACADR4 : begin
                    r_sda = dac_addr[5] ? 1'b1: 1'b0;
                    if (r_scount == d'022)       // 5x 1uS = 5uS start up time for mcp4725 
                     r_clk <= 1'bz;                   
                     r_state <= DACADR3;                    
                end
                DACADR3 : begin
                    if (r_scount == d'026)       // 5x 1uS = 5uS start up time for mcp4725 
                     r_clk <= 1'b0;                   
                     r_state <= DACADR2;                    
                end
               DACADR2 : begin
                    r_sda = dac_addr[4] ? 1'b1: 1'b0;
                    if (r_scount == d'030)       // 5x 1uS = 5uS start up time for mcp4725 
                     r_clk <= 1'bz;                   
                     r_state <= DACADR1;                    
                end
                DACADR1 : begin
                    r_clk <= 1'bz;
                    if (r_scount == d'034)       // 5x 1uS = 5uS start up time for mcp4725 
                     r_clk <= 1'b0;                   
                     r_state <= DACADR0;                    
                end
               DACADR0 : begin
                    r_sda = dac_addr[6] ? 1'b1: 1'b0;
                    if (r_scount == d'038)       // 5x 1uS = 5uS start up time for mcp4725 
                     r_clk <= 1'b0;                   
                     r_state <= DACADR6;                    
                end








            end
            endcase
        end


        case (r_state) begin
            POWERUP : begin
                    bit_count = d'07;
                    xcnt = 3'd0;
                    r_sda <= 1'b0;              // SCA goes L while SCK is H
                    r_state <= START;
                end
                START   : begin
                    r_clk <= 1'b0;
                     r_state <= DACADR7;                    
                end
                DACADR7  : begin
                    if (xcnt == 4) begin
                            xcnt <= 3'b0;            //reset counter
                            r_clk <= 1'b1 ? 1'bz: 1'b0;			// toggle slow clock 1uS tick (400KHz.  I2C clock is 100KHz)
                        end else 
                            xcnt <= xcnt + 1;		// Keep counting
                    if (xcnt == 3'd02 & r_clk == 1'b0) begin
                            r_sda = dac_addr[bit_count] ? 1'b1: 1'b0;
                            r_clk <= 1'b0;

                            if (bit_count == 0)
                                r_state <= NEXT_STATE;
                            else
                                bit_count = bit_count - 3'd1;


                    end
                    end

end




endmodule