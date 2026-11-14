// Instruction SRAM wrappers for gf180 (spec/row-8a-instruction-sram-decision.md:
// the instruction SRAM is single-port 1RW, so the fabric is built with
// ISRAM_1RW=1 and instantiates soc_sram_i_1rw).
//
// soc_sram_i_1rw: the same port and the same macro array as soc_sram_d
// (2**(AW-8) sram_256x32 macros, default AW=10: 4 KB); see soc_sram_d.sv for the
// INTERIM / PROVISIONAL notes, which apply here unchanged.
//
// soc_sram_i: the origin's 1rw1r wrapper, kept only so soc_fabric's
// ISRAM_1RW=0 branch resolves. The macro has one port and a second one is a
// bitcell/macro design, out of scope here (CLAUDE.md), so elaborating it is an
// error: build with ISRAM_1RW=1.
module soc_sram_i_1rw #(
    parameter int AW = 10
) (
    input  logic          clk0,
    input  logic          csb0,
    input  logic          web0,
    input  logic [3:0]    wmask0,
    input  logic [AW-1:0] addr0,
    input  logic [31:0]   din0,
    output logic [31:0]   dout0
);
  soc_sram_d #(
      .AW(AW)
  ) u_array (
      .clk0,
      .csb0,
      .web0,
      .wmask0,
      .addr0,
      .din0,
      .dout0
  );
endmodule

module soc_sram_i #(
    parameter int AW = 10
) (
    input  logic          clk0,
    input  logic          csb0,
    input  logic          web0,
    input  logic [3:0]    wmask0,
    input  logic [AW-1:0] addr0,
    input  logic [31:0]   din0,
    output logic [31:0]   dout0,
    input  logic          clk1,
    input  logic          csb1,
    input  logic [AW-1:0] addr1,
    output logic [31:0]   dout1
);
  $error("soc_sram_i (1rw1r) has no gf180 macro: the macro is single-port; build with ISRAM_1RW=1");
  assign dout0 = '0;
  assign dout1 = '0;
endmodule
