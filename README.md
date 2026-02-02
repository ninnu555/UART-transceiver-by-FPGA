# UART-transceiver-by-FPGA

A hardware implementation of a UART (Universal Asynchronous Receiver-Transmitter) system. This project consists of independent RX and TX modules designed in VHDL to facilitate asynchronous serial communication between a Gowin FPGA and a PC terminal.

## Functional Overview

The system enables the exchange of 8-bit data (ASCII characters in this case). Received data is mapped directly to the FPGA's onboard LEDs, providing a real-time binary representation of the incoming byte.

### Module Breakdown

* **Rx_UART**: A state-machine-based receiver that detects the start bit, samples incoming serial data at a rate of 9600 baud, and stores it in a shift register. It validates the transmission with a stop bit check before updating the output.
* **Tx_UART**: A state-machine-based transmitter that loads an 8-bit byte into a shift register, adds start/stop bits, and outputs the data serially.
* **UART (Top Level)**: Interconnects the RX and TX modules. It is configured to echo received data back to the transmitter, allowing loopback verification.

## Hardware Specifications

* **Target Device**: Gowin GW1NR-9 (GW1NR-LV9QN88PC6/I5).
* **Clock Management**: Internal counter-based baud rate generation (`2813` cycles) for 9600 bps operation.
* **I/O Logic**:
* **Logic Standard**: LVCMOS18.
* **Inputs**: System Clock, Reset (Active Low), UART RX, and a Transmit Button.
* **Outputs**: UART TX, 8-bit Data LEDs, and status flags (`rx_new`, `tx_ready`).



## Pin Mapping

Configurations as defined in the Physical Constraints file (`.cst`):

| Port | Pin | Description |
| --- | --- | --- |
| `ck` | 52 | System Clock Input |
| `reset` | 4 | Global Reset (Active Low) |
| `rx_in` | 18 | Serial Data Input |
| `tx_out` | 17 | Serial Data Output |
| `rx_data[0-7]` | 25-34 | Onboard LEDs (Binary Data) |
| `btn_in` | 3 | Manual Transmit Trigger |
| `rx_new` | 35 | Data Received Pulse |
| `tx_ready` | 40 | Transmitter Ready Signal |

## System Parameters

* **Baud Rate**: 9600 bps.
* **Data Bits**: 8 bits.
* **Stop Bits**: 1 bit.
* **Parity**: None.
* **Flow Control**: None (Manual trigger via `btn_in`).

## Project Structure

* `Rx_UART.vhd`: Receiver logic and FSM.
* `Tx_UART.vhd`: Transmitter logic and FSM.
* `UART.vhd`: Top-level structural architecture.
* `Physical_Constraints.cst`: Gowin-specific pin and IO assignments.
