FROM gcr.io/dataflow-templates-base/python3-template-launcher-base

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    # Make sure psycopg2-binary is properly installed
    python -c "import psycopg2; print('psycopg2 successfully imported')" && \
    # Verify apache_beam is installed correctly
    python -c "from apache_beam import pvalue; print('Apache Beam pvalue successfully imported')"

# Add PostgreSQL JDBC driver
ADD https://jdbc.postgresql.org/download/postgresql-42.7.2.jar /opt/postgresql-42.7.2.jar
ENV CLASSPATH="/opt/postgresql-42.7.2.jar"

# Copy the pipeline script
COPY main.py /dataflow/template/main.py

# Test if the file is correctly copied
RUN ls -la /dataflow/template/main.py

# Set up environment variables for launcher
ENV FLEX_TEMPLATE_PYTHON_PY_FILE="/dataflow/template/main.py"
ENV FLEX_TEMPLATE_PYTHON_REQUIREMENTS_FILE="/requirements.txt"

# Set Python path to ensure modules are found
ENV PYTHONPATH="${PYTHONPATH}:/dataflow/template/"