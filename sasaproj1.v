module axi_stream_slave_interface #(
    parameter TDATA_WIDTH = 64,
    parameter TKEEP_WIDTH = 8,
    parameter TSTRB_WIDTH = 8,
    parameter TLAST_WIDTH = 1,
    parameter TDEST_WIDTH = 2,
    parameter TUSER_WIDTH = 4,
    parameter TID_WIDTH   = 2,
    // Total Packet Width = 64 + 8 + 8 + 1 + 2 + 4 + 2 = 89 bits
    parameter PACKET_WIDTH = TDATA_WIDTH + TKEEP_WIDTH + TSTRB_WIDTH + TLAST_WIDTH + TDEST_WIDTH + TUSER_WIDTH + TID_WIDTH
)
(
    input  wire                    aclk,
    input  wire                    aresetn,

    // AXI4-Stream Slave Interface
    input  wire                    s_axis_tvalid,
    output wire                    s_axis_tready,
    input  wire [TDATA_WIDTH-1:0]  s_axis_tdata,
    input  wire [TKEEP_WIDTH-1:0]  s_axis_tkeep,
    input  wire [TSTRB_WIDTH-1:0]  s_axis_tstrb,
    input  wire                    s_axis_tlast,
    input  wire [TDEST_WIDTH-1:0]  s_axis_tdest,
    input  wire [TUSER_WIDTH-1:0]  s_axis_tuser,
    input  wire [TID_WIDTH-1:0]    s_axis_tid,

    // Interface FIFO
    input  wire                    fifo_full, // موجوده في المدخلات لانها تدخل في منطق ال handchek
    output wire                    fifo_wr_en,
    output wire [PACKET_WIDTH-1:0] fifo_wr_data
);

    // Handshake & Control Logic
    assign s_axis_tready = ~fifo_full; // طول ماهو مش مليان ف بيبعت اشاره انه جاهز 
    assign fifo_wr_en    = s_axis_tvalid & s_axis_tready;
    // الداتا الي هو هيقرأها 
    // Bit Packing (Total: 89 Bits) //concatination
    assign fifo_wr_data = {
        s_axis_tdata, // [88:25] ---> 64 bits
        s_axis_tkeep, // [24:17] ---> 8 bits
        s_axis_tstrb, // [16:9]  ---> 8 bits
        s_axis_tlast, // [8]     ---> 1 bit
        s_axis_tdest, // [7:6]   ---> 2 bits
        s_axis_tuser, // [5:2]   ---> 4 bits
        s_axis_tid    // [1:0]   ---> 2 bits
    };
endmodule
