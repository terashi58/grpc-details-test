build:
	cd src && \
	  protoc -I . --go_out=paths=source_relative:. --go-grpc_out=paths=source_relative:. proto/hello.proto && \
	  go build -o ../bin/server .

run:
	./bin/server

evans:
	echo '{"name":"gopher","error_message":"fail"}' | evans --proto ./src/proto/hello.proto cli call --enrich Say

evans-reflect:
	echo '{"name":"gopher","error_message":"fail"}' | evans -r cli call --enrich Say

grpcurl:
	grpcurl -plaintext -d '{"name":"gopher","error_message":"fail"}' -proto ./src/proto/hello.proto localhost:50051 sample.Hello/Say
