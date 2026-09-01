# 🎨 DesignSystemMake v1.0.0

[![macOS 14+](https://img.shields.io/badge/macOS-14.0%2B-blue.svg)](https://developer.apple.com/macos/)
[![Swift 5.10 / 6.0](https://img.shields.io/badge/Swift-5.10%20%7C%206.0-orange.svg)](https://swift.org)
[![Homebrew](https://img.shields.io/badge/Homebrew-Formula-green.svg)](Formula/designsystemmake.rb)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Figma API](https://img.shields.io/badge/Figma-Variables%20API-purple.svg)](https://www.figma.com/developers/api)

🌐 **Select Language**: [English](#-english) | [한국어](#-한국어) | [日本語](#-日本語) | [中文 (简体)](#-中文-简体)

---

## 🇺🇸 English

> **Production-grade macOS Native Design System Token Studio & Multi-Platform Exporter.**  
> Built with SwiftUI 5, AppKit, W3C DTCG Standards, and Apple Human Interface Guidelines (HIG).

### 🍺 Homebrew Installation
```bash
brew install mrKangHo/DesignSystemMake/designsystemmake
designsystemmake
```

### 🌟 Key Features
* **🎨 W3C DTCG Token Studio**: Color (Light/Dark dynamic modes), Typography (Font Family, Size, Weight, Line Height), Spacing, Border Radius, and Box Shadows.
* **🍏 Industry Presets**: Apple HIG, Tailwind CSS & Radix UI, Google Material Design 3, Ant Design (B2B).
* **⚡ Multi-Platform Code Exporter**:
  * **📱 SwiftUI & UIKit (iOS)**: Dynamic `UIColor` & `Color` extensions + standalone UIKit.
  * **💻 SwiftUI & AppKit (macOS)**: Dynamic `NSColor` & `Color` extensions + standalone AppKit.
  * **💨 Tailwind CSS**: Complete `tailwind.config.js` theme extensions.
  * **🎨 CSS Variables**: `:root` and `[data-theme="dark"]` CSS variables.
  * **🤖 Jetpack Compose (Android)** & **📱 Flutter (Dart)** tokens.
* **⚡ 1-Click Direct Figma REST API Auto-Sync**: Push tokens directly into Figma file variables in **0.5 seconds** via `POST /v1/files/{file_key}/variables`.
* **🤖 AI Agent System Context Exporter (`.md`)**: Generates structured `DESIGN_SYSTEM.md` context files for **Claude Code, Antigravity CLI, OpenAI Codex, and Cursor**.
* **🌐 4-Language i18n**: Korean 🇰🇷, English 🇺🇸, Japanese 🇯🇵, Chinese 🇨🇳.

---

## 🇰🇷 한국어

> **운영 단계급 macOS 네이티브 디자인 시스템 토큰 스튜디오 & 멀티 플랫폼 코드 내보내기.**  
> SwiftUI 5, AppKit, W3C DTCG 표준 규격 및 Apple Human Interface Guidelines (HIG) 기반 개발.

### 🍺 Homebrew 설치 방법
```bash
# Homebrew 탭 추가 및 설치
brew install mrKangHo/DesignSystemMake/designsystemmake

# 실행
designsystemmake
```

### 🌟 주요 기능
* **🎨 W3C DTCG 토큰 스튜디오**: 색상(Light/Dark 동적 다크모드), 타이포그래피(폰트 패밀리, 크기, 두께, 행간), 스페이싱, 라운딩(Border Radius), 그림자(Box Shadows).
* **🍏 글로벌 표준 프리셋 제공**: Apple HIG, Tailwind CSS & Radix UI, Google Material Design 3, Ant Design (B2B).
* **⚡ 완전 무누락 멀티 플랫폼 코드 생성기**:
  * **📱 SwiftUI & UIKit (iOS)**: Dynamic `UIColor` & `Color` 익스텐션 + Pure UIKit 전용 출력.
  * **💻 SwiftUI & AppKit (macOS)**: Dynamic `NSColor` & `Color` 익스텐션 + Pure AppKit 전용 출력.
  * **💨 Tailwind CSS**: `tailwind.config.js` 완전 테마 확장.
  * **🎨 CSS Variables**: `:root` 및 `[data-theme="dark"]` 변수.
  * **🤖 Jetpack Compose (Android)** 및 **📱 Flutter (Dart)** 지원.
* **⚡ 1-Click 피그마 REST API 실시간 직접 동기화**: Personal Access Token (PAT) 및 파일 URL 입력으로 **Figma 변수 컬렉션을 0.5초 만에 직접 주입**.
* **🤖 AI 코딩 에이전트 전용 프롬프트 문서 내보내기 (`.md`)**: **Claude Code, Antigravity CLI, OpenAI Codex, Cursor**에서 참조할 `DESIGN_SYSTEM.md` 자동 생성.
* **🌐 4개국어 지원**: 한국어 🇰🇷, English 🇺🇸, 日本語 🇯🇵, 中文 🇨🇳.

---

## 🇯🇵 日本語

> **プロダクション対応の macOS ナチュラ・デザインシステム・トークン・スタジオ＆マルチプラットフォーム・コードエクスポート。**  
> SwiftUI 5、AppKit、W3C DTCG 標準規格、および Apple Human Interface Guidelines（HIG）に準拠。

### 🍺 Homebrew インストール
```bash
# Homebrew でインストール
brew install mrKangHo/DesignSystemMake/designsystemmake

# 実行
designsystemmake
```

### 🌟 主な機能
* **🎨 W3C DTCG トークン・スタジオ**: カラー（Light/Dark 動的ダークモード）、タイポグラフィ、スペーシング、角丸（Radius）、シャドウ（Box Shadows）。
* **🍏 標準プリセット**: Apple HIG、Tailwind CSS & Radix UI、Google Material Design 3、Ant Design。
* **⚡ 完全マルチプラットフォーム・エクスポート**:
  * **📱 SwiftUI & UIKit (iOS)**: 動的 `UIColor` / `Color` 拡張機能。
  * **💻 SwiftUI & AppKit (macOS)**: 動的 `NSColor` / `Color` 拡張機能。
  * **💨 Tailwind CSS** & **🎨 CSS Variables**。
  * **🤖 Jetpack Compose (Android)** & **📱 Flutter (Dart)**。
* **⚡ 1-Click Figma REST API 自動同期**: Figma REST API を使用して、**0.5 秒で Figma 変数を直接同期**。
* **🤖 AI エージェント用ドキュメント出力 (`.md`)**: **Claude Code, Antigravity CLI, OpenAI Codex, Cursor** 用の `DESIGN_SYSTEM.md` を生成。

---

## 🇨🇳 中文 (简体)

> **生产级 macOS 原生设计系统 Token 工作台与多平台代码导出工具。**  
> 基于 SwiftUI 5、AppKit、W3C DTCG 规范与 Apple HIG 设计语言构建。

### 🍺 Homebrew 安装指南
```bash
# 通过 Homebrew 安装
brew install mrKangHo/DesignSystemMake/designsystemmake

# 启动程序
designsystemmake
```

### 🌟 核心特性
* **🎨 W3C DTCG 设计变量 Studio**: 颜色（亮色/暗色动态模式）、排版字体（字族、字号、字重、行高）、间距、圆角（Radius）与阴影（Box Shadow）。
* **🍏 内置标准预设**: Apple HIG、Tailwind CSS & Radix UI、Google Material Design 3、Ant Design (B2B)。
* **⚡ 零缺失多平台代码导出**:
  * **📱 SwiftUI & UIKit (iOS)**: 动态 `UIColor` 与 `Color` 扩展。
  * **💻 SwiftUI & AppKit (macOS)**: 动态 `NSColor` 与 `Color` 扩展。
  * **💨 Tailwind CSS** 与 **🎨 CSS Variables**。
  * **🤖 Jetpack Compose (Android)** 与 **📱 Flutter (Dart)**。
* **⚡ 一键 Figma REST API 实时同步**: 通过 API 将 Token 变量在 **0.5 秒内直接注入 Figma 文件**。
* **🤖 AI 编程 Agent 系统提示词文档导出 (`.md`)**: 为 **Claude Code、Antigravity CLI、OpenAI Codex、Cursor** 自动生成标准 `DESIGN_SYSTEM.md` 上下文。

---

## 📄 License
Distributed under the **MIT License**. See `LICENSE` for details.
