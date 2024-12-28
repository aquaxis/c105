# FPGAの内容が薄い本８ 「やりなおしからはじめるFPGA開発」 サンプル

C105で頒布した書籍「FPGAの内容が薄い本８ やりなおしからはじめるFPGA開発」のサンプルソースコードです。

本書籍のPDF版は[Boothにて頒布中](https://aquaxis.booth.pm/items/6386585)です。

ご質問等は[New Issue](https://github.com/aquaxis/c105/issues/new/choose)をください。

ファイルの構成はつぎのようになっています。

```
├── 01_adder   // 書籍の「7. はじめてのFPGA開発」
│   ├── build // 論理合成・配置配線ディレクトリ
│   │   └── Makefile
│   ├── rtl   // adder回路
│   │   ├── adder.sv
│   │   ├── adder.sv_
│   │   ├── adder.xdc
│   │   └── tb_adder.sv
│   ├── script // 各種スクリプト
│   │   ├── bitstream.tcl
│   │   ├── bitwrite.tcl
│   │   ├── flashwrite.tcl
│   │   ├── list.f
│   │   ├── par.tcl
│   │   └── synthesis.tcl
│   ├── sim   // シミュレーション
│   │   └── Makefile
│   └── verilator // Verilator
│       ├── Makefile
│       └── tb_adder.cpp
├── 02_beacon  // 書籍の「10. ビーコン回路」
│   ├── build // 論理合成・配置配線ディレクトリ
│   │   └── Makefile
│   ├── rtl // beacon回路
│   │   ├── beacon.sv
│   │   ├── beacon.xdc
│   │   └── tb_beacon.sv
│   ├── script // 各種スクリプト
│   │   ├── bitwrite.tcl
│   │   ├── compile.tcl
│   │   └── flashwrite.tcl
│   └── sim // シミュレーション
│       └── Makefile
├── 03_riscv   // 書籍の「11. RISC-V」
│   ├── build // 論理合成・配置配線ディレクトリ
│   │   └── Makefile
│   ├── rtl // RISC-V
│   │   ├── gpio.sv
│   │   ├── lct.sv
│   │   ├── memory.sv
│   │   ├── riscv.sv
│   │   ├── riscv.xdc
│   │   ├── rv32i.sv
│   │   ├── rv32i_alu.sv
│   │   ├── rv32i_csr.sv
│   │   ├── rv32i_decode.sv
│   │   ├── rv32i_reg.sv
│   │   └── tb_riscv.sv
│   ├── script // 各種スクリプト
│   │   ├── bitwrite.tcl
│   │   ├── compile.tcl
│   │   └── flashwrite.tcl
│   ├── sim // シミュレーション
│   │   └── Makefile
│   └── software // アプリケーション
│       ├── Makefile
│       ├── link.ld
│       ├── main.c
│       └── start.S
├── LICENSE
├── Makefile
└── README.md
```