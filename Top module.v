module axi_stream_router_top #(
    parameter DATA_WIDTH = 64, KEEP_WIDTH = 8, STRB_WIDTH = 8, LAST_WIDTH = 1,
    parameter DEST_WIDTH = 2, USER_WIDTH = 4, ID_WIDTH   = 2, ENTRY_DEPTH = 16,
    parameter PACKET_WIDTH = DATA_WIDTH + KEEP_WIDTH + STRB_WIDTH + LAST_WIDTH + DEST_WIDTH + USER_WIDTH + ID_WIDTH // 89 Bits
)(
    input  wire                  aclk, aresetn,
    // AXI4-Stream Slave Interface
    input  wire                  s_axis_tvalid, output wire s_axis_tready,
    input  wire [DATA_WIDTH-1:0] s_axis_tdata,  input  wire [KEEP_WIDTH-1:0] s_axis_tkeep,
    input  wire [STRB_WIDTH-1:0] s_axis_tstrb,  input  wire                  s_axis_tlast,
    input  wire [DEST_WIDTH-1:0] s_axis_tdest,  input  wire [USER_WIDTH-1:0] s_axis_tuser, input wire [ID_WIDTH-1:0] s_axis_tid,

    // Destination 0 Interface
    output wire                  m0_axis_tvalid, input  wire                  m0_axis_tready,
    output wire [DATA_WIDTH-1:0] m0_axis_tdata,  output wire [KEEP_WIDTH-1:0] m0_axis_tkeep,
    output wire [STRB_WIDTH-1:0] m0_axis_tstrb,  output wire                  m0_axis_tlast,
    output wire [USER_WIDTH-1:0] m0_axis_tuser,  output wire [ID_WIDTH-1:0]   m0_axis_tid,

    // Destination 1 Interface
    output wire                  m1_axis_tvalid, input  wire                  m1_axis_tready,
    output wire [DATA_WIDTH-1:0] m1_axis_tdata,  output wire [KEEP_WIDTH-1:0] m1_axis_tkeep,
    output wire [STRB_WIDTH-1:0] m1_axis_tstrb,  output wire                  m1_axis_tlast,
    output wire [USER_WIDTH-1:0] m1_axis_tuser,  output wire [ID_WIDTH-1:0]   m1_axis_tid,

    // Destination 2 Interface
    output wire                  m2_axis_tvalid, input  wire                  m2_axis_tready,
    output wire [DATA_WIDTH-1:0] m2_axis_tdata,  output wire [KEEP_WIDTH-1:0] m2_axis_tkeep,
    output wire [STRB_WIDTH-1:0] m2_axis_tstrb,  output wire                  m2_axis_tlast,
    output wire [USER_WIDTH-1:0] m2_axis_tuser,  output wire [ID_WIDTH-1:0]   m2_axis_tid,

    // Destination 3 Interface
    output wire                  m3_axis_tvalid, input  wire                  m3_axis_tready,
    output wire [DATA_WIDTH-1:0] m3_axis_tdata,  output wire [KEEP_WIDTH-1:0] m3_axis_tkeep,
    output wire [STRB_WIDTH-1:0] m3_axis_tstrb,  output wire                  m3_axis_tlast,
    output wire [USER_WIDTH-1:0] m3_axis_tuser,  output wire [ID_WIDTH-1:0]   m3_axis_tid
);

    // ==========================================
    // Internal Connections
    // ==========================================
    wire [PACKET_WIDTH-1:0] slave_packed_data;
    wire                    fifo_wr_en, fifo_full, fifo_empty, fifo_rd_en;

    // Unpacked Wires to match axi_fifo ports
    wire [DATA_WIDTH-1:0] fifo_wr_data; wire [KEEP_WIDTH-1:0] fifo_wr_keep; wire [STRB_WIDTH-1:0] fifo_wr_strb;
    wire                  fifo_wr_last; wire [DEST_WIDTH-1:0] fifo_wr_dest; wire [USER_WIDTH-1:0] fifo_wr_user;
    wire [ID_WIDTH-1:0]   fifo_wr_id;

    wire [PACKET_WIDTH-1:0] fifo_rd_data;

    wire                  m_router_tvalid, m_router_tready, m_router_tlast;
    wire [DATA_WIDTH-1:0] m_router_tdata; wire [KEEP_WIDTH-1:0] m_router_tkeep; wire [STRB_WIDTH-1:0] m_router_tstrb;
    wire [DEST_WIDTH-1:0] m_router_tdest; wire [USER_WIDTH-1:0] m_router_tuser; wire [ID_WIDTH-1:0]   m_router_tid;

    // Unpack Slave Packed Bus into individual FIFO inputs
    assign {fifo_wr_data, fifo_wr_keep, fifo_wr_strb, fifo_wr_last, fifo_wr_dest, fifo_wr_user, fifo_wr_id} = slave_packed_data;

    // Sub-modules Instantiation
    // 1. Slave Interface
    axi_stream_slave_interface #(
        .TDATA_WIDTH(DATA_WIDTH), .TKEEP_WIDTH(KEEP_WIDTH), .TSTRB_WIDTH(STRB_WIDTH),
        .TLAST_WIDTH(LAST_WIDTH), .TDEST_WIDTH(DEST_WIDTH), .TUSER_WIDTH(USER_WIDTH), .TID_WIDTH(ID_WIDTH)
    ) u_slave_interface 
    (
        .aclk(aclk), .aresetn(aresetn),
        .s_axis_tvalid(s_axis_tvalid), .s_axis_tready(s_axis_tready),
        .s_axis_tdata(s_axis_tdata),   .s_axis_tkeep(s_axis_tkeep),   .s_axis_tstrb(s_axis_tstrb),
        .s_axis_tlast(s_axis_tlast),   .s_axis_tdest(s_axis_tdest),   .s_axis_tuser(s_axis_tuser), .s_axis_tid(s_axis_tid),
        .fifo_full(fifo_full),         .fifo_wr_en(fifo_wr_en),       .fifo_wr_data(slave_packed_data)
    );

    // 2. Synchronous FIFO Storage
    axi_fifo #(
        .DATA_WIDTH(DATA_WIDTH), .ENTRY_DEPTH(ENTRY_DEPTH), .KEEP_WIDTH(KEEP_WIDTH), .STRB_WIDTH(STRB_WIDTH),
        .ID_WIDTH(ID_WIDTH),     .DEST_WIDTH(DEST_WIDTH),   .USER_WIDTH(USER_WIDTH), .LAST_WIDTH(LAST_WIDTH)
    ) u_axi_fifo 
    (
        .ACLK(aclk), .ARESETn(aresetn), .wr_en(fifo_wr_en), .rd_en(fifo_rd_en),
        .wr_data(fifo_wr_data), .wr_keep(fifo_wr_keep), .wr_strb(fifo_wr_strb), .wr_last(fifo_wr_last),
        .wr_dest(fifo_wr_dest), .wr_user(fifo_wr_user), .wr_id(fifo_wr_id),
        .data_out(fifo_rd_data), .fifo_full(fifo_full), .fifo_empty(fifo_empty)
    );

    // 3. Master Interface
    axi_stream_master_interface #(
        .DATA_WIDTH(DATA_WIDTH), .KEEP_WIDTH(KEEP_WIDTH), .STRB_WIDTH(STRB_WIDTH), .LAST_WIDTH(LAST_WIDTH),
        .DEST_WIDTH(DEST_WIDTH), .USER_WIDTH(USER_WIDTH), .ID_WIDTH(ID_WIDTH)
    ) u_master_interface 
    (
        .aclk(aclk), .aresetn(aresetn), .fifo_data_out(fifo_rd_data), .fifo_empty(fifo_empty), .fifo_rd_en(fifo_rd_en),
        .m_axis_tvalid(m_router_tvalid), .m_axis_tready(m_router_tready), .m_axis_tdata(m_router_tdata),
        .m_axis_tkeep(m_router_tkeep),   .m_axis_tstrb(m_router_tstrb),   .m_axis_tlast(m_router_tlast),
        .m_axis_tdest(m_router_tdest),   .m_axis_tuser(m_router_tuser),   .m_axis_tid(m_router_tid)
    );

    // 4. AXI4-Stream Router
    axi_stream_router #(
        .DATA_WIDTH(DATA_WIDTH), .KEEP_WIDTH(KEEP_WIDTH), .STRB_WIDTH(STRB_WIDTH),
        .LAST_WIDTH(LAST_WIDTH), .DEST_WIDTH(DEST_WIDTH), .USER_WIDTH(USER_WIDTH), .ID_WIDTH(ID_WIDTH)
    ) u_router 
    (
        .s_axis_tvalid(m_router_tvalid), .s_axis_tready(m_router_tready), .s_axis_tdata(m_router_tdata),
        .s_axis_tkeep(m_router_tkeep),   .s_axis_tstrb(m_router_tstrb),   .s_axis_tlast(m_router_tlast),
        .s_axis_tdest(m_router_tdest),   .s_axis_tuser(m_router_tuser),   .s_axis_tid(m_router_tid),

        .m0_axis_tvalid(m0_axis_tvalid), .m0_axis_tready(m0_axis_tready), .m0_axis_tdata(m0_axis_tdata),
        .m0_axis_tkeep(m0_axis_tkeep),   .m0_axis_tstrb(m0_axis_tstrb),   .m0_axis_tlast(m0_axis_tlast),
        .m0_axis_tuser(m0_axis_tuser),   .m0_axis_tid(m0_axis_tid),

        .m1_axis_tvalid(m1_axis_tvalid), .m1_axis_tready(m1_axis_tready), .m1_axis_tdata(m1_axis_tdata),
        .m1_axis_tkeep(m1_axis_tkeep),   .m1_axis_tstrb(m1_axis_tstrb),   .m1_axis_tlast(m1_axis_tlast),
        .m1_axis_tuser(m1_axis_tuser),   .m1_axis_tid(m1_axis_tid),

        .m2_axis_tvalid(m2_axis_tvalid), .m2_axis_tready(m2_axis_tready), .m2_axis_tdata(m2_axis_tdata),
        .m2_axis_tkeep(m2_axis_tkeep),   .m2_axis_tstrb(m2_axis_tstrb),   .m2_axis_tlast(m2_axis_tlast),
        .m2_axis_tuser(m2_axis_tuser),   .m2_axis_tid(m2_axis_tid),

        .m3_axis_tvalid(m3_axis_tvalid), .m3_axis_tready(m3_axis_tready), .m3_axis_tdata(m3_axis_tdata),
        .m3_axis_tkeep(m3_axis_tkeep),   .m3_axis_tstrb(m3_axis_tstrb),   .m3_axis_tlast(m3_axis_tlast),
        .m3_axis_tuser(m3_axis_tuser),   .m3_axis_tid(m3_axis_tid)
    );

endmodule
