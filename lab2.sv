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

  logic [2:0] first_coin, second_coin; // chosen coins (0/1/3/5)
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
  assign CoughUpMore = CltP;
  assign ExactAmount = CeqP && (Paid != 4'b0000) && (Cost != 4'b0000);

  ChangeSubtract u_sub (
    .Paid(Paid),
    .Cost(Cost),
    .Change(Change)
  );

  CoinPick u_pickFirst (
    .Change(Change),
    .ChangeNeeded(ChangeNeeded),
    .Pentagons(Pentagons),
    .Triangles(Triangles),
    .Circles(Circles),
    .Coin(first_coin),
    .val(fc_val),
    .After_P(P1),
    .After_T(T1),
    .After_C(C1)
  );

  RemainingAfterFirst u_rem1 (
    .Change(Change),
    .FC_val(fc_val),
    .Rem1(Rem1)
  );

  SecondCoinPick u_pickSecond (
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


// CoinPick: choose the coin using priority 5 then 3 then 1
// Respecting availability
module CoinPick (
  input  logic [3:0] Change,
  input  logic       ChangeNeeded,
  input  logic [1:0] Pentagons,
  input  logic [1:0] Triangles,
  input  logic [1:0] Circles,

  output logic [2:0] Coin,
  output logic [3:0] val,

  output logic [1:0] After_P,
  output logic [1:0] After_T,
  output logic [1:0] After_C
);

  logic can5, can3, can1;

  always_comb begin
    can5 = ChangeNeeded && (Change >= 5) && (Pentagons > 0);
    can3 = ChangeNeeded && (Change >= 3) && (Triangles > 0);
    can1 = ChangeNeeded && (Change >= 1) && (Circles > 0);

    if (can5) begin
      Coin = 3'b101;
      val = 4'b0101;
    end else if (can3) begin
      Coin = 3'b011;
      val = 4'b0011;
    end else if (can1) begin
      Coin = 3'b001;
      val = 4'b0001;
    end else begin
      Coin = 3'b000;
      val = 4'b0000;
    end
    
    After_P = Pentagons - (Coin==3'b101 ? 1 : 0);
    After_T = Triangles - (Coin==3'b011 ? 1 : 0);
    After_C = Circles - (Coin==3'b001 ? 1 : 0);
  end

endmodule : CoinPick


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
