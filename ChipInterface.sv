module ChipInterface
(output logic [ 7:0] D2_SEG, D1_SEG,
 output logic [ 3:0] D2_AN, D1_AN,
 output logic [15:0] LD,
 input  logic [15:0] SW,
 input  logic [ 3:0] BTN,
 input  logic        CLOCK_100); // needed for 7 Segs

  logic [2:0] FirstCoin, SecondCoin;

  EightSevenSegmentDisplays disp (
    .reset(BTN[2]),
    .HEX7(FirstCoin),
    .HEX6(SecondCoin),
    .*);

  // Instantiate your design module here
  // Use assign statements to connect inputs / outputs to
  // the ChipInterface inputs / outputs
  // Add other code as necessary ( like a display driver )

  ChangeMachine u_change_machine (
    .Cost(SW[15:12]),
    .Pentagons(SW[11:10]),
    .Triangles(SW[9:8]),
    .Circles(SW[7:6]),
    .Paid(SW[3:0]),
    .FirstCoin(FirstCoin),
    .SecondCoin(SecondCoin),
    .ExactAmount(LD[15]),
    .NotEnoughChange(LD[14]),
    .CoughUpMore(LD[13]));

endmodule : ChipInterface
