# FPGAの内容が薄い本８ 「やりなおしからはじめるFPGA開発」 サンプル

C105で頒布した書籍「FPGAの内容が薄い本８ やりなおしからはじめるFPGA開発」のサンプルソースコードです。

本書籍のPDF版は[Boothにて頒布中](https://aquaxis.booth.pm/items/6386585)です。

ご質問等は[New Issue](https://github.com/aquaxis/c105/issues/new/choose)をください。

ファイルの構成はつぎのようになっています。

## ファイル構成

```
├── 01_adder   // 書籍の「7. はじめてのFPGA開発」
│   ├── build // 論理合成・配置配線ディレクトリ
│   │   └── Makefile // 論理合成・配置配線のMakefile
│   ├── rtl   // adder回路ディレクトリ
│   │   ├── adder.sv // adder回路
│   │   ├── adder.sv_ // adder回路（信号反転）
│   │   ├── adder.xdc // adder制約ファイル
│   │   └── tb_adder.sv // adderテストベンチ
│   ├── script // 各種スクリプトディレクトリ
│   │   ├── bitstream.tcl // Bitファイル生成スクリプト
│   │   ├── bitwrite.tcl // Bitファイル書き込みスクリプト
│   │   ├── flashwrite.tcl // フラッシュメモリ書き込みスクリプト
│   │   ├── list.f // ファイル一覧
│   │   ├── par.tcl // 配置配線スクリプト
│   │   └── synthesis.tcl // 倫理合成スクリプト
│   ├── sim   // シミュレーション
│   │   └── Makefile // シミュレーション用Makefile
│   └── verilator // Verilatorディレクトリ
│       ├── Makefile // Verilator用Makefile
│       └── tb_adder.cpp // adderテストベンチ
├── 02_beacon  // 書籍の「10. ビーコン回路」
│   ├── build // 論理合成・配置配線ディレクトリディレクトリ
│   │   └── Makefile // 論理合成・配置配線スクリプト
│   ├── rtl // beacon回路ディレクトリ
│   │   ├── beacon.sv // ビーコン回路
│   │   ├── beacon.xdc // ビーコン制約ファイル
│   │   └── tb_beacon.sv // ビーコンテストベンチ
│   ├── script // 各種スクリプトディレクトリ
│   │   ├── bitwrite.tcl // Bitファイル書き込みスクリプト
│   │   ├── compile.tcl // 論理合成・配置配線スクリプト
│   │   └── flashwrite.tcl // フラッシュメモリ書き込みスクリプト
│   └── sim // シミュレーションディレクトリ
│       └── Makefile // シミュレーション用Makefile
├── 03_riscv   // 書籍の「11. RISC-V」
│   ├── build // 論理合成・配置配線ディレクトリディレクトリ
│   │   └── Makefile 論理合成・配置配線Makefile
│   ├── rtl // RISC-Vディレクトリ
│   │   ├── gpio.sv // GPIOモジュール
│   │   ├── lct.sv // バスコネクト
│   │   ├── memory.sv // 命令・データメモリ
│   │   ├── riscv.sv // RISC-Vトップ階層
│   │   ├── riscv.xdc // RISC-V制約ファイル
│   │   ├── rv32i.sv // RISC-Vコア
│   │   ├── rv32i_alu.sv // RISC-V ALU
│   │   ├── rv32i_csr.sv // RISC-V CSRレジスタファイル
│   │   ├── rv32i_decode.sv // RISC-V命令デコード
│   │   ├── rv32i_reg.sv // RISC-Vレジスタファイル
│   │   └── tb_riscv.sv // RISC-Vテストベンチ
│   ├── script // 各種スクリプトディレクトリ
│   │   ├── bitwrite.tcl // Bitファイル書き込みスクリプト
│   │   ├── compile.tcl // 論理合成・配置配線スクリプト
│   │   └── flashwrite.tcl // フラッシュメモリ書き込みスクリプト
│   ├── sim // シミュレーション
│   │   └── Makefile // シミュレーション用Makefile
│   └── software // アプリディレクトリ
│       ├── Makefile // アプリのMakefile
│       ├── link.ld // リンカースクリプト
│       ├── main.c // サンプルプログラム
│       └── start.S // スタートアップスクリプト
├── LICENSE // ライセンス
├── Makefile // このリポジトリをクリーンするMakefile
└── README.md // このファイル
```