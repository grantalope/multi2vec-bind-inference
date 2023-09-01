FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && \
    apt-get -y install git libgomp1 && \
    pip install --upgrade pip setuptools

# Install a compatible PyTorch version
RUN pip install torch==1.13.0+cu118 -f https://download.pytorch.org/whl/cu118/torch_stable.html

COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY . .

ENV PYTHONPATH="/app:/app/ImageBind"

RUN ./download.py

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["uvicorn app:app --host 0.0.0.0 --port 8080"]

