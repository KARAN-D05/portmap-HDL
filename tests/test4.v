module clock_module(
    input select,
    input hlt,
    input push,
    output reg out
);
  reg astable;
  reg manual;
  
  initial astable = 0;
  always #5 astable = ~astable;

  always@(posedge push) begin
    manual = 1;
    #5;
    manual = 0;
   end

  always@(*) begin
    if (select & ~hlt) begin
        out = astable;
    end else if (~ select & ~ hlt) begin
        out = manual;
    end else if (hlt) begin
        out = 0;
     end
  end

endmodule
