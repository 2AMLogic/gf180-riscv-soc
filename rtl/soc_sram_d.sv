// Data SRAM wrapper, 2**AW x 32 (default AW=10: 4 KB), 1rw, 8-bit write
// granularity, built from 2**(AW-8) gf180-sram `sram_256x32` macros
// (spec/sram-instance-plan-decision.md): word address addr0[7:0] goes to the
// macros, addr0[AW-1:8] selects one macro through CEN. Same OpenRAM-style
// port as the origin's wrapper (active-low csb/web, one-cycle registered read).
//
// INTERIM (spec/macro-views-interim-decision.md): the macro pin names,
// polarity and read latency below follow gf180-sram
// spec/macro-interface-decision.md, which is proposed, not ratified
// (gf180-sram#197). Marked PROVISIONAL where they matter. No behavioural model
// of the macro exists here, so this wrapper does not simulate on its own.
module soc_sram_d #(
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
  localparam int NM = 2 ** (AW - 8);

  if (AW < 9 || AW > 11) begin : g_aw_check
    $error("soc_sram_d: AW must be 9..11 (2, 4 or 8 sram_256x32 macros)");
  end

  logic [31:0] macro_q[NM];
  logic [AW-9:0] msel;

  // PROVISIONAL: WEN[i] active low, one bit per data bit; be[b] -> bits 8b+:8.
  logic [31:0] wen;
  assign wen = ~{{8{wmask0[3]}}, {8{wmask0[2]}}, {8{wmask0[1]}}, {8{wmask0[0]}}};

  for (genvar k = 0; k < NM; k++) begin : g_macro
    sram_256x32 u_macro (
        .A   (addr0[7:0]),
        .CEN (csb0 || addr0[AW-1:8] != (AW - 8)'(k)),
        .CLK (clk0),
        .D   (din0),
        .Q   (macro_q[k]),
        .GWEN(web0),  // PROVISIONAL: GWEN low = write, as web0
        .WEN (wen)
    );
  end

  // Q holds the last read of its macro (PROVISIONAL: 1-cycle latency), so the
  // output mux uses the select registered on the last read.
  always_ff @(posedge clk0) if (!csb0 && web0) msel <= addr0[AW-1:8];

  assign dout0 = macro_q[msel];
endmodule
