FROM nvidia/cuda:12.2.0-devel-ubuntu20.04

# Set non-interactive mode to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set CUDA_HOME
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=$CUDA_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

# Add PPA and install Python 3.10
RUN apt-get update && apt-get install -y software-properties-common curl \
 && add-apt-repository ppa:deadsnakes/ppa -y \
 && apt-get update && apt-get install -y \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    python3-pip \
    build-essential
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1

RUN curl -sS https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
 && python3.10 get-pip.py \
 && rm get-pip.py
RUN python3 -m pip install --upgrade pip

WORKDIR /resemble-enhance

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

CMD ["python3", "main.py"]
