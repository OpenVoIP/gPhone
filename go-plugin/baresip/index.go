package baresip

import (
	"fmt"
	"time"

	"github.com/OpenVoIP/baresip-go/binding"
	"github.com/OpenVoIP/baresip-go/ctrltcp"
	flutter "github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/go-flutter/plugin"
)

const methodChannelName = "tqcenglish.flutter.dev/baresip-method"
const eventChannelName = "tqcenglish.flutter.dev/baresip-event"

// PluginInfo 插件信息
type PluginInfo struct {
	stop chan bool
}

var _ flutter.Plugin = &PluginInfo{} // compile-time type check

//InitPlugin inits
func (p *PluginInfo) InitPlugin(messenger plugin.BinaryMessenger) error {
	methodChannel := plugin.NewMethodChannel(messenger, methodChannelName, plugin.StandardMethodCodec{})
	methodChannel.HandleFunc("hangup", p.hangup)
	methodChannel.HandleFunc("dial", p.dial)
	methodChannel.HandleFunc("answer", p.answer)

	eventChannel := plugin.NewEventChannel(messenger, eventChannelName, plugin.StandardMethodCodec{})
	eventChannel.Handle(p)

	//init
	p.stop = make(chan bool, 1)

	go binding.Start()

	return nil // no error
}

// scan 处理
func (p *PluginInfo) hangup(arguments interface{}) (reply interface{}, err error) {
	fmt.Print("hangup")
	binding.UAHangup()
	return nil, nil
}

// scan 处理
func (p *PluginInfo) dial(arguments interface{}) (reply interface{}, err error) {
	binding.UAConnect(arguments.(string))
	return nil, nil
}

// scan 处理
func (p *PluginInfo) answer(arguments interface{}) (reply interface{}, err error) {
	binding.UAAnswer()
	return nil, nil
}

//OnListen listen
func (p *PluginInfo) OnListen(arguments interface{}, sink *plugin.EventSink) {
	time.AfterFunc(3*time.Second, func() {
		// fmt.Println("建立 tcp 连接")
		go ctrltcp.GetConn()
	})
	time.AfterFunc(8*time.Second, func() {
		go ctrltcp.EventHandle(func(info ctrltcp.EventInfo) {
			// fmt.Printf("处理 tcp 数据 %+v\n", info)
			data := map[interface{}]interface{}{
				"type":            info.Type,
				"direction":       info.Direction,
				"peerdisplayname": info.Peerdisplayname,
			}
			sink.Success(data)
		})
	})

}

//OnCancel cancel
func (p *PluginInfo) OnCancel(arguments interface{}) {
	p.stop <- true
}
