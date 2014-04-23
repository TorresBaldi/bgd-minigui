//------------------------------------------------------------------------------------------------------------------
//	gui-globals
//------------------------------------------------------------------------------------------------------------------

import "mod_draw";
import "mod_key";
import "mod_map";
import "mod_proc";
import "mod_grproc";
import "mod_screen";
import "mod_string";
import "mod_text";
import "mod_dir";
import "mod_file";
import "mod_video";
import "mod_debug";
import "mod_say";

CONST

	// clases de widgets
	GUI_CLASS_WINDOW	= 0;
	GUI_CLASS_BUTTON	= 1;
	GUI_CLASS_TEXTBOX	= 2;
	GUI_CLASS_DIRLIST	= 3;
	
	// estados
	GUI_STATE_NORMAL 	= 0;
	GUI_STATE_HOVER 	= 1;
	GUI_STATE_ACTIVE 	= 2;
	
	// cantidad maxima de archivos que leer de una carpeta y/o mostrar en la lista
	GUI_FILES_MAX = 100;

END

GLOBAL

	STRUCT minigui
		
		// eventos del mouse
		int lclick;		// mouse left click
		int rclick;		// mouse right click
		int dbclick;	// mouse double click
		int ldown;	// left button down (apretado)
		int lup;	// delft button up (soltado)
		int rdown;	// right button down (apretado)
		int rup;	// right button up (soltado)
		
		// manejo de ventanas
		int win_count;	// contador de ventanas
		int drag_id;
		int hover_id;
		int hover_z;
		int active_id;
	
		// opciones
		int initialized;
		int screen_res_x;
		int screen_res_y;
		int screen_depth;
		int title_height;	// altura del titulo de una ventana

		// colores
		dword normal_bg_color;
		dword hover_bg_color;
		dword active_bg_color;
		dword border_color;
	END
	
END
