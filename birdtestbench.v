module birdtestbench();
  reg clk, dimclk;
  parameter CLK = 10;
  parameter DIMCLK = 30;
  reg rst, left, right, brk, hzd, rlight;
  wire [5:0] display;
  wire [5:0] pat;
  always begin
      #(CLK)clk = ~clk;
      #(DIMCLK)dimclk = ~dimclk;
  end
  
  thunderbird tb (.clk(clk), .rst(rst), .left(left), .right(right), .brk(brk), .hzd(hzd), .dimclk(dimclk), .rlight(rlight), .display(display));
  state state(.clk(clk), .rst(rst), .left(left), .right(right), .brk(brk), .hazard(hzd), .pat(pat));
  combination c (.pat(pat), .dimclk(dimclk), .rlight(rlight), .display(display));
  
  initial begin
    clk = 0;
    dimclk = 0;
    left = 0;
    right = 0;
    brk = 0;
    hzd = 0;
    
    rst = 0;
    @(posedge clk);
    # (1*CLK+3); 
    
    rst = 0;
    left = 1;
    @(posedge clk); // left
    # (30*CLK+3);
    
    left = 0;
    right = 1;
    @(posedge clk); // right
    # (30*CLK+3);
    
    right = 0;
    hzd = 1;
    @(posedge clk); // hazard
    # (30*CLK+3);
    
    hzd = 0;
    brk = 1;
    @(posedge clk); // break
    # (30*CLK+3);
    
    left = 1;
    brk = 1;
    @(posedge clk); // break & left
    # (30*CLK+3);
    
    right = 1;
    left = 0;
    brk = 1;
    @(posedge clk); // break & right
    # (30*CLK+3);
    
    right = 0;
    brk = 1;
    hzd = 1;
    @(posedge clk); // break & hazard
    # (30*CLK+3);
    
    
    end
endmodule
    