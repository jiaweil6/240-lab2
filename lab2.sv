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
  logic PeqC, PltC, PgtC;        // compare flags
  logic ChangeNeeded;            // CgtP (Paid > Cost)
  logic [3:0] Change;            // Paid - Cost

  logic [3:0] FirstCoin4, SecondCoin4; // chosen coins (0/1/3/5)
  logic [3:0] FCval, SCval;    // numeric value of chosen coin (0/1/3/5)

  logic [1:0] P1, T1, C1;        // availability AFTER first coin
  logic [3:0] Rem1;              // remaining after first coin (Change - FCval)

  // Submodule instances
  CompareBlock u_cmp (
    .Cost(Cost),
    .Paid(Paid),
    .PeqC(PeqC),
    .PltC(PltC),
    .PgtC(PgtC)
  );

  // Compare-derived signals / LEDs
  assign ExactAmount = PeqC && (Paid != 4'b0000);
  assign CoughUpMore = PltC;
  assign ChangeNeeded = PgtC;

  Subtracter u_sub (
    .A(Paid),
    .B(Cost),
    .AmB(Change)
  );

  CoinPick u_pick_first (
    .Change(Change),
    .ChangeNeeded(ChangeNeeded),
    .Pentagons(Pentagons),
    .Triangles(Triangles),
    .Circles(Circles),
    .Coin(FirstCoin4),
    .After_P(P1),
    .After_T(T1),
    .After_C(C1)
  );

  assign FCval = FirstCoin4;

  Subtracter u_rem1 (
    .A(Change),
    .B(FCval),
    .AmB(Rem1)
  );

  CoinPick u_pick_second (
    .Change(Rem1),
    .ChangeNeeded(ChangeNeeded),
    .Pentagons(P1),
    .Triangles(T1),
    .Circles(C1),
    .Coin(SecondCoin4)
  );

  assign SCval = SecondCoin4;

  Subtracter u_rem_final (
    .A(Change),
    .B(FCval + SCval),
    .AmB(Remaining)
  );

  assign NotEnoughChange = ChangeNeeded && (Remaining != 4'b0000);

  // Drive outputs (wire-through)
  assign FirstCoin  = FirstCoin4[2:0];
  assign SecondCoin = SecondCoin4[2:0];

endmodule : ChangeMachine



// ==========
// Submodules
// ==========

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


// Subtracter
module Subtracter (
  input  logic [3:0] A,
  input  logic [3:0] B,
  output logic [3:0] AmB
);
  always_comb begin
    AmB = A - B;
  end
endmodule : Subtracter

// CoinPick: choose the coin using priority 5 then 3 then 1
// Respecting availability
module CoinPick (
  input  logic [3:0] Change,
  input  logic       ChangeNeeded,
  input  logic [1:0] Pentagons,
  input  logic [1:0] Triangles,
  input  logic [1:0] Circles,

  output logic [3:0] Coin,
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
      Coin = 4'b0101;
    end else if (can3) begin
      Coin = 4'b0011;
    end else if (can1) begin
      Coin = 4'b0001;
    end else begin
      Coin = 4'b0000;
    end
  end

  // update inventory
  UpdateInventory u_update (
    .Pentagons(Pentagons),
    .Triangles(Triangles),
    .Circles(Circles),
    .Coin(Coin),
    .After_P(After_P),
    .After_T(After_T),
    .After_C(After_C)
  );

endmodule : CoinPick


// Update inventory after coin pick
module UpdateInventory (
  input logic [1:0] Pentagons,
  input logic [1:0] Triangles,
  input logic [1:0] Circles,
  input logic [3:0] Coin,
  output logic [1:0] After_P,
  output logic [1:0] After_T,
  output logic [1:0] After_C
);
  always_comb begin
    After_P = Pentagons - (Coin==4'b0101 ? 1 : 0);
    After_T = Triangles - (Coin==4'b0011 ? 1 : 0);
    After_C = Circles - (Coin==4'b0001 ? 1 : 0);
  end
endmodule : UpdateInventory
