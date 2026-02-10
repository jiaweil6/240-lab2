module ChipInterface
(
    output logic [ 7:0] D2_SEG , D1_SEG ,
    output logic [ 3:0] D2_AN  , D1_AN  ,
    output logic [15:0] LD ,
    input  logic [15:0] SW ,
    input  logic [ 3:0] BTN ,
    input  logic        CLOCK_100
); // needed for 7 Segs

    EightSevenSegmentDisplays disp (
    .reset ( BTN[2] ) ,
    // other connections
    .*
    );

    // Instantiate your design module here
    // Use assign statements to connect inputs / outputs to
    // the ChipInterface inputs / outputs
    // Add other code as necessary ( like a display driver )

endmodule : ChipInterface
