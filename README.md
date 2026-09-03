# NOC_STREAM_ROUTER-
 Excited to share my latest RTL verification milestone: AXI4-Stream Router Subsystem Verification!

I designed and verified a parameterized AXI4-Stream Router using SystemVerilog and QuestaSim. The system routes stream packets dynamically based on tdest routing signals across multiple master interfaces while preserving full AXI-Stream interface compliance.
*******************************
Flow OF Module : 
. Slave Module 
. FIFO Module 
. Master Module 
. AIX_Stream_Module 
. Top_level_Module 
. Test Bench

********************************
link Drive For Download all Slid and RTL code : 
https://drive.google.com/drive/folders/1u39sNQmkFIEsOYnkxb65Dwu3p9wcauxn
********************************

Key Verification Highlights:
🔹 Self-Checking Scoreboard: Developed an automated scoreboard to verify data integrity, timing, and packet ordering dynamically.
🔹 Randomized & Directed Testing: Simulated deterministic test cases alongside dynamic randomized packet generation to ensure robustness under heavy traffic.
🔹 AXI-Stream Interface Handling: Verified full control signal handshaking (TVALID, TREADY, TLAST, TKEEP, TSTRB, TUSER, TID).
🔹 Clean Simulation: Achieved 100% Pass Rate (0 Errors) with accurate demuxing and zero data corruption.

Building scalable and modular digital designs continues to be a thrilling journey! Check out the successful waveform run below
<img width="1600" height="1140" alt="image" src="https://github.com/user-attachments/assets/abb20dee-57e6-4492-8916-8171196f89f7" />
<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/c9cd28f0-0c59-48ce-8070-3ca9be01f912" />
<img width="1600" height="1130" alt="image" src="https://github.com/user-attachments/assets/cbad2a44-f394-4acf-afcc-e6f41232766e" />
