package baresip

/*
#cgo CFLAGS: -I/usr/local/include/re -I/usr/local/include/baresip
#cgo LDFLAGS: -lbaresip -lrem -lre

#include <stdint.h>
#include <stdlib.h>
#include <re.h>
#include <baresip.h>


static void signal_handler(int sig)
{
	static bool term = false;

	if (term)
	{
		mod_close();
		exit(0);
	}

	term = true;

	info("terminated by signal %d\n", sig);

	ua_stop_all(false);
}

static void ua_exit_handler(void *arg)
{
	(void)arg;
	debug("ua exited -- stopping main runloop\n");

	re_cancel();
}

static void ua_event_handler(struct ua *ua, enum ua_event ev,struct call *call, const char *prm, void *arg)
{
	re_printf("ua event: %s\n", uag_event_str(ev));
}

int mainLoop(){
	return re_main(signal_handler);
}

*/
import "C"

import (
	"fmt"
	"unsafe"
)

//Start 启动
func Start() (err C.int) {
	ua := C.CString("baresip")

	err = C.libre_init()
	if err != 0 {
		goto out
	}

	err = C.conf_configure()
	if err != 0 {
		fmt.Printf("main: configure failed: %m\n", err)
		goto out
	}

	/*
	 * Initialise the top-level baresip struct, must be
	 * done AFTER configuration is complete.
	 */
	err = C.baresip_init(C.conf_config())
	if err != 0 {
		fmt.Printf("main: baresip init failed (%m)\n", err)
		goto out
	}

	/* Initialise User Agents */
	err = C.ua_init(ua, 1, 1, 1)
	defer C.free(unsafe.Pointer(ua))

	if err != 0 {
		goto out
	}

	// uag_set_exit_handler(ua_exit_handler, NULL);
	// uag_event_register(ua_event_handler, NULL);

	/* Load modules */
	err = C.conf_modules()
	if err != 0 {
		goto out
	}

	/* Main loop */
	err = C.mainLoop()

out:
	if err != 0 {
		C.ua_stop_all(1)
	}

	C.ua_close()
	C.module_app_unload()
	C.conf_close()

	C.baresip_close()

	/* NOTE: modules must be unloaded after all application
	 *       activity has stopped.
	 */
	fmt.Printf("main: unloading modules..\n")
	C.mod_close()

	C.libre_close()

	/* Check for memory leaks */
	C.tmr_debug()
	C.mem_debug()

	return err
}
