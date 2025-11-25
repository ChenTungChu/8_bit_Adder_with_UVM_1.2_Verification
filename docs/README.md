🧩 一、整體架構概覽

你的專案是一個典型的 UVM Testbench Hierarchy：

uvm_test_top
└── env (adder_env)
    └── agent (adder_agent)
        ├── sequencer (adder_sequencer)
        ├── driver (adder_driver)
        └── monitor (adder_monitor)
└── scoreboard (adder_scoreboard)
└── reference model (adder_ref_model)


所有這些元件由 adder_test（繼承自 uvm_test）啟動並管理。
整個模擬會經歷一系列固定的 UVM Phase。

🚀 二、UVM Simulation Phases 對照說明
1️⃣ Build Phase（建構階段）

日誌：

@      0: [BASE_TEST] Build phase started.
@      0: [ADDER_TEST] Build phase started.
@      0: [ENV] Build phase started.
@      0: [ENV] All components successfully created
@      0: [AGENT] Build phase started.
@      0: [SEQUENCER] Created uvm_test_top.env.agent.seqr

✳️ 做了什麼：

UVM 自動呼叫每個 component 的 build_phase()。

各層在這階段 創建（create）子組件。

通常使用：

driver = adder_driver::type_id::create("driver", this);


env 建立 agent、scoreboard、ref_model。

agent 再建立 driver、monitor、sequencer。

🧠 重點理解：
UVM 採用 factory pattern，建構階段是用來決定哪些元件會被實例化、以何種型態建立。

2️⃣ Connect Phase（連接階段）

日誌：

@      0: [AGENT] Connect phase started.
@      0: [ENV] Connect phase started.

✳️ 做了什麼：

主要用來連接各元件之間的 TLM port/export：

driver.seq_item_port.connect(sequencer.seq_item_export);
monitor.ap.connect(scoreboard.analysis_export);
ref_model.ap.connect(scoreboard.ref_export);


🧠 重點理解：

這一步讓資料可以「流動」起來。
例如：

sequencer 把 sequence item 傳給 driver

monitor 把 DUT 輸出送給 scoreboard

ref_model 把期望值送給 scoreboard

還沒有任何模擬時間進行（都是 @0 時間點）。

3️⃣ End of Elaboration
@      0: [Questa UVM] End Of Elaboration


這是建構和連接都完成後的一個 checkpoint，代表 testbench hierarchy 都準備好了。
此時可用 uvm_top.print_topology() 來檢查整體層級。

4️⃣ Run Phase（模擬執行階段）
@      0: [ADDER_TEST] Run phase started.
@      0: [ADDER_TEST] Starting adder_seq on env.agent.seqr

✳️ 做了什麼：

這是 唯一有時間流動的階段。
各個元件在 run_phase() 中各自執行：

元件	工作內容
sequencer	提供 transaction 給 driver
driver	依序發出 stimulus 給 DUT，控制 valid/ready 等握手
monitor	監看 DUT 介面信號並產生實際輸出 transaction
ref_model	計算理論上的正確結果
scoreboard	收到 DUT 實際結果與 REF 結果，進行比對
⚙️ 三、你的模擬輸出解讀

以下逐段解釋你的 log：

▶ 1. Reset 階段
@   5001: [MONITOR] RESET asserted.
@  15000: [DRIVER] Reset deasserted.


Monitor 偵測 reset 啟動，driver 之後解除 reset。
這代表你的 testbench 在 run phase 初期，先等待 DUT ready。

▶ 2. 第一筆 transaction
@  25000: [SEQ] Generated: a = 241, b = 11
@  65001: [MONITOR]  Handshake captured: a = 241, b = 11, sum = 252
@  65001: [REF_MODEL] REF_MODEL: a = 241, b = 11, sum = 252
@  65001: [SCOREBOARD] REF pushed: ...
@  65001: [SCOREBOARD] DUT got: ...
@  65001: [SCOREBOARD] Match OK: ...


流程如下：

Sequencer 產生 input transaction（a=241, b=11）。

Driver 將該資料送入 DUT。

Monitor 偵測握手完成，捕捉實際輸出 sum=252。

Ref model 同時計算理論 sum（也=252）。

Scoreboard 收到雙方資料 → 比對 → 結果 Match。

這是一個完整的 data flow。

▶ 3. 後續 transaction

每一筆都重複上述流程：

#2: a=91, b=92 → sum=183
#3: a=145, b=105 → sum=250
#4: a=16, b=138 → sum=154
#5: a=254, b=0 → sum=254


每次都成功 match，表示你的整個 testbench pipeline（driver→DUT→monitor→scoreboard）都正確。

▶ 4. 結尾
@ 315000: [ADDER_TEST] Run phase completed.
@ 315000: [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase


代表模擬順利結束。
之後 UVM 還會進入（可選的）：

extract_phase（收集統計）

check_phase（檢查錯誤）

report_phase（印最終報告）

🧠 四、整體運作流程圖
               ┌────────────────────────┐
               │        adder_seq       │
               └────────────┬───────────┘
                            │ (sequence item)
                            ▼
               ┌────────────────────────┐
               │      adder_sequencer   │
               └────────────┬───────────┘
                            │
                            ▼
               ┌────────────────────────┐
               │       adder_driver     │──► 驅動 DUT 接口信號
               └────────────┬───────────┘
                            │
         DUT input/output   ▼
                            ▼
               ┌────────────────────────┐
               │      adder_monitor     │──► 傳送到 scoreboard
               └────────────┬───────────┘
                            │
                            ▼
               ┌────────────────────────┐
               │     adder_scoreboard   │◄── ref_model
               └────────────────────────┘

🧾 五、你這個專案展示的關鍵 UVM 概念
概念	你範例中如何體現
Factory 建構	使用 type_id::create() 在 build phase 建立所有元件
TLM 通訊	monitor, ref_model 使用 analysis_port 對 scoreboard 傳資料
Phase 控制	依序經過 build → connect → run → report
自動驗證	scoreboard 自動比對 DUT vs REF 結果
資料流整合	sequencer → driver → DUT → monitor → scoreboard 完整形成