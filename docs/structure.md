# Project Structure 
> **QuantumSynapse-BD Monorepo Directory Tree and Architecture**

本專案採用 **Monorepo** 架構進行管理，以確保前端視覺化、高性能神經模擬後端、以及 Python 量子計算微服務之間的高效協作與動態鏈接。

This project utilizes a **Monorepo** architecture to ensure seamless collaboration and type-safe data pipelines between the 3D frontend, the high-performance core backend, and the Python-based quantum microservice.

---

## 目錄樹 (Directory Tree)

程式碼輸出內容
Files generated successfully.

```text
quantumsynapse-bd/
├── README.md                          # 專案主說明文件 (Bilingual General Overview)
├── STRUCTURE.md                       # 系統架構與代碼目錄說明 (This File)
├── IMPLEMENTATION_PLAN.md             # 四階段實施藍圖與里程碑 (Phased Roadmap)
│
├── apps/
│   └── web/                           # 前端 Next.js 應用程式
│       ├── public/                    # 靜態資源 (3D GLTF/GLB 突觸模型、貼圖)
│       └── src/
│           ├── components/
│           │   ├── lab/               # 實驗室控制面板、進度條元件
│           │   └── r3f/               # React Three Fiber 3D 渲染核心
│           │       ├── SynapseScene.tsx  # 突觸間隙主場景
│           │       ├── Receptor.tsx      # 神經受體動態網格
│           │       └── Neurotransmitter.tsx # 粒子系統控制
│           ├── hooks/                 # 自定義 React Hooks (如 useQuantumJob)
│           ├── app/                   # Next.js App Router 頁面配置
│           └── lib/                   # WebSocket 與 API 客戶端
│
├── services/
│   ├── core-engine/                   # 核心神經/藥理動力學模擬引擎 (Go/Rust)
│   │   ├── Cargo.toml / main.go       
│   │   ├── src/
│   │   │   ├── models/                # 生化系統狀態機模型 (Neuro-state Machine)
│   │   │   ├── pharmacodynamics/      # 經典藥效學 (Hill Equation, Binding Kinetics)
│   │   │   └── websocket/             # 實時資料串流伺服器
│   │   └── Dockerfile
│   │
│   └── quantum-worker/                # IBM Quantum / Qiskit 微服務 (Python)
│       ├── requirements.txt
│       ├── celery_app.py              # 非同步工作任務隊列 (Task Queue)
│       ├── quantum_circuits/          # Qiskit 量子線路建構模組
│       │   ├── vqe_solver.py          # 變分量子特徵求解器 (VQE) 核心
│       │   └── molecule_builder.py    # SMILES 轉量子哈密頓量 (Hamiltonian)
│       └── docker-compose.yml
│
└── config/                            # 全域配置與環境變量模板
    ├── postgres/                      # 資料庫初始化腳本
    └── cloudflare/                    # wrangler.toml (Edge 路由配置)


關鍵子系統資料流架構 (Data Flow Architecture)1. 經典藥物模擬流 (Classical Simulation Flow - Known Drugs)使用者在 apps/web 選擇「Lithium 鋰鹽」。前端向 services/core-engine 發起請求。core-engine（基於 Rust/Go）直接提取 DrugBank 緩存數據，執行經典藥效學常微分方程（ODE），計算突觸間隙多巴胺/血清素濃度的動態調控。計算結果通過 WebSocket 每秒 60 幀同步至 R3F 粒子系統進行微觀渲染。2. 新藥合成量子計算流 (Quantum De Novo Synthesis Flow)使用者在前端畫布微調分子結構或化學特性參數。前端向 core-engine 提交合成請求，後端立即生成獨一無二的 job_id 並寫入 PostgreSQL。core-engine 將此高密度任務推入 Redis/Celery 隊列。services/quantum-worker（Python/Qiskit）自隊列中拉取任務，建構分子的費米子算符（Fermionic Operators），並調用 IBM Quantum Run 原生雲端硬碟。UX 轉折點： 在此排隊與計算期間（預計數十秒至數分鐘），前端監聽 WebSocket 狀態更新為 STATUS_QUANTUM_QUEUE_WAITING $\rightarrow$ STATUS_VQE_COMPUTING。UI 觸發精美的「實驗室深度分析進度條」，伴隨質譜線路 3D 粒子流。量子計算完畢，回傳分子結合能；core-engine 接手將其映射至突觸網絡，WebSocket 通知前端完成分析，3D 突觸動態呈現新藥結合。"""
