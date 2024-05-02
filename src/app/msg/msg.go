package msg

import (
	"app/protos/out/cl"

	"github.com/mikukawai/leaf/network/protobuf"
)

var Processor = protobuf.NewProcessor()

func init() {
	Processor.Register(&cl.Hello{})
}
