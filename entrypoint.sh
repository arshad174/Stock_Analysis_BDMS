#!/bin/bash
# ============================================================================
# Entrypoint for Hadoop/Spark Docker containers
# Role is determined by the NODE_ROLE environment variable: master | slave
# ============================================================================
set -e

echo "============================================"
echo " Node Role : ${NODE_ROLE:-master}"
echo " Hostname  : $(hostname)"
echo "============================================"

# Start SSH daemon (required for Hadoop inter-node communication)
service ssh start

if [ "${NODE_ROLE}" = "master" ]; then
    echo "[MASTER] Formatting HDFS NameNode (if not already formatted)..."
    if [ ! -d "/hadoop/dfs/name/current" ]; then
        hdfs namenode -format -force -nonInteractive
    fi

    echo "[MASTER] Starting HDFS NameNode..."
    hdfs --daemon start namenode

    echo "[MASTER] Forcing NameNode out of safe mode to allow early directory creation..."
    hdfs dfsadmin -safemode wait || hdfs dfsadmin -safemode leave || true
    sleep 5
    hdfs dfsadmin -safemode leave || true

    echo "[MASTER] Preparing HDFS directories..."
    hdfs dfs -mkdir -p /spark-logs
    hdfs dfs -mkdir -p /data/raw/prices
    hdfs dfs -mkdir -p /data/raw/news
    hdfs dfs -mkdir -p /data/raw/reddit
    hdfs dfs -mkdir -p /data/processed/sentiment
    hdfs dfs -mkdir -p /data/processed/anomalies
    hdfs dfs -mkdir -p /data/processed/momentum
    hdfs dfs -chmod -R 777 /spark-logs /data

    echo "[MASTER] Starting YARN ResourceManager..."
    yarn --daemon start resourcemanager

    echo "[MASTER] Starting Spark Master..."
    ${SPARK_HOME}/sbin/start-master.sh

    echo "[MASTER] Starting MapReduce JobHistory Server..."
    mapred --daemon start historyserver

    echo "[MASTER] All services started."

    # Wait for DataNodes to register before any pipeline work
    echo "[MASTER] Waiting 15s for DataNodes to register..."
    sleep 15
    hdfs dfsadmin -report

    echo "[MASTER] Starting Streamlit Dashboard on port 8501..."
    cd /app
    nohup streamlit run src/dashboard/dashboard.py \
        --server.port=8501 \
        --server.address=0.0.0.0 \
        --server.headless=true \
        > /tmp/streamlit.log 2>&1 &

    # Auto-run the data pipeline in background
    echo "[MASTER] Launching data pipeline in background..."
    nohup bash /app/run_pipeline.sh > /tmp/pipeline.log 2>&1 &

else
    echo "[SLAVE] Waiting for NameNode to become reachable..."
    for i in $(seq 1 60); do
        if hdfs dfs -ls / > /dev/null 2>&1; then
            echo "[SLAVE] NameNode is reachable after ${i}s."
            break
        fi
        echo "[SLAVE] NameNode not ready yet... (${i}/60)"
        sleep 1
    done

    echo "[SLAVE] Starting HDFS DataNode..."
    hdfs --daemon start datanode

    echo "[SLAVE] Starting YARN NodeManager..."
    yarn --daemon start nodemanager

    echo "[SLAVE] Starting Spark Worker..."
    ${SPARK_HOME}/sbin/start-worker.sh spark://master:7077

    echo "[SLAVE] All services started."
fi

echo "============================================"
echo " Container ready. Tailing logs..."
echo "============================================"

# Keep container alive by tailing Hadoop logs
tail -f ${HADOOP_HOME}/logs/*.log 2>/dev/null || tail -f /dev/null
