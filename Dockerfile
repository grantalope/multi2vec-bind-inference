# Start from NVIDIA CUDA with cuDNN
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04

WORKDIR /app

# Update and install dependencies
RUN apt-get update && \
    apt-get -y install git libgomp1 && \
    pip install --upgrade pip setuptools

# You can skip installing PyTorch, torchvision, and torchaudio here as they are already part of the CUDA image

# Rest of your Dockerfile
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

ENV PYTHONPATH="/app:/app/ImageBind"

RUN ./download.py

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["uvicorn app:app --host 0.0.0.0 --port 8080"]
