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

	/* The main run-loop can be stopped now */
	re_cancel();
}

static void ua_event_handler(struct ua *ua, enum ua_event ev,
							 struct call *call, const char *prm, void *arg)
{
	re_printf("ua event: %s\n", uag_event_str(ev));
}

int main(int argc, char *argv[])
{
	int err;

	err = libre_init();
	if (err)
		goto out;

	err = conf_configure();
	if (err)
	{
		warning("main: configure failed: %m\n", err);
		goto out;
	}

	/*
	 * Initialise the top-level baresip struct, must be
	 * done AFTER configuration is complete.
	 */
	err = baresip_init(conf_config());
	if (err)
	{
		warning("main: baresip init failed (%m)\n", err);
		goto out;
	}

	/* Initialise User Agents */
	err = ua_init("baresip v" BARESIP_VERSION " (" ARCH "/" OS ")",
				  true, true, true);
	if (err)
		goto out;

	uag_set_exit_handler(ua_exit_handler, NULL);

	uag_event_register(ua_event_handler, NULL);

	/* Load modules */
	err = conf_modules();
	if (err)
		goto out;

	/* Main loop */
	err = re_main(signal_handler);

out:
	if (err)
		ua_stop_all(true);

	ua_close();
	module_app_unload();
	conf_close();

	baresip_close();

	/* NOTE: modules must be unloaded after all application
	 *       activity has stopped.
	 */
	debug("main: unloading modules..\n");
	mod_close();

	libre_close();

	/* Check for memory leaks */
	tmr_debug();
	mem_debug();

	return err;
}
