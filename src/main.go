package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net"

	"github.com/golang/protobuf/ptypes"
	pb "github.com/terashi58/grpc-details-test/proto"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/reflection"
	"google.golang.org/grpc/status"
)

var (
	port = flag.Int("port", 50051, "The server port")
)

type server struct {
	pb.UnimplementedHelloServer
}

func (s *server) Say(ctx context.Context, in *pb.SayRequest) (*pb.SayResponse, error) {
	log.Printf("Received: %v", in.GetName())
	if msg := in.GetErrorMessage(); msg != "" {
		st := status.New(codes.Internal, "error with details")
		st2, err := st.WithDetails(
			&pb.Extension{Message: msg},
			ptypes.TimestampNow(),
		)
		if err != nil {
			return nil, err
		}
		return nil, st2.Err()
	}
	return &pb.SayResponse{Greet: "Hello " + in.GetName()}, nil
}

func main() {
	flag.Parse()
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", *port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer()
	pb.RegisterHelloServer(s, &server{})
	reflection.Register(s)
	log.Printf("server listening at %v", lis.Addr())
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
