# AI Crop Recommendation System

A powerful, fast, and intelligent FastAPI-based web service that recommends the most optimal crops to grow based on regional agricultural history, hyper-local soil chemistry, and predictive machine learning models.

## Features

- **Machine Learning Engine**: Utilizes a custom, pre-trained `scikit-learn` hybrid model to generate mathematical crop probabilities tailored to specific regions.
- **Soil Chemistry Cross-Referencing**: Automatically cross-references user input against localized datasets to fetch average N, P, K, and pH values.
- **Economic Estimations**: Leverages high-level Generative AI to provide nuanced, real-world financial breakdowns including estimated investments (seeds, labor, fertilizer) and projected profits.
- **Smart Filtering**: Built-in cascading fallback logic ensures accurate estimations even when optional parameters (like specific tracking years or seasons) are omitted.
- **Interactive Documentation**: Instant API testing available via the automatically generated Swagger UI page.

## Core Endpoints

### 1. `GET /recommend` (Pure ML Prediction)

Provides lightning-fast, offline predictions strictly derived from the local `.joblib` machine learning models and dataset statistical frequencies.

- **Key Output**: Top Recommended Crops, Model Probability (%), and Optimal Growing Seasons.

### 2. `GET /result/recommend` (Advanced Economic Strategy)

A hybrid endpoint that feeds regional soil profiles and the mathematical accuracy calculations from your local ML model into an advanced Generative Language AI.

- **Key Output**: Crop Name, Model Accuracy Probability, Detailed Investment Costs, Expected Profit Margins, Harvest Duration, and Technical Reasoning.

### 3. `GET /health`

A fast diagnostic endpoint to verify if system dependencies, datasets, and machine learning `.joblib` artifacts have successfully initialized.

## Technologies Used

- **Backend Framework**: Python (FastAPI, Uvicorn)
- **Data Engineering**: Pandas, NumPy
- **Machine Learning**: Scikit-Learn

## Installation & Setup

1. **Activate your virtual environment**  
   _(Windows Example)_:

   ```powershell
   .\myenv\Scripts\activate
   ```

2. **Install Required Packages**:  
   Ensure you have the required dependencies, specifically matching the ML environment versions.

   ```powershell
   pip install fastapi uvicorn scikit-learn==1.7.2 pandas numpy requests pydantic
   ```

3. **Start the API Server**:

   ```powershell
   uvicorn app3:app --reload
   ```

4. **Testing Interactively**:  
   Open your browser and navigate to `http://127.0.0.1:8000/docs` to use the built-in Swagger interface. You can immediately pass parameters like `state=Karnataka` and `district=Davangere` to see the live results!
