FROM python:3.12-slim

WORKDIR /workspace

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        coreutils && \
    rm -rf /var/lib/apt/lists/*

COPY . /workspace

CMD ["/bin/bash"]
