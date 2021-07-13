import 'dart:ffi' as ffi;

var dl = ffi.DynamicLibrary.executable();

typedef NativeAppSign = ffi.Void Function();
typedef DartAppSign = void Function();
var startApp = dl.lookupFunction<NativeAppSign, DartAppSign>("start_app");

typedef NativeAppCallSign = ffi.Void Function(ffi.Pointer);
typedef DartAppCallSign = void Function(ffi.Pointer);
var callApp = dl.lookupFunction<NativeAppCallSign, DartAppCallSign>("call_app");
