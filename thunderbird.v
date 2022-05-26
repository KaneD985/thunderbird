module thunderbird(clk, rst, left, right, brk, hzd, dimclk, rlight, display);
    wire [5:0] pat;
    output [5:0] display;
    input clk, rst, left, right, brk, hzd, dimclk, rlight;

    state state(.clk(clk), .rst(rst), .left(left), .right(right), .brk(brk), .hazard(hzd), .pat(pat));
    combination c(.pat(pat), .dimclk(dimclk), .rlight(rlight), .display(display));

endmodule


module combination (pat, dimclk, rlight, display);
    input [5:0] pat;
    input dimclk;
    input rlight;
    output reg [5:0] display;

    reg dim;
    always@(posedge dimclk) begin
    if(rlight) begin
        dim <= ~dim;

        if(pat[5]) begin
            display[5] = 1'b1;
        end
        else begin
            display[5] = dim;
        end
        
        if(pat[4]) begin
            display[4] = 1'b1;
        end
        else begin
            display[4] = dim;
        end

        if(pat[3]) begin
            display[3] = 1'b1;
        end
        else begin
            display[3] = dim;
        end

        if(pat[2]) begin
            display[2] = 1'b1;
        end
        else begin
            display[2] = dim;
        end

        if(pat[1]) begin
            display[1] = 1'b1;
        end
        else begin
            display[1] = dim;
        end

        if(pat[0]) begin
            display[0] = 1'b1;
        end
        else begin
            display[0] = dim;
        end
    end

    else begin
        display[5] = pat[5];
        display[4] = pat[4];
        display[3] = pat[3];
        display[2] = pat[2];
        display[1] = pat[1];
        display[0] = pat[0];
    end
  end

endmodule

