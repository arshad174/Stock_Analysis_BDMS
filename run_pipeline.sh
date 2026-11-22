#!/bin/bash
# ============================================================================
# run_pipeline.sh — Master Pipeline Orchestrator
# ============================================================================
# Run this inside the master container to execute the full pipeline:
#   docker exec -it master bash /app/run_pipeline.sh
#
# Stages:
#   1. Ingest price data (yfinance — no credentials needed)
#   2. Ingest news data (RSS feeds — no credentials needed)
#   3. Ingest Reddit data (needs REDDIT_ env vars — skipped if missing)
#   4. Run standalone processing (sentiment + anomaly + momentum)
# ============================================================================
set -e

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║     BDATL — Full Pipeline Execution                     ║"
echo "║     Indian Market Sentiment & Anomaly Detection         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

cd /app

# ── Stage 1: Price Ingestion ────────────────────────────────────
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📈 Stage 1/4: Ingesting Price Data (yfinance)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
python -m src.ingestion.fetch_price --period 5y || {
    echo "⚠️  Price ingestion had errors, continuing..."
}

# ── Stage 2: News Ingestion ─────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📰 Stage 2/4: Ingesting News Data (RSS feeds)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
python -m src.ingestion.fetch_news || {
    echo "⚠️  News ingestion had errors, continuing..."
}

# ── Stage 3: (Removed Reddit Stage) ───────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💬 Stage 3/4: Skipping Reddit Ingestion (Removed)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"


# ── Stage 4: Processing (Sentiment + Anomaly + Momentum) ───────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧠 Stage 4/4: Running PySpark ML Pipeline on Cluster..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "  -> NLP Sentiment Analysis..."
spark-submit --master spark://master:7077 \
    --conf spark.cores.max=2 \
    --driver-memory 768m --executor-memory 768m \
    /app/src/ml/nlp_sentiment.py || {
    echo "⚠️  Sentiment pipeline had errors."
}

echo "  -> Anomaly Detection..."
spark-submit --master spark://master:7077 \
    --conf spark.cores.max=2 \
    --driver-memory 768m --executor-memory 768m \
    /app/src/ml/anomaly_detector.py || {
    echo "⚠️  Anomaly detection had errors."
}

echo "  -> Momentum MapReduce..."
spark-submit --master spark://master:7077 \
    --conf spark.cores.max=2 \
    --driver-memory 768m --executor-memory 768m \
    /app/src/ml/momentum_mapreduce.py || {
    echo "⚠️  Momentum pipeline had errors."
}

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  ✅ Pipeline Complete!                                   ║"
echo "║  Dashboard: http://localhost:8501                        ║"
echo "║  Refresh the Streamlit page to see updated data.         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
