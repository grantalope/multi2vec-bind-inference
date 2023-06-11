FROM python:3.8-slim

WORKDIR /app

RUN apt-get update
RUN pip install --upgrade pip setuptools

COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY download.py .
RUN ./download.py

COPY . .

ENV PYTHONPATH="/app:/app/ImageBind"

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["uvicorn app:app --host 0.0.0.0 --port 8080"]
