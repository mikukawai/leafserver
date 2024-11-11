package internal

import (
	"app/protos/out/cl"
	"reflect"

	"github.com/mikukawai/leaf/gate"
	"github.com/mikukawai/leaf/log"
)

func init() {
	// 向当前模块（game 模块）注册 Hello 消息的消息处理函数 handleHello
	handler(&cl.C2L_Login{}, handleHello)
}
func handler(m interface{}, h interface{}) {
	skeleton.RegisterChanRPC(reflect.TypeOf(m), h)
}
func handleHello(args []interface{}) {
	// 收到的 Hello 消息
	m := args[0].(*cl.C2L_Login)
	// 消息的发送者
	a := args[1].(gate.Agent)
	// 输出收到的消息的内容
	log.Debug("login %v", m.GetUid())
	// 给发送者回应一个 Hello 消息
	a.WriteMsg(&cl.L2C_Login{
		Ret: 1,
	})
}
