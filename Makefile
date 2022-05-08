build:
	cd src && \
	  protoc -I . --go_out=paths=source_relative:. --go-grpc_out=paths=source_relative:. proto/*.proto && \
	  go build -o ../bin/server .

run:
	./bin/server

evans:
	echo '{"name":"gopher","error_message":"fail"}' | evans --path ./src/ --proto proto/sub.proto,proto/hello.proto,proto/common.proto cli call --enrich Say

evans-reflect:
	echo '{"name":"gopher","error_message":"fail"}' | evans -r cli call --enrich Say

grpcurl:
	grpcurl -plaintext -d '{"name":"gopher","error_message":"fail"}' -import-path ./src/ -proto proto/hello.proto -proto proto/common.proto localhost:50051 sample.Hello/Say

grpcurl-reflect:
	grpcurl -plaintext -d '{"name":"gopher","error_message":"fail"}' localhost:50051 sample.Hello/Say
