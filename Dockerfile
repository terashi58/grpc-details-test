# syntax = docker/dockerfile:1

FROM golang:1.17-bullseye
ARG PROTOC_VERSION=3.20.0
ARG PROTOC_GEN_GO_VERSION=1.28.0
ARG PROTOC_GEN_GO_GRPC_VERSION=1.2.0
# ARG EVANS_VERSION=0.10.5
ARG EVANS_HASH=823938c
ARG GRPCURL_VERSION=1.8.6

RUN apt-get update \
    && apt-get install -y --no-install-recommends git curl unzip make tmux \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # install proto tools
    && curl -fsSL -o /tmp/protoc-linux-x86_64.zip "https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip" \
    && unzip -p /tmp/protoc-linux-x86_64.zip bin/protoc > /usr/local/bin/protoc \
    && chmod +x /usr/local/bin/protoc \
    && rm /tmp/protoc-linux-x86_64.zip \
    && go install "google.golang.org/protobuf/cmd/protoc-gen-go@v${PROTOC_GEN_GO_VERSION}" \
    && go install "google.golang.org/grpc/cmd/protoc-gen-go-grpc@v${PROTOC_GEN_GO_GRPC_VERSION}" \
    # install grpc clients
    # && curl -SL https://github.com/ktr0731/evans/releases/download/v${EVANS_VERSION}/evans_linux_amd64.tar.gz | \
    # tar zx -C /usr/local/bin evans --no-same-owner --no-same-permissions \
    && go install "github.com/ktr0731/evans@${EVANS_HASH}" \
    && cp ${GOPATH}/bin/evans /usr/local/bin \
    && curl -SL https://github.com/fullstorydev/grpcurl/releases/download/v${GRPCURL_VERSION}/grpcurl_${GRPCURL_VERSION}_linux_x86_64.tar.gz | \
    tar zx -C /usr/local/bin grpcurl --no-same-owner --no-same-permissions

WORKDIR /grpc-details

COPY . .

RUN make build

CMD ["bash"]
