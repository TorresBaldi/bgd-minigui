//------------------------------------------------------------------------------------------------------------------
//	gui-funciones
//------------------------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------------------------
//	GUI_START
//	Inicializa los valores de la gui
//------------------------------------------------------------------------------------------------------------------
FUNCTION gui_start(int title_height, dword color_normal, dword color_hover, dword color_active, dword color_border)

BEGIN
	
	//obtengo la resolucion del juego
	minigui.screen_res_x = graphic_info(0,0,G_WIDTH);
	minigui.screen_res_y = graphic_info(0,0,G_HEIGHT);
	minigui.screen_depth = graphic_info(0,0,G_DEPTH);
	
	// el alto del titulo de la ventana
	minigui.title_height = title_height;
	
	// colores
	minigui.normal_bg_color	= color_normal;
	minigui.hover_bg_color	= color_hover;
	minigui.active_bg_color	= color_active;
	minigui.border_color	= color_border;
	
	//informo que se inicializo correctamente
	minigui.initialized = true;

END

//------------------------------------------------------------------------------------------------------------------
//	CONSTRUCTOR
//	crea los graficos usados por botones y controles
//	recibe datos del objeto, devuelve id del nuevo mapa creado
//------------------------------------------------------------------------------------------------------------------
FUNCTION int gui_constructor(int width, int height, int class, int state, string caption)
PRIVATE

	int i, j;
	
	int graph_id;
	int aux_id;

END

BEGIN
	
	// creo un grafico nuevo
	graph_id = map_new(width, height, minigui.screen_depth);
	drawing_map(0, graph_id);

	// color del fondo
	switch ( state )
	
		case GUI_STATE_NORMAL:
			drawing_color( minigui.normal_bg_color );
		end
		
		case GUI_STATE_HOVER:
			drawing_color( minigui.hover_bg_color );
		end
		
		case GUI_STATE_ACTIVE:
			drawing_color( minigui.active_bg_color );
		end
		
	end
	//dibujo el fondo
	draw_box(1, 1, width-2, height-2 );
	
	// dibujo contorno
	drawing_color( minigui.border_color );
	draw_line(1, height-1, width-2, height-1);
	draw_line(1, 0, width-2, 0);
	draw_line(0, 1, 0, height-2);
	draw_line(width-1, 1, width-1, height-2);
	
	// dibujos especiales
	switch ( class )
	
		// cambio el color de fondo y dibujo titulo
		case GUI_CLASS_WINDOW:
		
			// color de fondo
			draw_line(1, minigui.title_height, width-2, minigui.title_height);
			drawing_color( minigui.normal_bg_color );
			draw_box(1, minigui.title_height+1, width-2, height-2 );
			
			// titulo
			aux_id = write_in_map(0, caption, 4);
			map_put(0, graph_id, aux_id, width/2, minigui.title_height/2);
			unload_map(0, aux_id);
			
		end

		// dibujo la linea inferior
		case GUI_CLASS_DIRLIST:
			draw_line(1, height - minigui.title_height, width-2, height - minigui.title_height);
		end

		// dibuja etiquetas de texto
		case GUI_CLASS_BUTTON:
			aux_id = write_in_map(0, caption, 4);
			map_put(0, graph_id, aux_id, width/2, height/2);
			unload_map(0, aux_id);
		end
		
	end
	
	return graph_id;

END

//------------------------------------------------------------------------------------------------------------------
//	IS_HOVER
//	comprueba si el mouse esta dentro del boton
//------------------------------------------------------------------------------------------------------------------
FUNCTION int is_hover(int x, y, int width, int height)
BEGIN

	if ( mouse.x < x-width/2 OR mouse.x > x+width/2
	  OR mouse.y < y-height/2 OR mouse.y > y+height/2	)
	
		return false;
		
	else
	
		return true;
		
	end

END
