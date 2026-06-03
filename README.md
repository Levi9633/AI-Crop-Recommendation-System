# 🌱 AgriMind: Hybrid Crop Recommendation Engine

[![Python](https://img.shields.io/badge/python-3.9+-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)
[![Scikit-Learn](https://img.shields.io/badge/scikit--learn-%23F7931E.svg?style=for-the-badge&logo=scikit-learn&logoColor=white)](https://scikit-learn.org/)
[![Pandas](https://img.shields.io/badge/pandas-%23150458.svg?style=for-the-badge&logo=pandas&logoColor=white)](https://pandas.pydata.org/)
[![Google Gemini](https://img.shields.io/badge/Google%20Gemini-8E75C2?style=for-the-badge&logo=googlegemini&logoColor=white)](https://ai.google.dev/)
[![Uvicorn](https://img.shields.io/badge/uvicorn-222222?style=for-the-badge&logo=python&logoColor=white)](https://www.uvicorn.org/)

AgriMind is an enterprise-grade, high-fidelity hybrid crop recommendation engine that blends predictive machine learning pipelines with historical regional dataset frequencies to deliver hyper-localized agricultural intelligence. By dynamically query-matching regional soil chemistry profiles (Nitrogen, Phosphorus, Potassium, and pH levels) and integrating with Google Gemini AI (`gemini-2.5-flash`), AgriMind generates high-fidelity financial projections, duration matrices, and strategic agronomic recommendations. Built entirely on FastAPI, the engine provides microsecond response times for core ML calls alongside intelligent cascading fallbacks for partial parameter queries.

---

## 🖥️ User Interface & Experience

| Component | UI Design Styling | Functional Highlight |
| :--- | :--- | :--- |
| **Swagger API Explorer** | Sleek, dark-mode adaptive Swagger UI layout with interactive parameters. | Real-time endpoint testing (`/docs`) with pre-populated schema parameters for states and districts. |
| **Diagnostics Console** | Minimalist JSON system health check telemetry dashboard. | Live initialization status for Scikit-Learn pipelines, Multi-Label Binarizer models, and Pandas datasets. |
| **Structured JSON Response** | Clean, serialized JSON schema optimized for frontend rendering. | Seamless integration with dynamic visual charts, budget maps, and agricultural scheduling tools. |

---

## ⚙️ Technical Pillars & Key Features

| Technical Pillar | Technology | Functional Specification |
| :--- | :--- | :--- |
| **Hybrid Inference Pipeline** | `scikit-learn` Classifier + `pandas` Historical Stats | Computes combined probability rankings using: $$Score = 0.65 \cdot P_{ML} + 0.35 \cdot P_{Freq}$$, filtering crops below a 5% confidence threshold. |
| **Local Soil Telemetry** | SQLite/CSV District Soil Mapping Database | Offline, case-insensitive cross-referencing of Nitrogen (N), Phosphorus (P), Potassium (K), and pH levels based on a curated Indian district dataset. |
| **Hierarchical Fallback Engine** | Dynamic Query Matching Algorithms | Cascading database queries that relax parameters step-by-step from full spec (State+District+Year+Season) down to global datasets when matching entries are sparse. |
| **Strategic Economic LLM** | `Google Gemini API` (`gemini-2.5-flash`) | Contextual prompt injection wrapping regional stats and ML predictions into a structured JSON schema, yielding INR-denominated seed, labor, and profit margins. |
| **Auto-Seasonal Inference** | Timezone-Aware (`Asia/Kolkata`) Temporal Logic | Infers active Indian crop season (Kharif: Jun-Sep, Rabi: Oct-Feb, Summer: Mar-May) based on client datetime when parameters are omitted. |

---

## 📊 System Architecture

The following diagram illustrates the data flow of the recommendation system, mapping client requests through the FastAPI gateway, local ML and dataset computation, external Gemini LLM integration, and returning clean JSON payloads.

```mermaid
flowchart TD
    %% Custom Styling
    classDef client fill:#d4e6f1,stroke:#2980b9,stroke-width:2px,color:#1b4f72;
    classDef gateway fill:#fadbd8,stroke:#e74c3c,stroke-width:2px,color:#78281f;
    classDef mlEngine fill:#d5f5e3,stroke:#2ecc71,stroke-width:2px,color:#145a32;
    classDef fallback fill:#fcf3cf,stroke:#f1c40f,stroke-width:2px,color:#7d6608;
    classDef gemini fill:#e8daef,stroke:#8e44ad,stroke-width:2px,color:#4a235a;
    
    Client["📱 Client Request / Swagger UI"]:::client
    Gateway["⚡ FastAPI Router (app3.py)"]:::gateway
    
    subgraph CoreEngine ["⚙️ Core Processing Layer"]
        SoilDB["🛢️ Soil NPK Database (india_district_npk.csv)"]:::fallback
        CropDB["🛢️ Production Stats (India Agriculture Crop Production.csv)"]:::fallback
        Fallback["🔄 Hierarchical Query Fallback Engine"]:::fallback
        MLEngine["🧠 Scikit-Learn Pipeline (hybrid_crop_model.joblib)"]:::mlEngine
        MLB["🏷️ Label Binarizer (hybrid_mlb.joblib)"]:::mlEngine
        HybridScorer["⚖️ Hybrid Scoring Algorithm"]:::mlEngine
    end
    
    subgraph ExternalServices ["🌐 External Integration Layer"]
        Gemini["✨ Google Gemini API (gemini-2.5-flash)"]:::gemini
    end
    
    %% Connections
    Client -->|"/recommend"| Gateway
    Client -->|"/result/recommend"| Gateway
    
    Gateway --> SoilDB
    Gateway --> Fallback
    Fallback --> CropDB
    
    Gateway --> MLEngine
    MLEngine --> MLB
    
    MLEngine -->|P_ML| HybridScorer
    Fallback -->|P_Freq| HybridScorer
    
    Gateway -->|Prompt: Soil Stats + Hybrid Top Crops| Gemini
    
    HybridScorer -->|JSON Response| Client
    Gemini -->|JSON Response (Economic Strategies)| Client
```

---

## 📂 Project Directory Structure

```
AI-Crop-Recommendation-System/
├── .git/                      # Version control metadata (Git-ignored)
├── model3_fastapi/            # Core Model & Dataset Artifacts directory
│   ├── hybrid_crop_model.joblib   # Trained Scikit-Learn ML pipeline
│   ├── hybrid_mlb.joblib          # Trained Multi-Label LabelBinarizer
│   ├── hybrid_stats.joblib        # Offline pre-computed statistical tables
│   ├── India Agriculture Crop Production.csv  # 27MB historical crop production database
│   └── india_district_npk.csv     # Localized soil N, P, K, pH chemistry database
├── .gitattributes             # Git attributes file
├── LICENSE                    # Open-source license file (MIT)
├── README.md                  # Developer Documentation (This file)
├── app3.py                    # Production FastAPI entry point & API Router
└── backup.txt                 # Legacy application script backup
```

---

## 🚀 Installation & Setup

Follow these steps to set up and launch AgriMind in your local environment.

### 1. Prerequisites
- **Python 3.9 - 3.12** installed on your system.
- **Google Gemini API Key** (Required for the `/result/recommend` economic endpoint).

### 2. Environment Setup

Clone the repository to your local machine, open your terminal (e.g., PowerShell on Windows), and navigate to the project directory:

```powershell
# Navigate to the project root directory
cd AI-Crop-Recommendation-System

# Create a virtual environment
python -m venv myenv

# Activate the virtual environment
.\myenv\Scripts\activate
```

### 3. Install Dependencies

Install the required packages. Ensure Scikit-Learn matches version `1.7.2` to load the `.joblib` model artifacts correctly:

```powershell
pip install fastapi uvicorn scikit-learn==1.7.2 pandas numpy requests pydantic
```

### 4. Configuration

Configure your Gemini API key. By default, the key is configured in `app3.py` under the `GEMINI_API_KEY` global variable. Alternatively, you can set it as an environment variable in your terminal before launching the server:

```powershell
# Set Gemini API Key environment variable
$env:GEMINI_API_KEY="AIzaSyYourGeminiApiKeyHere"
```

### 5. Run the Server

Launch the FastAPI application using the Uvicorn development server:

```powershell
uvicorn app3:app --reload
```

---

## 📡 API Reference & Payload Specifications

### 1. Pure ML Prediction Endpoint
`GET /recommend`

Retrieves crop recommendations sorted by the hybrid model probability score along with local soil telemetry.

#### Query Parameters
| Parameter | Type | Required | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `state` | `string` | No | `None` | `Karnataka` | Name of the state to search. |
| `district` | `string` | No | `None` | `Davangere` | Name of the district to search. |
| `year` | `string` | No | `None` | `2001-02` | Crop year range. |
| `season` | `string` | No | `None` | `Kharif` | Crop season (Kharif, Rabi, Summer). |
| `top_k_crops` | `integer` | No | `10` | `5` | Maximum number of crops to return. |
| `ml_prob_threshold` | `float` | No | `0.05` | `0.1` | Cutoff probability for predictions. |

#### Sample Response (`200 OK`)
```json
{
  "state": "Karnataka",
  "district": "Davangere",
  "year": "2001-02",
  "season": "Kharif",
  "soil_info": {
    "N_ppm": 280.5,
    "P_ppm": 22.4,
    "K_ppm": 195.1,
    "pH_avg": 6.8
  },
  "recommendations": [
    {
      "crop": "Rice",
      "model_probability": 0.892,
      "best_season": {
        "season": "Kharif",
        "probability": 0.912
      },
      "all_seasons": [
        {
          "season": "Kharif",
          "probability": 0.912
        },
        {
          "season": "Summer",
          "probability": 0.088
        }
      ]
    }
  ]
}
```

---

### 2. Advanced Economic Strategy Endpoint
`GET /result/recommend`

Feeds local ML telemetry, historical frequencies, and soil parameters into Google Gemini to build structural financial projections for the top 3 crops.

#### Query Parameters
Same parameters as `GET /recommend`.

#### Sample Response (`200 OK`)
```json
{
  "state": "Karnataka",
  "district": "Davangere",
  "year": "2001-02",
  "season": "Kharif",
  "soil_info": {
    "N_ppm": 280.5,
    "P_ppm": 22.4,
    "K_ppm": 195.1,
    "pH_avg": 6.8
  },
  "recommendations": [
    {
      "crop": "Rice",
      "model_probability": 0.892,
      "investment": "₹22,000 - ₹28,000 per acre",
      "profit": "₹35,000 - ₹45,000 per acre",
      "investment_breakdown": {
        "seeds": "₹3,500",
        "labour": "₹12,000",
        "fertilizer": "₹6,000",
        "other": "₹3,500"
      },
      "duration_to_grow": "110 - 120 days",
      "season": "Kharif",
      "reasoning": "Rice matches the high historic Kharif probability and is well-suited for the clayey soils in Davangere. Local NPK levels support robust vegetative growth during the monsoon season."
    }
  ]
}
```

---

### 3. Diagnostics & Health Check
`GET /health`

Verifies if local machine learning classifiers, encoders, and CSV datasets have initialized successfully.

#### Sample Response (`200 OK`)
```json
{
  "status": "ok",
  "model_loaded": true,
  "mlb_loaded": true,
  "dataset_loaded": true,
  "npk_dataset_loaded": true
}
```

---

## 🧪 Verification & Testing

Verify that your installation is running correctly by using any of the following methods:

1. **Swagger UI Validation:** Navigating to `http://127.0.0.1:8000/docs` in your browser. Use the Swagger interactive console to execute a query for `state=Karnataka` and `district=Davangere`.
2. **Terminal Health Check:** Execute a curl command or query the API directly via PowerShell:
   ```powershell
   Invoke-RestMethod -Uri "http://127.0.0.1:8000/health"
   ```
   **Expected Response:**
   ```json
   { "status": "ok", "model_loaded": true, "mlb_loaded": true, "dataset_loaded": true, "npk_dataset_loaded": true }
   ```
