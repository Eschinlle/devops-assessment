FROM python:3.11-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

FROM python:3.11-slim

WORKDIR /app

RUN useradd -m -u 1000 appuser

COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local

COPY --chown=appuser:appuser app/ ./app/

USER appuser

ENV PATH=/home/appuser/.local/bin:$PATH

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
