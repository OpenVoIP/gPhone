package main

import (
	"baresip"

	"github.com/go-flutter-desktop/go-flutter"
)

var options = []flutter.Option{
	flutter.WindowInitialDimensions(400, 600),
	flutter.AddPlugin(&baresip.PluginInfo{}),
}
