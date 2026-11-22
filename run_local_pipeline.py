"""Run the local BDATL pipeline on Windows/macOS/Linux without Hadoop or Docker.

Usage: python main.py --period 2y
       python main.py --period 1y --tickers RELIANCE.NS TCS.NS INFY.NS
"""
import argparse
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parent
DATA = ROOT / "data"
DEFAULT_TICKERS = ["RELIANCE.NS", "TCS.NS", "INFY.NS", "HDFCBANK.NS", "ICICIBANK.NS"]

def run(command, env):
    print("\n>>> " + " ".join(map(str, command)), flush=True)
    subprocess.run(command, cwd=ROOT, env=env, check=True)

def main():
    parser = argparse.ArgumentParser(description="BDATL local pipeline")
    parser.add_argument("--period", default="2y", help="yfinance period: 6mo, 1y, 2y, 5y")
    parser.add_argument("--tickers", nargs="+", default=DEFAULT_TICKERS)
    parser.add_argument("--skip-news", action="store_true", help="Skip RSS news collection")
    args = parser.parse_args()
    env = os.environ.copy()
    env["BDATL_DATA_DIR"] = str(DATA)
    (DATA / "logs").mkdir(parents=True, exist_ok=True)
    print("BDATL LOCAL PIPELINE - Docker/Hadoop not required for this mode")
    print(f"Data directory: {DATA}")
    run([sys.executable, "-m", "src.ingestion.fetch_price", "--tickers", *args.tickers,
         "--period", args.period, "--no-hdfs"], env)
    if not args.skip_news:
        run([sys.executable, "-m", "src.ingestion.fetch_news", "--no-hdfs"], env)
    run([sys.executable, "-m", "src.pipeline_standalone"], env)
    print("\nPipeline finished. Start the dashboard with:")
    print("python -m streamlit run src/dashboard/dashboard.py")

if __name__ == "__main__":
    main()
