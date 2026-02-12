module ChipInterface
(output logic [ 7:0] D2_SEG, D1_SEG,
 output logic [ 3:0] D2_AN, D1_AN,
 output logic [15:0] LD,
 input  logic [15:0] SW,
 input  logic [ 3:0] BTN,
 input  logic        CLOCK_100); // needed for 7 Segs

  logic [2:0] FirstCoin, SecondCoin;
  logic [7:0] Blank;
  logic [3:0] Remaining, Remaining0, Remaining1;

  EightSevenSegmentDisplays disp (
    .reset(BTN[2]),
    .HEX7(FirstCoin),
    .HEX6(SecondCoin),
    .HEX5(Remaining1),
    .HEX4(Remaining0),
    .HEX3(4'b0000),
    .HEX2(4'b0000),
    .HEX1(4'b0000),
    .HEX0(4'b0000),
    .dec_points(8'b0000_0000),
    .blank(Blank),
    .*);

  ChangeMachine u_change_machine (
    .Cost(SW[15:12]),
    .Pentagons(SW[11:10]),
    .Triangles(SW[9:8]),
    .Circles(SW[7:6]),
    .Paid(SW[3:0]),
    .FirstCoin(FirstCoin),
    .SecondCoin(SecondCoin),
    .Remaining(Remaining),
    .ExactAmount(LD[15]),
    .NotEnoughChange(LD[14]),
    .CoughUpMore(LD[13]));

  always_comb begin
    Blank = 8'b0000_1111;
    if (Remaining >= 4'd10) begin
      Remaining0 = Remaining - 4'd10;
      Remaining1 = 4'd1;
    end 
    else begin 
      Remaining0 = Remaining;
      Remaining1 = 4'd0;
      Blank[5] = 1'b1;
    end
  end

endmodule : ChipInterface
