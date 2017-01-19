import "mod_draw";
import "mod_key";
import "mod_map";
import "mod_math";
import "mod_proc";
import "mod_grproc";
import "mod_screen";
import "mod_string";
import "mod_text";
import "mod_file";
import "mod_video";
import "mod_debug";
import "mod_say";
import "mod_sound";
import "mod_wm";
import "mod_rand";
import "mod_path";
import "mod_dir";

CONST
	SCREEN_X = 640;
	SCREEN_Y = 480;
	SCREEN_D = 16;
END

GLOBAL

	int fullscreen = false;

	int desktop_x, desktop_y;
	
	int window1, button1, stepper = 5;
	
	int window2, button2, button3;
	
	int window3;
	
	int button;
	
	string archivo = "";
	
END

//include "minigui.lib";

include "prg/gui-globals.prg";
include "prg/gui-funciones.prg";
include "gui-control-cursor.prg";
include "gui-control-window.prg";
include "gui-control-button.prg";
include "gui-control-textbox.prg";
include "gui-control-label.prg";
include "gui-control-dirlist.prg";
include "gui-control-stepper.prg";


BEGIN

	// inicializo video
	set_fps(60,0);
	get_desktop_size(&desktop_x, &desktop_y);

	if ( fullscreen )
		// escalo a la resolucion del monitor
		scale_resolution = desktop_x * 10000 + desktop_y;
		set_mode(SCREEN_X, SCREEN_Y, SCREEN_D, mode_fullscreen + MODE_WAITVSYNC);
	else
		// centro la ventana en la pantalla
		set_mode(SCREEN_X, SCREEN_Y, SCREEN_D, mode_window + MODE_WAITVSYNC);
		set_window_pos(desktop_x/2 - SCREEN_X/2, desktop_y/2 - SCREEN_Y/2);
	end
	
	// muestro variables en pantalla
	write_var(0,0,0,0,fps);
	write_var(0,0,20,0,minigui.lclick);
	write_var(0,0,30,0,minigui.rclick);
	write_var(0,0,40,0,minigui.dbclick);
	
	write_var(0,0,60,0,minigui.hover_id);
	write_var(0,0,70,0,minigui.active_id);
	
	// inicio la gui
	gui_start(16, rgb(20, 20, 20), rgb(10, 50, 200), rgb(10, 100, 200), rgb(200, 200, 200));
	gui_cursor("png/cursor.png");
	
	// creo ventana A
	window1 = gui_window(320, 150, 200, 200, "Ventana A", true);
	gui_button(320, 100, 100, 60, window1, "Boton", &button1);
	gui_stepper(320, 160, 50, 24, window1, 1, 10, 1, &stepper);
	
	// creo ventana B
	window2 = gui_window(200, 150, 200, 300, "Ventana B", true);
	gui_button(200+50, 280, 80, 30, window2, "Boton", &button1);
	gui_button(200-50, 280, 80, 30, window2, "Boton", &button1);
	gui_dirlist(200, 150, 190, 200, window2, "prg/*", &archivo);

	// creo ventana C
	window3 = gui_window(350, 350, 200, 150, "Ventana C", true);
	
	//creo botones sueltos
	gui_button(520, 300, 100, 30, NULL, "Boton Suelto", &button);
	
	// main loop
	loop
	
		if ( key ( _esc ) or exit_status )
			exit();
		end

		frame;
		
	end
END
