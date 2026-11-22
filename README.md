<img width="1600" height="800" alt="WhatsApp Image 2026-11-19 at 6 56 10 PM" src="https://github.com/user-attachments/assets/85cb3edd-42c4-4dcc-9258-b2b9c0fda23a" /># 📊 BDATL Engine — Indian Stock Market Sentiment & Anomaly Detection

> Real-time sentiment analysis, price-anomaly detection, sector momentum and short-term price projection for Indian (NSE) stocks — with a Streamlit dashboard and an optional Hadoop/Spark distributed stack.

![Python](https://img.shields.io/badge/Python-3.10--3.12-blue?logo=python&logoColor=white)
![Streamlit](https://img.shields.io/badge/Streamlit-Dashboard-FF4B4B?logo=streamlit&logoColor=white)
![Pandas](https://img.shields.io/badge/Pandas-NumPy-150458?logo=pandas&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Hadoop%20%2F%20Spark-2496ED?logo=docker&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

**Author:** Arshad Kabir

---

## 📌 Overview

BDATL Engine (Big Data Analytics & Technologies Lab project) fuses **OHLCV price data** from Yahoo Finance with **financial news headlines** from Indian RSS feeds to:

- score news **sentiment** per stock,
- detect **price/volume anomalies**,
- compute **sector momentum** over 30/60/90-day windows,
- show a **future price projection** with honest hold-out metrics,
- present everything in an interactive **Streamlit dashboard**.

The project supports two run modes:

| Mode | What runs | Requirements |
|---|---|---|
| **Local mode** (recommended) | Ingestion + pandas/NumPy/TextBlob analytics + Streamlit | Python only |
| **Distributed mode** (optional) | HDFS, YARN, Spark, Hive, Pig, HBase on a 4-node Docker cluster | Docker + several machines |

---

## 🖼️ Screenshots

**Market sentiment overview — KPIs and watchlist performance indexed to 100**

<img width="1600" height="800" alt="WhatsApp Image 2026-11-19 at 6 56 10 PM" src="https://github.com/user-attachments/assets/b52a38e0-2016-4369-9fc1-f7adb5966f41" />


**Recent anomaly alerts and sector momentum heatmap**

<img width="1600" height="852" alt="WhatsApp Image 2026-11-19 at 6 56 25 PM" src="https://github.com/user-attachments/assets/0532fdbb-de3d-4eaa-970f-426aaba984fc" />


**Price analytics and future price prediction with hold-out metrics**

<img width="1555" height="621" alt="WhatsApp Image 2026-11-19 at 7 16 00 PM" src="https://github.com/user-attachments/assets/e0ac9f31-0236-4da0-b65a-2c2bb2bbaed8" />


---

## ✨ Features

- **Data ingestion** — daily OHLCV prices via `yfinance` (NSE `.NS` tickers); headlines from Moneycontrol, Economic Times, LiveMint and NDTV Profit RSS feeds, auto-tagged to tickers.
- **Sentiment analysis** — TextBlob polarity scored per headline and labelled positive / neutral / negative.
- **Anomaly detection** — flags `statistical_outlier`, `price_volume_spike` and `volume_surge` days using returns, 7-day volatility, volume ratio vs. the 20-day average and SMAs.
- **Sector momentum** — rolling 30/60/90-day sentiment momentum per sector (map of ~500 NIFTY stocks in `src/config/tickers.py`).
- **Price prediction** — a NumPy ridge-regularised linear model on lagged log-returns, rolled forward N trading days, with chronological hold-out **MAE, RMSE and directional accuracy** plus an uncertainty band.
- **Dashboard pages** — Market Overview, Ticker Detail, Sector Heatmap and Event Replay, with date-range, ticker and anomaly-type filters and a one-click **Re-run Pipeline** button.

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│   Streamlit: Overview │ Ticker Detail │ Heatmap │ Replay │
└────────────────────────────┬─────────────────────────────┘
                             │
┌────────────────────────────┴─────────────────────────────┐
│                 ANALYTICS / ML LAYER                     │
│  Sentiment (TextBlob) │ Anomaly Detection │ Momentum     │
│  Price forecast (ridge regression, NumPy)                │
└────────────────────────────┬─────────────────────────────┘
                             │
┌────────────────────────────┴─────────────────────────────┐
│             BATCH LAYER (distributed mode only)          │
│          Hive │ Pig (ETL / joins) │ HBase                │
└────────────────────────────┬─────────────────────────────┘
                             │
┌────────────────────────────┴─────────────────────────────┐
│                    INGESTION LAYER                       │
│        yfinance (NSE prices) │ RSS news feeds            │
└──────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
Stock-Analysis-BDMS-Project/
├── main.py                    # Entry point → runs the local pipeline
├── run_local_pipeline.py      # Ingestion → analytics orchestration
├── requirements-local.txt     # Dependencies for local mode
├── requirements.txt           # Full dependencies (incl. PySpark, scikit-learn)
├── pyproject.toml
├── .env.example               # Environment variable template
├── Dockerfile                 # Hadoop + Spark image (distributed mode)
├── docker-compose.yml         # 1 master + 3 slave cluster
├── entrypoint.sh
├── run_pipeline.sh
├── config/                    # Hadoop / YARN / Spark config files
├── data/
│   ├── raw/prices/            # OHLCV CSVs (one per ticker)
│   ├── raw/news/              # Scraped news CSVs
│   └── processed/             # sentiment / anomalies / momentum CSVs
├── docs/images/               # README screenshots
└── src/
    ├── config/tickers.py      # Ticker → sector map
    ├── ingestion/             # fetch_price.py, fetch_news.py
    ├── pipeline_standalone.py # pandas/NumPy analytics (local mode)
    ├── ml/                    # PySpark versions: sentiment, anomaly, momentum
    ├── batch/                 # Hive schema, Pig ETL, HBase setup
    └── dashboard/dashboard.py # Streamlit app
```

---

## 🚀 Quick Start (Local Mode)

### 1. Clone the repository
```bash
git clone https://github.com/arshad174/Stock_Analysis_BDMS.git
cd Stock_Analysis_BDMS
```

### 2. Create a virtual environment

**Windows (PowerShell)**
```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
```
> If activation is blocked: `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass`

**macOS / Linux**
```bash
python3 -m venv .venv
source .venv/bin/activate
```

> Use Python **3.10 – 3.12** (see `pyproject.toml`).

### 3. Install dependencies
```bash
python -m pip install --upgrade pip setuptools wheel
pip install -r requirements-local.txt
```

### 4. Run the data pipeline
```bash
python main.py --period 2y
```

Useful options:
```bash
# Faster test with fewer stocks
python main.py --period 1y --tickers RELIANCE.NS TCS.NS INFY.NS

# Skip news collection
python main.py --period 2y --skip-news

# Re-run analytics only on already-downloaded CSVs
python -m src.pipeline_standalone
```

Default watchlist: `RELIANCE.NS`, `TCS.NS`, `INFY.NS`, `HDFCBANK.NS`, `ICICIBANK.NS`.

### 5. Launch the dashboard
In a **second terminal** (project root, venv active):
```bash
python -m streamlit run src/dashboard/dashboard.py
```
Open **http://localhost:8501**.

> `main.py` runs the data pipeline only. The dashboard is started separately with Streamlit.

---

## 🐳 Distributed Mode (Optional)

Runs HDFS, YARN, Spark, Hive, Pig and HBase on a 1-master + 3-slave Docker cluster across machines on the same LAN.

1. Find each machine's IPv4 address (`ipconfig` on Windows, `ifconfig` on macOS/Linux).
2. On **every** machine create a `.env` file in the project root:
   ```ini
   MASTER_IP=192.168.x.x
   SLAVE1_IP=192.168.x.x
   SLAVE2_IP=192.168.x.x
   SLAVE3_IP=192.168.x.x
   ```
3. Start each node on its own machine:
   ```bash
   docker-compose up --build -d master   # on the master
   docker-compose up --build -d slave1   # on slave 1 (repeat for slave2, slave3)
   ```
4. Verify at `http://<MASTER_IP>:9870` — it should show 3 active DataNodes.
5. Run the pipeline inside the master container (`docker exec -it master bash`):
   ```bash
   python /app/src/ingestion/fetch_price.py
   python /app/src/ingestion/fetch_news.py
   hive -f /app/src/batch/hive_schema.hql
   pig  -f /app/src/batch/etl_normalize_join.pig
   bash /app/src/batch/hbase_setup.sh
   spark-submit --master spark://master:7077 /app/src/ml/nlp_sentiment.py
   spark-submit --master spark://master:7077 /app/src/ml/anomaly_detector.py
   spark-submit --master spark://master:7077 /app/src/ml/momentum_mapreduce.py
   streamlit run /app/src/dashboard/dashboard.py --server.port 8501 --server.address 0.0.0.0
   ```

| Service | URL |
|---|---|
| HDFS NameNode | `http://<MASTER_IP>:9870` |
| YARN ResourceManager | `http://<MASTER_IP>:8088` |
| Spark Master | `http://<MASTER_IP>:8080` |
| MapReduce History | `http://<MASTER_IP>:19888` |
| Streamlit Dashboard | `http://<MASTER_IP>:8501` |

---

## 📤 Output Data

| File | Contents |
|---|---|
| `data/processed/sentiment/sentiment.csv` | Per-headline sentiment score, label and confidence by ticker |
| `data/processed/anomalies/anomalies.csv` | Anomaly date, type, score, daily return and volume ratio |
| `data/processed/momentum/momentum.csv` | Sector momentum for 30/60/90-day windows |

---

## ⚠️ Limitations

- **Not investment advice.** The price projection is a simple statistical estimate for learning purposes; markets are noisy and the hold-out accuracy shown in the dashboard is modest.
- Sentiment uses TextBlob on short headlines, so many scores come out neutral (this is why average sentiment can read `0.000`).
- Reddit ingestion (`fetch_reddit.py`) is referenced in the design but is **not included** in this repository.
- Local mode does not execute the Hive / Pig / HBase / HDFS / Spark jobs; local momentum is computed with pandas, not Hadoop MapReduce.
- Distributed mode has been set up for a lab cluster and needs additional integration testing.
- Live data depends on Yahoo Finance and RSS providers, which may throttle or change feeds.

---

## 🛠️ Tech Stack

Python • pandas • NumPy • TextBlob • feedparser • yfinance • Streamlit • Plotly • Altair • Docker • Hadoop (HDFS, YARN, MapReduce) • Spark • Hive • Pig • HBase

---

## 🔮 Future Improvements

- Replace TextBlob with a finance-tuned model (e.g. FinBERT)
- Add Reddit / social sentiment ingestion
- Add unit tests and a CI workflow
- Automated scheduled pipeline runs

---

## 👤 Author

**Arshad Kabir**

Feel free to open an issue or pull request if you have suggestions.

## 📄 License

Released under the [MIT License](LICENSE).
