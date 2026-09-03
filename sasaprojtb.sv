`timescale 1ns / 1ps

module tb_axi_stream_router;

    // Parameters
    parameter DATA_WIDTH = 64, KEEP_WIDTH = 8, STRB_WIDTH = 8, LAST_WIDTH = 1;
    parameter DEST_WIDTH = 2, USER_WIDTH = 4, ID_WIDTH   = 2, ENTRY_DEPTH = 16;
    parameter PACKET_WIDTH = DATA_WIDTH + KEEP_WIDTH + STRB_WIDTH + LAST_WIDTH + DEST_WIDTH + USER_WIDTH + ID_WIDTH;

    // DUT Signals
    reg                  aclk, aresetn;
    reg                  s_axis_tvalid;
    wire                 s_axis_tready;
    reg [DATA_WIDTH-1:0] s_axis_tdata;
    reg [KEEP_WIDTH-1:0] s_axis_tkeep;
    reg [STRB_WIDTH-1:0] s_axis_tstrb;
    reg                  s_axis_tlast;
    reg [DEST_WIDTH-1:0] s_axis_tdest;
    reg [USER_WIDTH-1:0] s_axis_tuser;
    reg [ID_WIDTH-1:0]   s_axis_tid;

    wire                 m_tvalid[0:3];
    reg                  m_tready[0:3];
    wire [DATA_WIDTH-1:0] m_tdata[0:3];
    wire [KEEP_WIDTH-1:0] m_tkeep[0:3];
    wire [STRB_WIDTH-1:0] m_tstrb[0:3];
    wire                 m_tlast[0:3];
    wire [USER_WIDTH-1:0] m_tuser[0:3];
    wire [ID_WIDTH-1:0]   m_tid[0:3];

    // Testbench Control & Scoreboard Variables
    integer error_count = 0;
    integer success_count = 0;

    // Packed Struct for Data Storage
    typedef struct packed {
        bit [DATA_WIDTH-1:0] tdata;
        bit [KEEP_WIDTH-1:0] tkeep;
        bit [STRB_WIDTH-1:0] tstrb;
        bit                  tlast;
        bit [USER_WIDTH-1:0] tuser;
        bit [ID_WIDTH-1:0]   tid;
    } packet_t;

    // Array FIFOs to replace Dynamic Queues for Iverilog Compatibility
    packet_t exp_fifo[0:3][0:127];
    integer  wr_ptr[0:3];
    integer  rd_ptr[0:3];

    // Clock Generation (100 MHz -> Period 10ns)
    always #5 aclk = ~aclk;

    // Instantiate Top Module
    axi_stream_router_top #(
        .DATA_WIDTH(DATA_WIDTH), .KEEP_WIDTH(KEEP_WIDTH), .STRB_WIDTH(STRB_WIDTH),
        .LAST_WIDTH(LAST_WIDTH), .DEST_WIDTH(DEST_WIDTH), .USER_WIDTH(USER_WIDTH),
        .ID_WIDTH(ID_WIDTH),     .ENTRY_DEPTH(ENTRY_DEPTH)
    ) dut (
        .aclk(aclk), .aresetn(aresetn),
        .s_axis_tvalid(s_axis_tvalid), .s_axis_tready(s_axis_tready),
        .s_axis_tdata(s_axis_tdata),   .s_axis_tkeep(s_axis_tkeep),   .s_axis_tstrb(s_axis_tstrb),
        .s_axis_tlast(s_axis_tlast),   .s_axis_tdest(s_axis_tdest),   .s_axis_tuser(s_axis_tuser), .s_axis_tid(s_axis_tid),

        .m0_axis_tvalid(m_tvalid[0]), .m0_axis_tready(m_tready[0]), .m0_axis_tdata(m_tdata[0]),
        .m0_axis_tkeep(m_tkeep[0]),   .m0_axis_tstrb(m_tstrb[0]),   .m0_axis_tlast(m_tlast[0]),
        .m0_axis_tuser(m_tuser[0]),   .m0_axis_tid(m_tid[0]),

        .m1_axis_tvalid(m_tvalid[1]), .m1_axis_tready(m_tready[1]), .m1_axis_tdata(m_tdata[1]),
        .m1_axis_tkeep(m_tkeep[1]),   .m1_axis_tstrb(m_tstrb[1]),   .m1_axis_tlast(m_tlast[1]),
        .m1_axis_tuser(m_tuser[1]),   .m1_axis_tid(m_tid[1]),

        .m2_axis_tvalid(m_tvalid[2]), .m2_axis_tready(m_tready[2]), .m2_axis_tdata(m_tdata[2]),
        .m2_axis_tkeep(m_tkeep[2]),   .m2_axis_tstrb(m_tstrb[2]),   .m2_axis_tlast(m_tlast[2]),
        .m2_axis_tuser(m_tuser[2]),   .m2_axis_tid(m_tid[2]),

        .m3_axis_tvalid(m_tvalid[3]), .m3_axis_tready(m_tready[3]), .m3_axis_tdata(m_tdata[3]),
        .m3_axis_tkeep(m_tkeep[3]),   .m3_axis_tstrb(m_tstrb[3]),   .m3_axis_tlast(m_tlast[3]),
        .m3_axis_tuser(m_tuser[3]),   .m3_axis_tid(m_tid[3])
    );

    // ==========================================
    // Task to Send Packets
    // ==========================================
    task send_packet(
        input [DATA_WIDTH-1:0] data,
        input [DEST_WIDTH-1:0] dest,
        input [KEEP_WIDTH-1:0] keep = 8'hFF,
        input [STRB_WIDTH-1:0] strb = 8'hFF,
        input                  last = 1'b1,
        input [USER_WIDTH-1:0] user = 4'h0,
        input [ID_WIDTH-1:0]   id   = 2'b00
    );
        packet_t pkt;
        begin
            pkt.tdata = data; pkt.tkeep = keep; pkt.tstrb = strb;
            pkt.tlast = last; pkt.tuser = user; pkt.tid   = id;

            // Save to expected FIFO array
            case (dest)
                2'b00: begin exp_fifo[0][wr_ptr[0]] = pkt; wr_ptr[0] = wr_ptr[0] + 1; end
                2'b01: begin exp_fifo[1][wr_ptr[1]] = pkt; wr_ptr[1] = wr_ptr[1] + 1; end
                2'b10: begin exp_fifo[2][wr_ptr[2]] = pkt; wr_ptr[2] = wr_ptr[2] + 1; end
                2'b11: begin exp_fifo[3][wr_ptr[3]] = pkt; wr_ptr[3] = wr_ptr[3] + 1; end
            endcase

            @(posedge aclk);
            s_axis_tvalid <= 1'b1;
            s_axis_tdata  <= data;
            s_axis_tdest  <= dest;
            s_axis_tkeep  <= keep;
            s_axis_tstrb  <= strb;
            s_axis_tlast  <= last;
            s_axis_tuser  <= user;
            s_axis_tid    <= id;

            do @(posedge aclk); while (!s_axis_tready);

            s_axis_tvalid <= 1'b0;
        end
    endtask

    // ==========================================
    // Self-Checking Logic (Checker Monitors)
    // ==========================================
    genvar k;
    generate
        for (k = 0; k < 4; k = k + 1) begin : gen_checkers
            always @(posedge aclk) begin
                if (aresetn && m_tvalid[k] && m_tready[k]) begin
                    if (rd_ptr[k] >= wr_ptr[k]) begin
                        $display("[ERROR] Unexpected packet received at Destination %0d at time %0t!", k, $time);
                        error_count = error_count + 1;
                    end else begin
                        packet_t exp_pkt;
                        exp_pkt = exp_fifo[k][rd_ptr[k]];
                        rd_ptr[k] = rd_ptr[k] + 1;

                        if (m_tdata[k] === exp_pkt.tdata && 
                            m_tkeep[k] === exp_pkt.tkeep &&
                            m_tstrb[k] === exp_pkt.tstrb &&
                            m_tlast[k] === exp_pkt.tlast &&
                            m_tuser[k] === exp_pkt.tuser &&
                            m_tid[k]   === exp_pkt.tid) begin
                            $display("[SUCCESS] Dest %0d Matched! Data=0x%0h, Time=%0t", k, m_tdata[k], $time);
                            success_count = success_count + 1;
                        end else begin
                            $display("[ERROR] Dest %0d Mismatch! Expected Data=0x%0h, Got Data=0x%0h at Time=%0t", 
                                     k, exp_pkt.tdata, m_tdata[k], $time);
                            error_count = error_count + 1;
                        end
                    end
                end
            end
        end
    endgenerate

    // ==========================================
    // Main Stimulus Sequence
    // ==========================================
    initial begin
        // Setup Waveform Dump
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_axi_stream_router);

        // Initialization
        aclk = 0;
        aresetn = 0;
        s_axis_tvalid = 0;
        s_axis_tdata = 0; s_axis_tkeep = 0; s_axis_tstrb = 0;
        s_axis_tlast = 0; s_axis_tdest = 0; s_axis_tuser = 0; s_axis_tid = 0;
        m_tready[0] = 1; m_tready[1] = 1; m_tready[2] = 1; m_tready[3] = 1;

        wr_ptr[0] = 0; wr_ptr[1] = 0; wr_ptr[2] = 0; wr_ptr[3] = 0;
        rd_ptr[0] = 0; rd_ptr[1] = 0; rd_ptr[2] = 0; rd_ptr[3] = 0;

        // Reset Sequence
        #20;
        aresetn = 1;
        #20;

        $display("\n=== TEST 1: DETERMINISTIC DIRECTED TESTS (BEFORE RANDOMIZATION) ===");
        send_packet(64'hAAAA_BBBB_CCCC_DDDD, 2'b00, 8'hFF, 8'hFF, 1'b1, 4'h1, 2'b00);
        send_packet(64'h1111_2222_3333_4444, 2'b01, 8'hFF, 8'hFF, 1'b1, 4'h2, 2'b01);
        send_packet(64'h5555_6666_7777_8888, 2'b10, 8'hFF, 8'hFF, 1'b1, 4'h3, 2'b10);
        send_packet(64'h9999_8888_7777_6666, 2'b11, 8'hFF, 8'hFF, 1'b1, 4'h4, 2'b11);
        #50;

        $display("\n=== TEST 2: RANDOMIZED PACKETS TEST ===");
        repeat (15) begin
            send_packet(
                {$random, $random},
                $random % 4,
                8'hFF, 8'hFF, 1'b1,
                $random % 16,
                $random % 4
            );
        end

        # 200;

        // Final Report
        $display("\n==============================================");
        $display("              FINAL TEST REPORT               ");
        $display("==============================================");
        $display(" Total Successful Packets Verified: %0d", success_count);
        $display(" Total Error Count                : %0d", error_count);
        
        if (error_count == 0 && success_count > 0) begin
            $display(" RESULT: ALL TESTS PASSED SUCCESSFULLY! (0 ERRORS)");
        end else begin
            $display(" RESULT: TEST FAILED WITH %0d ERROR(S)", error_count);
        end
        $display("==============================================\n");

        $finish;
    end

endmodule