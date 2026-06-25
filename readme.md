# QuantumSynapse-BD 
> **Quantum Molecular Dynamics & Synaptic Simulation for Bipolar Disorder Therapeutics**

`QuantumSynapse-BD` 是一個創新的全端虛擬實驗室平台，旨在透過 **React Three Fiber (R3F)** 的三維微觀視覺化，模擬已知精神科藥物對雙相情緒障礙症（Bipolar Disorder, BD）的神經突觸影響。此外，本系統建構了「經典-量子混合架構（Hybrid Classical-Quantum Architecture）」，允許使用者設計、合成「新穎藥物分子（De Novo Molecules）」，並非同步調度 **IBM Quantum (Qiskit)** 運算資源，深度分析新分子與神經受體（如 G 蛋白偶聯受體 GPCRs）的結合親和力（Binding Affinity）與電子基態能量。

`QuantumSynapse-BD` is an innovative full-stack virtual laboratory platform designed to simulate the synaptic impact of known psychiatric drugs on Bipolar Disorder (BD) via 3D micro-visualizations powered by **React Three Fiber (R3F)**. Furthermore, the system incorporates a Hybrid Classical-Quantum Architecture, allowing users to design and synthesize *de novo* drug molecules, asynchronously dispatching computational workloads to **IBM Quantum (Qiskit)** to deeply analyze molecular binding affinities and ground-state energies with neuroreceptors (e.g., GPCRs).

---

## 核心願景 & UI/UX 哲學 (Core Vision & UI/UX Philosophy)

### 實驗室深度分析進度條 (The Laboratory Deep Analysis Paradigm)
由於量子化學計算（如 VQE 演算法）本質上屬於高延遲、排隊機制重的非同步任務，本專案摒棄了傳統 Web 應用的「即時響應」迷思，轉而採用**擬真科學實驗室（Immersive Lab Progression）**的 UX 核心。
* 當使用者點擊「合成並啟動量子模擬」後，前端 R3F 將切換至「質譜/分子對接沉浸式等待介面」。
* 後端透過 WebSocket 實時推送階段性的經典計算與量子線路排隊進度，將底層高延遲的技術限制，轉化為具備高度儀式感與專業感的「科學實驗深度分析」體驗。

### The Laboratory Deep Analysis Paradigm
Since quantum chemical computations (e.g., VQE algorithms) are inherently high-latency, queue-based asynchronous tasks, this project rejects the traditional web myth of "instantaneous response" in favor of an **Immersive Lab Progression** UX.
* Upon clicking "Synthesize & Initiate Quantum Simulation", the R3F frontend transitions into a mass-spectrometry/molecular-docking immersive waiting state.
* The backend streams real-time queue states and quantum circuit execution steps via WebSockets, transforming underlying hardware latencies into a highly ritualistic and professional "scientific deep-analysis" experience.

---

##  Key Technology Stack

* **Frontend:** Next.js (App Router), React Three Fiber (R3F), Three.js, Tailwind CSS.
* **Core Backend & State Machine:** Go (Echo Framework) / Rust (Actix-web) for ultra-low latency neurochemical token-bucket and synaptic state processing.
* **Quantum & Chemical Engine:** Python, Qiskit Nature, RDKit, OpenMM, Celery, Redis.
* **Infrastructure:** Cloudflare Workers (Edge Caching & Global Routing), PostgreSQL (Persistent Chemical/User Data).

---

## 科學根據與數據來源 (Scientific Grounding & Data Sources)
為了確保模擬系統的嚴謹性，本專案的常數與生化機制奠基於以下權威數據源：
1. **DrugBank Database:** 用於獲取已知雙相情緒障礙症藥物（如 Lithium Carbonate, Valproate, Aripiprazole, Quetiapine）的受體靶點、抑制常數 ($K_i$) 與藥效學參數。
2. **KEGG Pathway Database (hsa04720 / hsa04020):** 參考長期增強作用（Long-term Potentiation）與鈣離子訊號傳導途徑，將突觸後電位與細胞內第二信使（如 GSK-3β、Inositol Trisphosphate）的級聯反應數位化。
3. **ChEMBL & PubChem:** 提供小分子配體（Ligands）的 SMILES 結構式與三維構象幾何參數。
4. **Qiskit Nature Quantities:** 使用 VQE（變分量子特徵求解器）估算分子軌域電子云重疊與靜電勢能。

---

## 參考文獻 (References)
* Post, R. M. (2018). *Neurobiological basis of bipolar disorder: From inside the cell to the topography of the brain.* World Psychiatry, 17(1), 14-15.
* Perdomo-Ortiz, A., et al. (2012). *From open-loop to close-loop quantum simulation of chemical dynamics.* Scientific Reports, 2, 286.
* Bowden, C. L. (2003). *Valproate in the treatment of bipolar disorder.* Expert Review of Neurotherapeutics, 3(4), 433-441.
