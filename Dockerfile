FROM python:3.11-slim

WORKDIR /app

# Install dependencies
RUN apt-get update && \
    apt-get -y install git libgomp1 cmake && \
    pip install --upgrade pip setuptools && \
    pip install numpy pyyaml mkl mkl-include setuptools cmake cffi typing_extensions

# Clone PyTorch and build
RUN git clone --recursive https://github.com/pytorch/pytorch && \
    cd pytorch && \
    git checkout v1.13.0 && \
    python setup.py install

COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY . .

ENV PYTHONPATH="/app:/app/ImageBind"

RUN ./download.py

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["uvicorn app:app --host 0.0.0.0 --port 8080"]
