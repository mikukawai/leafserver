package main

import (
	"context"
	"fmt"

	"github.com/go-redis/redis/v8"
)

type Redis struct {
    Addr     string
    Password string
    DB       int
}


func main() {
    //创建一个新的Redis客户端
    rdb := redis.NewClient(&redis.Options{
        Addr: "localhost:9998",
        Password: "lovengame",
        DB: 0,
    })

    //使用ping测试连接
    pong, err := rdb.Ping(context.Background()).Result()
    rdb.HSet(context.Background(), "key", "field", "value")
    if err != nil {
        fmt.Println("redis connect failed")
        return
    }

    fmt.Println(pong)

    //关闭连接
    defer rdb.Close()
}
