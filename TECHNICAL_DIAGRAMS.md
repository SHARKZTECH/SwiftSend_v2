# SwiftSend Technical Diagrams

## Figure 1: System Architecture Diagram

```mermaid
flowchart TB
    subgraph "Mobile Apps"
        CA[Customer App<br/>Android/iOS]
        RA[Courier App<br/>Android/iOS]
    end

    subgraph "Web Portals"
        AP[Agent Portal]
        AD[Admin Dashboard]
    end

    subgraph "Cloud Infrastructure"
        API[API Server<br/>REST/HTTPS]
        ML[ML Inference<br/>Service]
        PS[Payment<br/>Service]
    end

    subgraph "Database Layer"
        PG[(PostgreSQL<br/>Cluster)]
        RD[(Redis<br/>Cache)]
    end

    subgraph "External Services"
        MP[M-Pesa API]
        MAP[Google Maps API]
        SMS[SMS Gateway]
        FCM[Firebase FCM]
    end

    CA <-->|HTTPS| API
    RA <-->|HTTPS| API
    AP <-->|HTTPS| API
    AD <-->|HTTPS| API

    API <--> PG
    API <--> RD
    API <--> ML
    API <--> PS

    PS <--> MP
    API <--> MAP
    API <--> SMS
    API <--> FCM
```

---

## Figure 2: Address Resolution Process Flowchart

```mermaid
flowchart TD
    A([Start]) --> B[User inputs informal address]
    B --> C[Text sent to NLP Module]
    C --> D[Tokenization & Entity Recognition]
    D --> E[Query Landmark Database<br/>with Fuzzy Matching]
    E --> F[Parse Directional/Distance Info]
    F --> G[Community Data Lookup<br/>100m radius]
    G --> H{Multiple<br/>Candidates?}

    H -->|Yes| I[ML Ranking Model]
    H -->|No| J[Calculate Confidence Score]
    I --> J

    J --> K{Score > 60%?}
    K -->|Yes| L[Auto-resolve to GPS]
    K -->|No| M[Request Verification Call]
    M --> L

    L --> N[Return Coordinates<br/>with Accuracy Zone]
    N --> O[Show Map Confirmation]
    O --> P{User Adjusts?}

    P -->|Yes| Q[Store Correction<br/>for ML Learning]
    P -->|No| R([End])
    Q --> R
```

---

## Figure 3: Escrow Payment System Flowchart

```mermaid
flowchart TD
    A([Customer Initiates Payment]) --> B[STK Push to Phone]
    B --> C[Customer Enters M-Pesa PIN]
    C --> D[Funds Transfer to<br/>Platform Escrow Account]
    D --> E[Server Receives Confirmation]
    E --> F[Status: ESCROWED]
    F --> G[Trigger Courier Matching]

    G --> H[Courier Assigned]
    H --> I[Courier Completes Delivery]
    I --> J[POD Capture:<br/>Signature + Photo + GPS]
    J --> K[Generate SHA-256 Hash]
    K --> L[Customer Notification Sent]

    L --> M[2-Hour Dispute Window]
    M --> N{Dispute Filed?}

    N -->|Yes| O[Freeze Funds<br/>Start Resolution]
    N -->|No| P[Auto-Release Funds]

    O --> Q{Resolution}
    Q -->|Customer Wins| R[Refund to Customer]
    Q -->|Courier Wins| P

    P --> S[Split Payment]
    S --> T[85% to Courier Wallet]
    S --> U[15% to Platform]
    T --> V[Courier Withdraws<br/>to M-Pesa Anytime]
    V --> W([End])
    R --> W
```

---

## Figure 4: Courier Matching Algorithm Diagram

```mermaid
flowchart TD
    subgraph "Stage 1: Initial Filtering"
        A[New Delivery Order] --> B[Query Online Couriers<br/>within 5km Radius]
        B --> C[Filter by Vehicle Type<br/>vs Package Size]
    end

    subgraph "Stage 2: Scoring Calculation"
        C --> D[Calculate Composite Score]
        D --> E["Score =
        0.30 × Proximity +
        0.20 × Rating +
        0.20 × Vehicle_Match +
        0.15 × Acceptance_Rate +
        0.10 × Current_Load +
        0.05 × Traffic"]
    end

    subgraph "Stage 3: Parallel Dispatch"
        E --> F[Rank by Score<br/>Descending]
        F --> G[Send to Top 3<br/>Simultaneously]
        G --> H[Start 60s Timer]
        H --> I{First Accept?}
        I -->|Yes| J[Assign Courier]
        I -->|Timeout| K[Expand to 10km]
        K --> B
    end

    J --> L([Delivery Begins])
```

---

## Figure 5: Offline Operation Architecture

```mermaid
flowchart TB
    subgraph "Local Storage Layer"
        SQL[(SQLite DB)]
        MAP[(Map Cache<br/>OSM Tiles)]
        POD[(POD Queue)]
    end

    subgraph "Offline Capabilities"
        V[✓ View Assigned Deliveries]
        N[✓ GPS Navigation]
        C[✓ Capture POD]
        M[✓ Mark Complete]
        X[✗ Accept New Jobs]
    end

    subgraph "Sync Mechanism"
        BG[Background Service<br/>30s Connectivity Check]
        BG --> Q{Online?}
        Q -->|Yes| UP[Query PENDING Records]
        UP --> BATCH[Batch Upload POD<br/>with Retry Logic]
        Q -->|No| WAIT[Wait & Retry]
        WAIT --> BG
    end

    subgraph "Fallback"
        SMS[SMS Gateway]
        SMS --> CRIT[Critical Updates<br/>via SMS]
    end

    SQL --> V
    MAP --> N
    V --> C
    C --> POD
    POD --> BATCH
    BATCH --> SMS
```

---

## Figure 6: Community Agent Network Topology

```mermaid
flowchart TB
    subgraph "Agent Registration"
        REG[Local Shops, M-Pesa Agents, Kiosks]
        REG --> DATA[Registered Data:<br/>Name, GPS, Hours, Capacity]
        DATA --> COV[500+ Agents in<br/>Kibera, Mathare, Mukuru]
    end

    subgraph "Package Handoff Flow"
        CR[Courier] -->|Delivers to| AG[Agent Location]
        AG --> SIG[Agent Signature + Photo<br/>as POD]
        SIG --> SMS[SMS to Recipient<br/>with Collection Code]
        SMS --> WAIT[48-Hour Collection Window]
        WAIT --> REC[Recipient Shows Code]
        REC --> REL[Agent Releases Package]
        REL --> PAY[Agent Earns KES 30<br/>Paid Weekly via M-Pesa]
    end

    subgraph "Geographic Coverage"
        direction LR
        K[Kibera<br/>150 agents]
        MT[Mathare<br/>120 agents]
        MK[Mukuru<br/>100 agents]
        O[Other Areas<br/>130+ agents]
    end
```

---

## Drawing Standards Applied

| Requirement                | Implementation                                                |
| -------------------------- | ------------------------------------------------------------- |
| Numbered figures           | Fig. 1 through Fig. 6                                         |
| Standard flowchart symbols | Rectangles (process), Diamonds (decisions), Ovals (start/end) |
| Clear directional arrows   | Mermaid auto-generates arrow directions                       |
| Legible text               | Markdown rendering ensures clarity                            |
| Separate sheets            | Each figure in its own section                                |
