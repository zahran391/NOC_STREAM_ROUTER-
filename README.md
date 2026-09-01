# NOC_STREAM_ROUTER-
 Excited to share my latest RTL verification milestone: AXI4-Stream Router Subsystem Verification!

I designed and verified a parameterized AXI4-Stream Router using SystemVerilog and QuestaSim. The system routes stream packets dynamically based on tdest routing signals across multiple master interfaces while preserving full AXI-Stream interface compliance.

Key Verification Highlights:
🔹 Self-Checking Scoreboard: Developed an automated scoreboard to verify data integrity, timing, and packet ordering dynamically.
🔹 Randomized & Directed Testing: Simulated deterministic test cases alongside dynamic randomized packet generation to ensure robustness under heavy traffic.
🔹 AXI-Stream Interface Handling: Verified full control signal handshaking (TVALID, TREADY, TLAST, TKEEP, TSTRB, TUSER, TID).
🔹 Clean Simulation: Achieved 100% Pass Rate (0 Errors) with accurate demuxing and zero data corruption.

Building scalable and modular digital designs continues to be a thrilling journey! Check out the successful waveform run below
<img width="1600" height="1140" alt="image" src="https://github.com/user-attachments/assets/abb20dee-57e6-4492-8916-8171196f89f7" />
