`default_nettype none

// Top-level: ChangeMachine
module ChangeMachine (
  input logic [3:0] Cost,
  input logic [3:0] Paid,
  input logic [1:0] Pentagons,   // available count of 5
  input logic [1:0] Triangles,   // available count of 3
  input logic [1:0] Circles,     // available count of 1

  output logic [2:0] FirstCoin,
  output logic [2:0] SecondCoin,
  output logic [3:0] Remaining,

  output logic ExactAmount,
  output logic CoughUpMore,
  output logic NotEnoughChange
);

  // Internal wires
  logic CeqP, CltP, CgtP;        // compare flags
  logic ChangeNeeded;            // CgtP (Paid > Cost)
  logic [3:0] Change;            // Paid - Cost

  logic [2:0] first_coin, second_coin;
  logic [3:0] fc_val, sc_val;    // numeric value of chosen coin (0/1/3/5)

  logic [1:0] P1, T1, C1;        // availability AFTER first coin
  logic [3:0] Rem1;              // remaining after first coin (Change - fc_val)

  // Submodule instances
  CompareBlock u_cmp (
    .Cost(Cost),
    .Paid(Paid),
    .CeqP(CeqP),
    .CltP(CltP),
    .CgtP(CgtP)
  );

  // Compare-derived signals / LEDs
  assign ChangeNeeded = CgtP;
  assign CoughUpMore  = CltP;

  // NOTE: If your lab defines ExactAmount differently, edit this line.
  assign ExactAmount  = CeqP && (Paid != 4'b0000) && (Cost != 4'b0000);

  ChangeSubtract u_sub (
    .Paid(Paid),
    .Cost(Cost),
    .Change(Change)
  );

  FirstCoinPick u_pick1 (
    .Change(Change),
    .ChangeNeeded(ChangeNeeded),
    .Pentagons(Pentagons),
    .Triangles(Triangles),
    .Circles(Circles),
    .FirstCoin(first_coin),
    .FC_val(fc_val),
    .After1_P(P1),
    .After1_T(T1),
    .After1_C(C1)
  );

  RemainingAfterFirst u_rem1 (
    .Change(Change),
    .FC_val(fc_val),
    .Rem1(Rem1)
  );

  SecondCoinPick u_pick2 (
    .Rem1(Rem1),
    .ChangeNeeded(ChangeNeeded),
    .Pentagons(P1),
    .Triangles(T1),
    .Circles(C1),
    .SecondCoin(second_coin),
    .SC_val(sc_val)
  );

  FinalRemaining u_rem_final (
    .Change(Change),
    .FC_val(fc_val),
    .SC_val(sc_val),
    .Remaining(Remaining)
  );

  assign NotEnoughChange = ChangeNeeded && (Remaining != 4'b0000);

  // Drive outputs (wire-through)
  assign FirstCoin  = first_coin;
  assign SecondCoin = second_coin;

endmodule : ChangeMachine


// Submodules

// CompareBlock: compute eq/lt/gt for Paid vs Cost
module CompareBlock (
  input  logic [3:0] Cost,
  input  logic [3:0] Paid,
  output logic       PeqC,
  output logic       PltC,
  output logic       PgtC
);
  always_comb begin
    PeqC = (Paid == Cost);
    PltC = (Paid < Cost);
    PgtC = (Paid > Cost);
  end
endmodule : CompareBlock


// ChangeSubtract: Change = Paid - Cost (unsigned 4-bit)
module ChangeSubtract (
  input  logic [3:0] Paid,
  input  logic [3:0] Cost,
  output logic [3:0] Change
);
  always_comb begin
    Change = Paid - Cost;
  end
endmodule : ChangeSubtract


// FirstCoinPick: choose FirstCoin using priority 5 then 3 then 1, respecting availability
module FirstCoinPick (
  input  logic [3:0] Change,
  input  logic       ChangeNeeded,
  input  logic [1:0] Pentagons,
  input  logic [1:0] Triangles,
  input  logic [1:0] Circles,

  output logic [2:0] FirstCoin,
  output logic [3:0] FC_val,

  output logic [1:0] After1_P,
  output logic [1:0] After1_T,
  output logic [1:0] After1_C
);

  always_comb begin
    // PSEUDOCODE:
    // can5 = ChangeNeeded && (Change >= 5) && (Pentagons > 0)
    // can3 = ChangeNeeded && (Change >= 3) && (Triangles > 0)
    // can1 = ChangeNeeded && (Change >= 1) && (Circles   > 0)
    //
    // if can5: FirstCoin=3'b101, FC_val=5
    // else if can3: FirstCoin=3'b011, FC_val=3
    // else if can1: FirstCoin=3'b001, FC_val=1
    // else: FirstCoin=3'b000, FC_val=0
    //
    // After1_P = Pentagons - (FirstCoin==3'b101 ? 1 : 0)
    // After1_T = Triangles - (FirstCoin==3'b011 ? 1 : 0)
    // After1_C = Circles   - (FirstCoin==3'b001 ? 1 : 0)

    FirstCoin = 3'b000;
    FC_val    = 4'b0000;

    After1_P  = Pentagons;
    After1_T  = Triangles;
    After1_C  = Circles;
  end

endmodule : FirstCoinPick


// RemainingAfterFirst: Rem1 = Change - FC_val
module RemainingAfterFirst (
  input  logic [3:0] Change,
  input  logic [3:0] FC_val,
  output logic [3:0] Rem1
);
  always_comb begin
    Rem1 = Change - FC_val
  end
endmodule : RemainingAfterFirst


// SecondCoinPick: choose SecondCoin with same priority using Rem1 and updated availability
module SecondCoinPick (
  input  logic [3:0] Rem1,
  input  logic       ChangeNeeded,
  input  logic [1:0] Pentagons,
  input  logic [1:0] Triangles,
  input  logic [1:0] Circles,

  output logic [2:0] SecondCoin,
  output logic [3:0] SC_val
);

  always_comb begin
    // PSEUDOCODE:
    // can5 = ChangeNeeded && (Rem1 >= 5) && (Pentagons > 0)
    // can3 = ChangeNeeded && (Rem1 >= 3) && (Triangles > 0)
    // can1 = ChangeNeeded && (Rem1 >= 1) && (Circles   > 0)
    //
    // if can5: SecondCoin=3'b101, SC_val=5
    // else if can3: SecondCoin=3'b011, SC_val=3
    // else if can1: SecondCoin=3'b001, SC_val=1
    // else: SecondCoin=3'b000, SC_val=0

    SecondCoin = 3'b000;
    SC_val     = 4'b0000;
  end

endmodule : SecondCoinPick


// FinalRemaining: Remaining = Change - FC_val - SC_val
module FinalRemaining (
  input  logic [3:0] Change,
  input  logic [3:0] FC_val,
  input  logic [3:0] SC_val,
  output logic [3:0] Remaining
);
  always_comb begin
    Remaining = Change - FC_val - SC_val;
  end
endmodule : FinalRemaining
