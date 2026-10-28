// INTERIM black-box declaration of the gf180-sram macro, for lint and for
// `klt synthesize` (request `macros[].verilog_blackbox`). Not a model: no
// behaviour, no timing.
//
// The pin list is the one proposed in gf180-sram spec/macro-interface-decision.md
// (A[7:0], CEN, CLK, D[31:0], Q[31:0], GWEN, WEN[31:0]; CEN/GWEN/WEN active
// low) and is NOT ratified (gf180-sram#197). It is not derived from any LEF:
// the only LEF at the pinned gf180-sram commit is the 322-pin array core.
// Governed by spec/macro-views-interim-decision.md; retire this file when the
// macro-level LEF and Liberty views exist and are pinned in reuse.lock.json.
// VDD/VSS are physical pins and are not in the netlist.
(* blackbox *)
module sram_256x32 (
    input  wire [7:0]  A,
    input  wire        CEN,
    input  wire        CLK,
    input  wire [31:0] D,
    output wire [31:0] Q,
    input  wire        GWEN,
    input  wire [31:0] WEN
);
endmodule
