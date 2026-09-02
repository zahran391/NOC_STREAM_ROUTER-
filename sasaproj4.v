module axi_stream_router #(
    parameter DATA_WIDTH = 64,
    parameter KEEP_WIDTH = 8,
    parameter STRB_WIDTH = 8,
    parameter LAST_WIDTH = 1,
    parameter DEST_WIDTH = 2,
    parameter USER_WIDTH = 4,
    parameter ID_WIDTH   = 2
)(
    // AXI4-Stream Input (Master Interface)
    input  wire                  s_axis_tvalid,
    output reg                   s_axis_tready,
    input  wire [DATA_WIDTH-1:0] s_axis_tdata,
    input  wire [KEEP_WIDTH-1:0] s_axis_tkeep,
    input  wire [STRB_WIDTH-1:0] s_axis_tstrb,
    input  wire                  s_axis_tlast,
    input  wire [DEST_WIDTH-1:0] s_axis_tdest,
    input  wire [USER_WIDTH-1:0] s_axis_tuser,
    input  wire [ID_WIDTH-1:0]   s_axis_tid,

    // Destination 0 Interface
    output reg                   m0_axis_tvalid,
    input  wire                  m0_axis_tready,
    output wire [DATA_WIDTH-1:0] m0_axis_tdata,
    output wire [KEEP_WIDTH-1:0] m0_axis_tkeep,
    output wire [STRB_WIDTH-1:0] m0_axis_tstrb,
    output wire                  m0_axis_tlast,
    output wire [USER_WIDTH-1:0] m0_axis_tuser,
    output wire [ID_WIDTH-1:0]   m0_axis_tid,

    // Destination 1 Interface
    output reg                   m1_axis_tvalid,
    input  wire                  m1_axis_tready,
    output wire [DATA_WIDTH-1:0] m1_axis_tdata,
    output wire [KEEP_WIDTH-1:0] m1_axis_tkeep,
    output wire [STRB_WIDTH-1:0] m1_axis_tstrb,
    output wire                  m1_axis_tlast,
    output wire [USER_WIDTH-1:0] m1_axis_tuser,
    output wire [ID_WIDTH-1:0]   m1_axis_tid,

    // Destination 2 Interface
    output reg                   m2_axis_tvalid,
    input  wire                  m2_axis_tready,
    output wire [DATA_WIDTH-1:0] m2_axis_tdata,
    output wire [KEEP_WIDTH-1:0] m2_axis_tkeep,
    output wire [STRB_WIDTH-1:0] m2_axis_tstrb,
    output wire                  m2_axis_tlast,
    output wire [USER_WIDTH-1:0] m2_axis_tuser,
    output wire [ID_WIDTH-1:0]   m2_axis_tid,

    // Destination 3 Interface
    output reg                   m3_axis_tvalid,
    input  wire                  m3_axis_tready,
    output wire [DATA_WIDTH-1:0] m3_axis_tdata,
    output wire [KEEP_WIDTH-1:0] m3_axis_tkeep,
    output wire [STRB_WIDTH-1:0] m3_axis_tstrb,
    output wire                  m3_axis_tlast,
    output wire [USER_WIDTH-1:0] m3_axis_tuser,
    output wire [ID_WIDTH-1:0]   m3_axis_tid
);

    //  تمرير البيانات (Data Bus Broadcast) لجميع المنافذ لتوفير المساحة الهيكلية
    assign m0_axis_tdata = s_axis_tdata;  assign m0_axis_tkeep = s_axis_tkeep; 
    assign m0_axis_tstrb = s_axis_tstrb;  assign m0_axis_tlast = s_axis_tlast;  
    assign m0_axis_tuser = s_axis_tuser;  assign m0_axis_tid = s_axis_tid;
    assign m1_axis_tdata = s_axis_tdata;  assign m1_axis_tkeep = s_axis_tkeep;  
    assign m1_axis_tstrb = s_axis_tstrb;  assign m1_axis_tlast = s_axis_tlast;  
    assign m1_axis_tuser = s_axis_tuser;  assign m1_axis_tid = s_axis_tid;
    assign m2_axis_tdata = s_axis_tdata;  assign m2_axis_tkeep = s_axis_tkeep;  
    assign m2_axis_tstrb = s_axis_tstrb;  assign m2_axis_tlast = s_axis_tlast;  
    assign m2_axis_tuser = s_axis_tuser;  assign m2_axis_tid = s_axis_tid;
    assign m3_axis_tdata = s_axis_tdata;  assign m3_axis_tkeep = s_axis_tkeep;  
    assign m3_axis_tstrb = s_axis_tstrb;  assign m3_axis_tlast = s_axis_tlast;  
    assign m3_axis_tuser = s_axis_tuser;  assign m3_axis_tid = s_axis_tid;
    always @(*) begin
        // القيم الافتراضية للـ Valids والـ Ready
        m0_axis_tvalid = 1'b0;
        m1_axis_tvalid = 1'b0;
        m2_axis_tvalid = 1'b0;
        m3_axis_tvalid = 1'b0;
        s_axis_tready  = 1'b0;
        // انا خلاص عملت ان الداتا يحصل لها توصل لكله بس محدش هيستلمها من غير ان لمبه تنور عنده
        // tvalid --> هي اللمبه الي لما تنور خلاص يستلم الداتا 
        case (s_axis_tdest)
            2'b00: 
            begin
                m0_axis_tvalid = s_axis_tvalid; 
                s_axis_tready  = m0_axis_tready; // هنا ربطه الجاهزيه للجهاز الي هيستقبل بالماستر 
    // بحيث انه لو بصفر يعني مش جاهز يستقبل لا يرجع خطوه للخلف للماستر لغايه ماتيجي اشاره ب 1 ان الجهاز جاهز
            end
            2'b01: 
            begin
                m1_axis_tvalid = s_axis_tvalid;
                s_axis_tready  = m1_axis_tready;
            end
            2'b10: begin
                m2_axis_tvalid = s_axis_tvalid;
                s_axis_tready  = m2_axis_tready;
            end
            2'b11: 
            begin
                m3_axis_tvalid = s_axis_tvalid;
                s_axis_tready  = m3_axis_tready;
            end
            default: 
            begin
                s_axis_tready  = 1'b0;
            end
        endcase
    end
endmodule