module state(clk, rst, left, right, brk, hazard, pat);
    input clk, rst, left, right, brk, hazard;
    output reg [5:0] pat;
    `define state_off   4'd0
    `define state_brake   4'd1
    `define state_l1   4'd2
    `define state_l2   4'd3
    `define state_l3   4'd4
    `define state_r1   4'd5
    `define state_r2   4'd6
    `define state_r3   4'd7
    `define state_bl1   4'd8
    `define state_bl2   4'd9
    `define state_br1   4'd10
    `define state_br2   4'd11
    `define state_hazard  4'd12          
 
    reg[3:0] currentState;
    reg[3:0] nextState;  
    
    always@( * ) begin
        case(currentState)
            `state_off: begin
                pat = 6'b000000;  
            end
            `state_brake: begin
                pat = 6'b111111;
            end
            `state_l1: begin
                pat = 6'b001000; 
            end
            `state_l2: begin
                pat = 6'b011000;
            end
            `state_l3: begin
                pat = 6'b111000;
            end
            `state_r1: begin
                pat = 6'b000100;
            end
            `state_r2: begin
                pat = 6'b000110;
            end
            `state_r3: begin
                pat = 6'b000111;
            end
            `state_bl1: begin
                pat = 6'b001111;
            end
            `state_bl2: begin
                pat = 6'b011111;
            end
            `state_br1: begin
                pat = 6'b111100;
            end
            `state_br2: begin
                pat = 6'b111110;
            end
            `state_hazard: begin
                pat = 6'b111111;
            end
        endcase 
    end
    always@(posedge clk) begin          
        if(rst)
            currentState <= `state_off;
        else
            currentState <= nextState;
    end
 
    always@( * ) begin            
    nextState = currentState;
    if(rst) begin            
        nextState = `state_off;
    end
    else if(!rst && brk && !left && !right) begin    
        nextState = `state_brake; 
    end
    else if(!rst && brk && left && right) begin    
        nextState = `state_brake;
    end
    else if(!rst && !brk && hazard && (currentState != `state_hazard)) begin      
        nextState = `state_hazard;         
    end 
    else if(!rst && !brk && !hazard && left && right && (currentState != `state_hazard)) begin  
        nextState = `state_hazard;       
    end
    else if(!rst && !brk && !hazard && !left && !right) begin
        nextState = `state_off;
    end

    else begin
    case (currentState)
        `state_off: begin              //state_off
            if(!rst && brk && !left && right) nextState = `state_br1;
            if(!rst && brk && left && !right) nextState = `state_bl1;
            if(!rst && !brk && !hazard && left && !right) nextState = `state_l1;
            if(!rst && !brk && !hazard && !left && right) nextState = `state_r1;
        end
        `state_brake: begin
            if(!rst && brk && !left && right) nextState = `state_br1;
            if(!rst && brk && left && !right) nextState = `state_bl1;
            if(!rst && !brk && !hazard && left && !right) nextState = `state_l1;
            if(!rst && !brk && !hazard && !left && right) nextState = `state_r1;
        end
        `state_l1: begin
            if(!rst && brk && !left && right) nextState = `state_br1;
            if(!rst && brk && left && !right) nextState = `state_bl2;
            if(!rst && !brk && !hazard && left && !right) nextState = `state_l2;
            if(!rst && !brk && !hazard && !left && right) nextState = `state_r1;
        end
        `state_l2: begin
            if(!rst && brk && !left && right) nextState = `state_br1;
            if(!rst && brk && left && !right) nextState = `state_brake;
            if(!rst && !brk && !hazard && left && !right) nextState = `state_l3;
            if(!rst && !brk && !hazard && !left && right) nextState = `state_r1;
        end
        `state_l3: begin
            if(!rst && brk && !left && right) nextState = `state_br1;
            if(!rst && brk && left && !right) nextState = `state_r3;
            if(!rst && !brk && !hazard && left && !right) nextState = `state_off;
            if(!rst && !brk && !hazard && !left && right) nextState = `state_r1;
        end
        `state_r1: begin
            if(!rst && brk && !left && right) nextState = `state_br2;
            if(!rst && brk && left && !right) nextState = `state_bl1;
            if(!rst && !brk && !hazard && left && !right) nextState = `state_l1;
            if(!rst && !brk && !hazard && !left && right) nextState = `state_r2;
        end
        `state_r2: begin
            if(!rst && brk && !left && right) nextState = `state_brake;
            if(!rst && brk && left && !right) nextState = `state_bl1;
            if(!rst && !brk && !hazard && left && !right) nextState = `state_l1;
            if(!rst && !brk && !hazard && !left && right) nextState = `state_r3;
        end
        `state_r3: begin
            if(!rst && brk && !left && right) nextState = `state_l3;
            if(!rst && brk && left && !right) nextState = `state_bl1;
            if(!rst && !brk && !hazard && left && !right) nextState = `state_l1;
            if(!rst && !brk && !hazard && !left && right) nextState = `state_off;
        end
        `state_bl1: begin
            if(!rst && brk && !left && right) nextState = `state_br1;
            if(!rst && brk && left && !right) nextState = `state_bl2;
            if(!rst && !brk && !hazard && left && !right) nextState = `state_l2;
            if(!rst && !brk && !hazard && !left && right) nextState = `state_r1;
        end
        `state_bl2: begin
            if(!rst && brk && !left && right) nextState = `state_br1;
            if(!rst && brk && left && !right) nextState = `state_brake;
            if(!rst && !brk && !hazard && left && !right) nextState = `state_l3;
            if(!rst && !brk && !hazard && !left && right) nextState = `state_r1;
        end
        `state_br1: begin
            if(!rst && brk && !left && right) nextState = `state_br2;
            if(!rst && brk && left && !right) nextState = `state_bl1;
            if(!rst && !brk && !hazard && left && !right) nextState = `state_l1;
            if(!rst && !brk && !hazard && !left && right) nextState = `state_r2;
        end
        `state_br2: begin
            if(!rst && brk && !left && right) nextState = `state_brake;
            if(!rst && brk && left && !right) nextState = `state_bl1;
            if(!rst && !brk && !hazard && left && !right) nextState = `state_l1;
            if(!rst && !brk && !hazard && !left && right) nextState = `state_r3;
        end
        `state_hazard: begin
            if(!rst && brk && !left && right) nextState = `state_br1;
            if(!rst && brk && left && !right) nextState = `state_bl1;
            if(!rst && !brk && !hazard && left && !right) nextState = `state_l1;
            if(!rst && !brk && !hazard && !left && right) nextState = `state_r1;
            if(!rst && !brk && hazard) nextState = `state_off;
            if(!rst && !brk && !hazard && left && right) nextState = `state_off;
        end 
    endcase  
    end   
    end
endmodule;
