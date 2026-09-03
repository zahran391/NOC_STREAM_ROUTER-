module axi_stream_master_interface #(
    parameter DATA_WIDTH   = 64,
    parameter KEEP_WIDTH   = 8,
    parameter STRB_WIDTH   = 8,
    parameter LAST_WIDTH   = 1,
    parameter DEST_WIDTH   = 2,
    parameter USER_WIDTH   = 4,
    parameter ID_WIDTH     = 2,
    parameter PACKET_WIDTH = DATA_WIDTH + KEEP_WIDTH + STRB_WIDTH + LAST_WIDTH + DEST_WIDTH + USER_WIDTH + ID_WIDTH // 89 Bits
)
(
    // Global Clock & Reset
    input  wire                    aclk,
    input  wire                    aresetn,

    // Signals from/to Synchronous FIFO
    input  wire [PACKET_WIDTH-1:0] fifo_data_out, // الـ Packet الـ 89 bits اللي جاية من الـ FIFO
    input  wire                    fifo_empty,    // إشارة إن الـ FIFO فاضية
    output wire                    fifo_rd_en,    // أمر القراءة الموجه للـ FIFO

    // AXI4-Stream Master Outputs (تتصل مباشرة بمدخل الـ Router)
    output wire                    m_axis_tvalid, // الداتا طالعة جاهزة
    input  wire                    m_axis_tready, // الـ Router جاهز يستقبل
    output wire [DATA_WIDTH-1:0]   m_axis_tdata,  // Payload (64 bits)
    output wire [KEEP_WIDTH-1:0]   m_axis_tkeep,  // Byte Enables (8 bits)
    output wire [STRB_WIDTH-1:0]   m_axis_tstrb,  // Strobe Control (8 bits)
    output wire                    m_axis_tlast,  // End of Frame Flag (1 bit)
    output wire [DEST_WIDTH-1:0]   m_axis_tdest,  // Target Address (2 bits)
    output wire [USER_WIDTH-1:0]   m_axis_tuser,  // User Sideband (4 bits)
    output wire [ID_WIDTH-1:0]     m_axis_tid     // Stream Source ID (2 bits)
);


    reg data_valid_reg;

    assign fifo_rd_en = (!fifo_empty && (!m_axis_tvalid || m_axis_tready));

    
    always @(posedge aclk or negedge aresetn) 
    begin
        if (!aresetn) 
        begin
            data_valid_reg <= 1'b0;
        end
         else 
         begin
            if (fifo_rd_en) begin
                data_valid_reg <= 1'b1; // طلبت قراءة، فالـ Clock الجاية هتوصل داتا صحيحة
            end else if (m_axis_tready) begin
                data_valid_reg <= 1'b0; // الـ Router استلم الداتا وخلاص خلصنا
            end
        end
    end

    
    assign m_axis_tvalid = data_valid_reg;

    // (Unpacking)
    assign {m_axis_tdata, 
            m_axis_tkeep, 
            m_axis_tstrb, 
            m_axis_tlast, 
            m_axis_tdest, 
            m_axis_tuser, 
            m_axis_tid} = fifo_data_out;

endmodule
