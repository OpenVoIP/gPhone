package baresip

import (
	"fmt"

	baresip "github.com/OpenVoIP/baresip-go"
	flutter "github.com/go-flutter-desktop/go-flutter"
	"github.com/go-flutter-desktop/go-flutter/plugin"
)

const channelName = "tqcenglish.flutter.dev/baresip"

// PluginInfo 插件信息
type PluginInfo struct {
	stop chan bool
}

var _ flutter.Plugin = &PluginInfo{} // compile-time type check

//InitPlugin inits
func (p *PluginInfo) InitPlugin(messenger plugin.BinaryMessenger) error {
	channel := plugin.NewMethodChannel(messenger, channelName, plugin.StandardMethodCodec{})
	channel.HandleFunc("start_scan", p.scan)

	//init
	p.stop = make(chan bool, 1)

	go baresip.Start()

	return nil // no error
}

// scan 处理
func (p *PluginInfo) scan(arguments interface{}) (reply interface{}, err error) {
	fmt.Print("scan")
	return nil, nil
}
