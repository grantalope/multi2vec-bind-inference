FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04


WORKDIR /app

# Update and install dependencies
RUN apt-get update && \
    apt-get -y install git libgomp1 && \
    pip install --upgrade pip setuptools

# Install PyTorch, torchvision, and torchaudio compatible with CUDA 11.8
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY . .

ENV PYTHONPATH="/app:/app/ImageBind"

RUN ./download.py

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["uvicorn app:app --host 0.0.0.0 --port 8080"]
