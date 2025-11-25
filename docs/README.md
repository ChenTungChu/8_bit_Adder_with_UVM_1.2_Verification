# 8-bit Adder with UVM 1.2 Verification

## Introduction


- This project implements an 8-bit adder module that follows a valid/ready handshake protocol. It contains a complete UVM (Universal Verification Methodology) 1.2 verification environment.
- The DUT (Design Under Test), implemented a simple 8-bit adder, contains four states, with handshake signals to verify functional correctness, timing behavior, and protocol compliance.
- The UVM verification environment includes all major UVM components (driver, monitor, scoreboard… etc.), forming a fully closed-loop verification flow.
- The main goal of the project is to get familiar with the implementation and verification using UVM.

## DUT



- **Functionality**
    - Handshake-based adder is simulated so that state transitions determine when it receives input and when it outputs data
- **Main signals**
    - `in_valid`, `in_ready` : Handshake at input stage
    - `out_valid`, `out_ready` : Handshake at output stage
    - `sum` : Result sum
- **FSM**
    
    
    | State | Action | Next State |
    | --- | --- | --- |
    | IDLE | Wait for `in_valid` | CALC |
    | CALC | Add calculation | WAIT |
    | WAIT | Wait for `out_ready` | DONE |
    | DONE | Clear sum and back to IDLE | IDLE |

## UVM Environment Overview



- **UVM architecture diagram**
    
    ![alt text](https://github.com/ChenTungChu/8_bit_Adder_with_UVM_1.2_Verification/blob/main/docs/uvm_diagram.png)
    
    - This project basically follows this structure.
    
     
    
- **Overall hierarchy**
    
    ```
    uvm_test_top
     └── env (adder_env)
          ├── agent (adder_agent)
          │    ├── driver (adder_driver)
          │    ├── monitor (adder_monitor)
          │    └── sequencer (adder_sequencer)
          ├── scoreboard (adder_scoreboard)
          └── ref_model (adder_ref_model)
    ```
    

## UVM Execution Flow



### 1. Build phase

- Create all uvm_components instances
- Set up virtual interface
- Example log:
    
    ```
    @ 0: [ENV] All components successfully created
    ```
    

### 2. Connect phase

- Connect `seq_item_port` with `seq_item_export` and `analysis_port`
    - Driver ↔ Sequencer
    - Monitor → Scoreboard
    - Reference Model → Scoreboard

### 3. Run phase

**(1)  `adder_driver`**

- Receive transaction from `sequence`
- Wait for  `in_ready` , and then send out `in_valid`, `a` , and `b`
- After handshake, disable `in_valid`
- Finish one transaction and inform sequencer
- Example driver log
    
    ```
    @  15000: [DRIVER] Reset deasserted.
    @  75000: [DRIVER] Driver done: a = 241, b = 11, sum = 0
    ```
    

 **(2) `adder_monitor`**

- Monitor handshake signals
- Capture data when `out_valid && out_ready`
- Write the result (sum) to analysis port through `adder_seq_item`
- Example monitor log
    
    ```
    @  65001: [MONITOR] Handshake captured: a = 241, b = 11, sum = 252
    ```
    

**(3) `adder_ref_model`**

- Software model that calculates the expected result
    - This project uses simple model written in SystemVerilog
- Send the expected result to scoreboard
- Example reference model log
    
    ```
    @  65001: [REF_MODEL] REF_MODEL: a = 241, b = 11, sum = 252
    ```
    

**(4) `adder_scoreboard`**

- Collect DUT and REF_MODEL outputs
- Compare if the outputs match
    - If match: Record total matches
    - If not match: Report error
- Example scoreboard log with successful match
    
    ```
    @  65001: [SCOREBOARD] Match OK: a = 241, b = 11, sum = 252; Total matches = 1
    ```
    

**(5) `adder_seq`**

- Generate random input vectors
- Send multiple transactions to driver
- Example sequence log
    
    ```
    @  25000: [SEQ] Generated: a = 241, b = 11
    ```
    

## Verification Results

- Repeat five iterations, all passed without error, DUT results match with reference model perfectly
- Outputs of one successful verification
    
    ```
    @ 65001: [MONITOR] Handshake captured: a = 241, b = 11, sum = 252
    @ 65001: [REF_MODEL] REF_MODEL: a = 241, b = 11, sum = 252
    @ 65001: [SCOREBOARD] Match OK: a = 241, b = 11, sum = 252; Total matches = 1
    ```
    
- Complete results are in the result folder

## Conclusion

- This project fully demonstrated:
    - Layered and structured verification using UVM.
    - Robust handshake protocol and synchronous logic.
    - Interaction among the Driver, Monitor, and Scoreboard.
    - A reusable and scalable verification environment architecture.
- Verification results show that all the transaction match successfully, indicating that the verification environment is correctly designed and stable.


## Future Work

- Implement reference model with other languages (such as Python/C++)
    - Most industrial refence model uses languages other than SystemVerilog for the algorithms for reusability, cross-platform, and connection to software team
    - Use DPI-C or UVM FLI to connect to UVM environment
- Add coverage and closure report
    - Currently have the monitor and sequence, but missing the coverage component
    - Should add cover group for input:
        - `a` : 0 - 255
        - `b` : 0 - 255
        - Corner cases: `0x00`, `0xFF`, and overflow conditions
    - Aim to achieve **100% coverage closure**