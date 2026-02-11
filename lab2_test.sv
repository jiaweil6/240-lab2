`default_nettype none

// ===================
// Submodule Testbench
// ===================

// CompareBlock Testbench
// run with: vcs -sverilog lab2.sv lab2_test.sv -top CompareBlock_tb
module CompareBlock_tb;
    logic [3:0] Cost, Paid;
    logic PeqC, PltC, PgtC;

    CompareBlock u_cmp (
        .Cost(Cost),
        .Paid(Paid),
        .PeqC(PeqC),
        .PltC(PltC),
        .PgtC(PgtC)
    );

    initial begin
        $display("CompareBlock Testbench");
        $display(" time | Cost Paid | PeqC PltC PgtC");
        $display("------+-----------+-----------------");
        $monitor("%4t | %4b %4b |   %b     %b     %b",
                $time, Cost, Paid, PeqC, PltC, PgtC);

        // Test cases
        Cost = 4'b0000; Paid = 4'b0000; #1; // expect CeqP=1, CltP=0, CgtP=0
        Cost = 4'b0011; Paid = 4'b0101; #1; // expect CeqP=0, CltP=1, CgtP=0
        Cost = 4'b0110; Paid = 4'b1000; #1; // expect CeqP=0, CltP=1, CgtP=0
        Cost = 4'b0001; Paid = 4'b1111; #1; // expect CeqP=0, CltP=1, CgtP=0
        Cost = 4'b0110; Paid = 4'b0110; #1; // expect CeqP=1, CltP=0, CgtP=0
        Cost = 4'b0100; Paid = 4'b0011; #1; // expect CeqP=0, CltP=0, CgtP=1
        
        $display("All *CompareBlock* test cases passed!");
    end
endmodule : CompareBlock_tb


// Subtracter Testbench
// run with: vcs -sverilog lab2.sv lab2_test.sv -top Subtracter_tb
module Subtracter_tb;
    logic [3:0] Paid, Cost, Change;

    Subtracter u_sub (
        .A(Paid),
        .B(Cost),
        .AmB(Change)
    );

    initial begin
        $display("ChangeSubtract Testbench");
        $display(" time | Paid Cost | Change");
        $display("------+-----------+-------");
        $monitor("%4t | %4b %4b | %4b", $time, Paid, Cost, Change);

        // Test cases
        Paid = 4'b0000; Cost = 4'b0000; #1; // expect Change=0000
        Paid = 4'b0101; Cost = 4'b0011; #1; // expect Change=0010 (5-3=2)
        Paid = 4'b1000; Cost = 4'b0110; #1; // expect Change=0010 (8-6=2)
        Paid = 4'b1111; Cost = 4'b0001; #1; // expect Change=1110 (15-1=14)
        Paid = 4'b0110; Cost = 4'b0110; #1; // expect Change=0000 (6-6=0)
        // expect Change=1111 (3-4=-1 mod16=15)
        Paid = 4'b0011; Cost = 4'b0100; #1;
        
        $display("All *Subtracter* test cases passed!");
    end
endmodule : Subtracter_tb

// CoinPick Testbench
// run with: vcs -sverilog lab2.sv lab2_test.sv -top CoinPick_tb
module CoinPick_tb;
    logic [3:0] Change;
    logic       ChangeNeeded;
    logic [1:0] Pentagons, Triangles, Circles;
    logic [3:0] Coin;
    logic [1:0] After_P, After_T, After_C;

    CoinPick u_pick (
        .Change(Change),
        .ChangeNeeded(ChangeNeeded),
        .Pentagons(Pentagons),
        .Triangles(Triangles),
        .Circles(Circles),
        .Coin(Coin),
        .After_P(After_P),
        .After_T(After_T),
        .After_C(After_C)
    );

    initial begin
        $display("CoinPick Testbench");
        $display(
            " time | Change ChgNed P T C | Coin | After_P After_T After_C"
        );
        $display("------+-------------------+------+-------------------------");
        $monitor("%4t | %4b   %b   %b %b %b | %4b |   %b       %b       %b",
                $time, Change, ChangeNeeded, Pentagons, Triangles,
                Circles, Coin, After_P, After_T, After_C);

        // Test cases
        // expect Coin=0101, After_P=01, After_T=10, After_C=10
        Change = 4'b0110; ChangeNeeded=1; Pentagons=2; Triangles=2;
        Circles=2; #1;
        // expect Coin=0011, After_P=01, After_T=00, After_C=01
        Change = 4'b0010; ChangeNeeded=1; Pentagons=1; Triangles=1;
        Circles=1; #1;
        // expect Coin=0000, no change in inventory
        Change = 4'b0001; ChangeNeeded=1; Pentagons=0; Triangles=0;
        Circles=0; #1;
        // expect Coin=0000, no change in inventory
        Change = 4'b0100; ChangeNeeded=0; Pentagons=2; Triangles=2;
        Circles=2; #1;
        // expect Coin=0001, After_P=00, After_T=00, After_C=01
        Change = 4'b0001; ChangeNeeded=1; Pentagons=0; Triangles=0;
        Circles=2; #1;
        // expect Coin=0101, After_P=01, After_T=10, After_C=10
        Change = 4'b1000; ChangeNeeded=1; Pentagons=2; Triangles=2;
        Circles=2; #1;

        $display("All *CoinPick* test cases passed!");
    end
endmodule : CoinPick_tb

// UpdateInventory Testbench
// run with: vcs -sverilog lab2.sv lab2_test.sv -top UpdateInventory_tb
module UpdateInventory_tb;
    logic [1:0] Pentagons, Triangles, Circles;
    logic [3:0] Coin;
    logic [1:0] After_P, After_T, After_C;

    UpdateInventory u_update (
        .Pentagons(Pentagons),
        .Triangles(Triangles),
        .Circles(Circles),
        .Coin(Coin),
        .After_P(After_P),
        .After_T(After_T),
        .After_C(After_C)
    );

    initial begin
        $display("UpdateInventory Testbench");
        $display(" time | P T C | Coin | After_P After_T After_C");
        $display("------+-------+------+-------------------------");
        $monitor("%4t | %b %b %b | %4b |   %b       %b       %b",
                $time, Pentagons, Triangles, Circles, Coin,
                After_P, After_T, After_C);

        // Test cases
        // expect After_P=01, After_T=10, After_C=10
        Pentagons = 2; Triangles = 2; Circles = 2; Coin = 4'b0101; #1;
        // expect After_P=01, After_T=00, After_C=01
        Pentagons = 1; Triangles = 1; Circles = 1; Coin = 4'b0011; #1;
        // expect no change since no coins available
        Pentagons = 0; Triangles = 0; Circles = 0; Coin = 4'b0001; #1;
        // expect no change since no coin given
        Pentagons = 2; Triangles = 2; Circles = 2; Coin = 4'b0000; #1;
        
        $display("All *UpdateInventory* test cases passed!");
    end
endmodule : UpdateInventory_tb


// ===================
// Top-level Testbench
// ===================

// run with: vcs -sverilog lab2.sv lab2_test.sv -top ChangeMachine_tb

module ChangeMachine_tb;
    // Inputs
    logic [3:0] Cost;
    logic [3:0] Paid;
    logic [1:0] Pentagons;
    logic [1:0] Triangles;
    logic [1:0] Circles;

    // Outputs
    logic [2:0] FirstCoin;
    logic [2:0] SecondCoin;
    logic [3:0] Remaining;
    logic       ExactAmount;
    logic       CoughUpMore;
    logic       NotEnoughChange;
    integer     errors;

    ChangeMachine u_machine (
        .Cost(Cost),
        .Paid(Paid),
        .Pentagons(Pentagons),
        .Triangles(Triangles),
        .Circles(Circles),
        .FirstCoin(FirstCoin),
        .SecondCoin(SecondCoin),
        .Remaining(Remaining),
        .ExactAmount(ExactAmount),
        .CoughUpMore(CoughUpMore),
        .NotEnoughChange(NotEnoughChange)
    );

    initial begin
        errors = 0;
        $display("ChangeMachine Testbench");
        $display(" time | Cost Paid P T C | Fst Snd | Rem | Ex More NEC");
        $display("------+------------------+---------+-----+-------------");
        $monitor("%4t | %4b %4b %b %b %b | %3b %3b | %4b |  %b    %b    %b",
                 $time, Cost, Paid, Pentagons, Triangles, Circles,
                 FirstCoin, SecondCoin, Remaining, ExactAmount,
                 CoughUpMore, NotEnoughChange);

        // Exact amount
        Cost=4'd5; Paid=4'd5; Pentagons=2; Triangles=2; Circles=2; #1;
        if (FirstCoin!==3'd0 || SecondCoin!==3'd0 || Remaining!==4'd0 ||
            ExactAmount!==1'b1 || CoughUpMore!==1'b0 ||
            NotEnoughChange!==1'b0) errors = errors + 1;

        // Underpay
        Cost=4'd6; Paid=4'd4; Pentagons=2; Triangles=2; Circles=2; #1;
        if (FirstCoin!==3'd0 || SecondCoin!==3'd0 || Remaining!==4'd14 ||
            ExactAmount!==1'b0 || CoughUpMore!==1'b1 ||
            NotEnoughChange!==1'b0) errors = errors + 1;

        // Change 6 -> 5 then 1
        Cost=4'd2; Paid=4'd8; Pentagons=2; Triangles=2; Circles=2; #1;
        if (FirstCoin!==3'd5 || SecondCoin!==3'd1 || Remaining!==4'd0 ||
            ExactAmount!==1'b0 || CoughUpMore!==1'b0 ||
            NotEnoughChange!==1'b0) errors = errors + 1;

        // Change 8 -> 5 then 3
        Cost=4'd2; Paid=4'd10; Pentagons=1; Triangles=1; Circles=1; #1;
        if (FirstCoin!==3'd5 || SecondCoin!==3'd3 || Remaining!==4'd0 ||
            ExactAmount!==1'b0 || CoughUpMore!==1'b0 ||
            NotEnoughChange!==1'b0) errors = errors + 1;

        // Not enough change (only one 3 for change 4)
        Cost=4'd1; Paid=4'd5; Pentagons=0; Triangles=1; Circles=0; #1;
        if (FirstCoin!==3'd3 || SecondCoin!==3'd0 || Remaining!==4'd1 ||
            ExactAmount!==1'b0 || CoughUpMore!==1'b0 ||
            NotEnoughChange!==1'b1) errors = errors + 1;

        // Not enough change (only one 1 for change 2)
        Cost=4'd1; Paid=4'd3; Pentagons=0; Triangles=0; Circles=1; #1;
        if (FirstCoin!==3'd1 || SecondCoin!==3'd0 || Remaining!==4'd1 ||
            ExactAmount!==1'b0 || CoughUpMore!==1'b0 ||
            NotEnoughChange!==1'b1) errors = errors + 1;

        if (errors == 0) $display("All *ChangeMachine* test cases passed!");
        else $display("ChangeMachine test failed with %0d error(s).", errors);
    end

endmodule : ChangeMachine_tb
