//------------------------------------------------------------------------------------------------------------------
//
//	MINIGUI v 1.2
//	
//------------------------------------------------------------------------------------------------------------------

/*
	CHANGELOG

[v1.2]
 - Se mejora la prioridad y profundidad de ventanas
 - Se mejora la activacion y desactivacion de ventanas

[v1.1]

 - agregado gui_stepper()
 - se mueven y renombran variables

[v1.0]

 - Release inicial


*/

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
//------------------------------------------------------------------------------------------------------------------
//	GUI_BUTTON
//
//	boton basico
//------------------------------------------------------------------------------------------------------------------
PROCESS gui_button(int x, int y, int width, int height, int container_id, string caption, int pointer return_value)

PRIVATE

	int state;
	
	int graph_normal, graph_hover, graph_active;
	
	int has_container;
	
	int pos_x, pos_y;
	
END

BEGIN

	// creo los graficos
	graph_normal 	= gui_constructor(width, height, GUI_CLASS_BUTTON, GUI_STATE_NORMAL, caption);
	graph_hover 	= gui_constructor(width, height, GUI_CLASS_BUTTON, GUI_STATE_HOVER, caption);
	graph_active 	= gui_constructor(width, height, GUI_CLASS_BUTTON, GUI_STATE_ACTIVE, caption);
	
	// obtengo la posicion respecto al container
	if ( exists(container_id) )
		has_container = true;
		pos_x = x - container_id.x;
		pos_y = y - container_id.y;
		priority = container_id.priority - 1;	// se actualiza justo despues que su padre
	end
	
	LOOP
		
		if ( has_container )
			IF (exists (container_id) )
				// actualizo la posicion en cada frame respecto al container
				x = container_id.x + pos_x;
				y = container_id.y + pos_y;
				z = container_id.z -1;
			ELSE
				// elimino el boton si el container dejo de existir
				signal(id,S_KILL);
			END
		end
		
		// compruebo estados del boton
		// ( boton solo funciona si el container esta activado )
		if ( is_hover(x, y, width, height ) )
		
			// estados
			if ( mouse.left )
				state = GUI_STATE_ACTIVE;
				graph = graph_active;
			else
				state = GUI_STATE_HOVER;
				graph = graph_hover;
			end
			
			// activo el boton
			if ( minigui.lclick )
				* return_value = true;
			else
				* return_value = false;
			end
		
		else
		
			state = GUI_STATE_NORMAL;
			graph = graph_normal;
			
		end
		
		frame;
		
	END
	
ONEXIT

	// descargo los graficos creados
	unload_map(0, graph_normal);
	unload_map(0, graph_hover);
	unload_map(0, graph_active);

END
//------------------------------------------------------------------------------------------------------------------
//	GUI_CURSOR
//
//	cursor con soporte de eventos
//------------------------------------------------------------------------------------------------------------------
PROCESS gui_cursor(string png)

PRIVATE
	int left_was_pressed;
	int right_was_pressed;
	
	int double_counter;
	int double_time = 20;	// frames entre un click y el siguiente para ser doble
	
	int last_x, last_y;		// posicion del ultimo click
END

BEGIN

	// inicializo la gui si corresponde
	if ( minigui.initialized == false )
		gui_start(16, rgb(20, 20, 20), rgb(10, 90, 220), rgb(40, 120, 240), rgb(100, 100, 100));
	end

	//set_center(minigui.fpg, 1, 2, 2);
	//file = minigui.fpg;
	
	graph = load_png(png);
	z = -300;
	priority = 3;
	
	// ignoro el dormir
	signal_action(s_freeze,s_ign);
	
	LOOP
	
		// actualizo posicion
		x = mouse.x;
		y = mouse.y;
			
		// boton izquierdo presionado
		if ( mouse.left )
		
			// si es el primer frame
			if ( !left_was_pressed )
			
				left_was_pressed = true;
				
				last_x = mouse.x; last_y = mouse.y;
				
				// informo el evento ldown
				minigui.ldown = true;
				
				// si paso poco tiempo, es doble click
				if ( double_counter < double_time )
				
					double_counter = double_time;
					
					// informo el evento dbclick
					minigui.dbclick = true;
				
				// sino, reinicia el tiempo para el proximo
				else
				
					double_counter = 0;
					
				end
			
			end
		
		// boton derecho presionado
		elseif ( mouse.right )
		
			// si es el primer frame
			if ( !right_was_pressed )
			
				right_was_pressed = true;
				
				last_x = mouse.x; last_y = mouse.y;
				
				// informo el evento rdown
				minigui.rdown = true;
				
			end
			
		// ningun boton presionado
		else
		
			// si recien se solto el boton izquierdo
			if ( left_was_pressed )
			
				left_was_pressed = false;
				
				// informo el evento lup
				minigui.lup = true;
				
				//si no se movio ni es doble, es click
				if ( last_x == mouse.x && last_y == mouse.y /*AND NOT double_was_pressed*/)
					
					// informo el evento lclick
					minigui.lclick = true;
					
				end
			
			// si recien se solto el boton derecho
			elseif ( right_was_pressed )

				right_was_pressed = false;
				
				// informo el evento rup
				minigui.rup = true;
				
				//si no se movio, es click
				if ( last_x == mouse.x && last_y == mouse.y )
				
					// informo el evento rclick
					minigui.rclick = true;
					
				end
			
			end
		
		end
		
		frame;
		
		// reinicio todos los eventos
		minigui.lclick 	= false;
		minigui.rclick 	= false;
		minigui.dbclick	= false;
		minigui.ldown 	= false;
		minigui.lup 	= false;
		minigui.rdown 	= false;
		minigui.rup 	= false;
		
		// contador de tiempo entre clicks
		double_counter++;
		
	END

END
//------------------------------------------------------------------------------------------------------------------
//	GUI_DIRLIST
//
//	muestra uan lista con los archivos del directorio
//	falta mejorar y optimizar!!!
//------------------------------------------------------------------------------------------------------------------
PROCESS gui_dirlist(int x, int y, int width, int height, int container_id, string dir, string pointer selected_file)

PRIVATE

	//int state = GUI_STATE_ACTIVE;
	
	int graph_normal;
	
	int has_container;
	
	// botones
	int previous_page, next_page;
	
	int total, visible_first, visible_last = 18, visible_max;
	
	string visible_status;
	int visible_status_id;
	
	int pos_x, pos_y;
	
	// mouse
	int relative_x, relative_y;
	
	// archivos
	string archivos[GUI_FILES_MAX];
	string archivo_actual;
	int textos_id[GUI_FILES_MAX];

	int i;
	
	int seleccion;
	
	int actualizar_textos = true;
	
	int key_lock;

END

BEGIN

	// creo el grafico
	graph_normal = gui_constructor(width, height, GUI_CLASS_DIRLIST, GUI_STATE_NORMAL, NULL);
	
	z = 10;
	graph = graph_normal;
	
	// obtengo la posicion respecto al container
	if ( exists(container_id) )
		has_container = true;
		pos_x = x - container_id.x;
		pos_y = y - container_id.y;
		priority = container_id.priority - 1;	// se actualiza justo despues que su padre
	end

	// creo botones
	gui_button(x - width/2 + 10, y + height/2 - minigui.title_height/2, 20, minigui.title_height, id, "<<", &previous_page );
	gui_button(x + width/2 - 10, y + height/2 - minigui.title_height/2, 20, minigui.title_height, id, ">>", &next_page );
	
	// obtengo todos los archivos del directorio
	while ( (archivo_actual = glob( dir ) ) != "" )
	
		// ignoro directorios padres
		if ( fileinfo.directory OR fileinfo.hidden )
			continue;
		end
		
		// evito desbordamient
		if (i > GUI_FILES_MAX)
			break;
		end
		
		//say("archivos["+i+"]	"+archivo_actual);
		
		// agrego el archivo a la lista
		archivos[i] = archivo_actual;
		i++;
		
	end
	// reseteo el glob
	glob("");
	
	//cuento el total de archivos
	total = i;
	
	//calculo el maximo de textos, y los limites
	visible_max = (height - minigui.title_height - 2) / 15;	// calculo el maximo dependiendo el tamaño del contenedor
	if ( visible_max > total )	// limito el maximo de archivos visibles
		visible_max = total;
	end
	visible_first = 0;
	visible_last = visible_first + visible_max;
	
	// escribo los textos
	// para que despues se puedan borrar y volver a escribir
	text_z = z-2;
	visible_status_id = write_string(0, x, y + height/2 - minigui.title_height/2, 4, &visible_status);
	for(i=0; i<visible_max; i++)
		textos_id[i] = write_string(0,0,0,0,&archivo_actual);
	end
	text_z = -256;
	
	//creo el cursor
	gui_dirlist_cursor(width, height, &seleccion);
	
	loop
	
		if ( has_container )
			IF (exists (container_id) )
				// actualizo la posicion en cada frame respecto al container
				x = container_id.x + pos_x;
				y = container_id.y + pos_y;
				z = container_id.z -1;
				
				actualizar_textos = true;
				
			ELSE
				// elimino el boton si el container dejo de existir
				signal(id,S_KILL_TREE);
			END
		end

		visible_status = (visible_first+1) + "-" + visible_last + "/" + total;
		
		// muevo el cursor, y cambio la seleccion
		if ( key (_up) and not key_lock)
			key_lock = true;
			seleccion--;
			if ( seleccion < 0 )
				seleccion = 0;
				
				visible_first--;
				visible_last--;
				actualizar_textos = true;
				
			end
		elseif ( key (_down) and not key_lock)
			key_lock = true;
			seleccion++;
			
			// limite
			if ( seleccion > visible_max-1 )
				seleccion = visible_max-1;
				
				visible_first++;
				visible_last++;
				actualizar_textos = true;
				
			end
		elif (not key (_up) and not key (_down) and key_lock)
			key_lock = false;
		end
		
		
		//botones de paginas
		if ( previous_page )
		
			visible_first -= visible_max;
			visible_last -= visible_max;
			actualizar_textos = true;
			
		elseif ( next_page )
		
			visible_first += visible_max;
			visible_last += visible_max;
			actualizar_textos = true;
			
		end
		
		// calculo los limites
		if ( visible_last > total )
		
			visible_last = total;
			visible_first = visible_last - visible_max;
			
		elseif (visible_first < 0)
		
			visible_first = 0;
			visible_last = visible_first + visible_max;
			
		end
		
		// actualizo la lista visible
		if ( actualizar_textos )		
			actualizar_textos = false;

			text_z = z -2;	// escribo arriba del cursor tambien
			
			// borro y escribo los textos
			delete_text(visible_status_id);
			visible_status_id = write_string(0, x, y + height/2 - minigui.title_height/2, 4, &visible_status);
			for (i=0; i<visible_max; i++)
				delete_text(textos_id[i]);
				textos_id[i] = write_string (0, x - width/2 + 20, y - height/2 + 10 + i*15, 3, &archivos[visible_first + i]);
			end
			
			// reestablezco la Z
			text_z = -256;
			
		end
		
		// selecciono con el cursor del mouse
		if ( is_hover(x, y, width, height) and minigui.ldown )
		
			relative_x = mouse.x - (x-width/2);
			relative_y = mouse.y - (y-height/2);
			
			//say("click: " + relative_x + "," + relative_y + " (" + (relative_y+1/15) + ")");
			
			// si no me paso, cambio la seleccion
			if ( relative_y/15 < visible_max )
				seleccion = relative_y / 15;
			end
		
		end
		
		// seleccion de archivo
		selected_file = archivos[visible_first + seleccion];
		
		if ( key (_space) )
			say(*selected_file);
		end
		
		frame;
		
	end
	
ONEXIT

	unload_map(0, graph_normal);

	// elimino los textos
	delete_text(visible_status_id);
	for(i=0; i<visible_max; i++)
		delete_text( textos_id[i] );
	end
	
END

//------------------------------------------------------------------------------------------------------------------
PROCESS gui_dirlist_cursor(int width, int height, int pointer seleccion)

PRIVATE

	int graph_id;
	
END

BEGIN

	graph_id = map_new(width-2, 15, 16);
	
	drawing_color(minigui.hover_bg_color);
	drawing_map(0, graph_id);
	
	draw_box(0, 0, width-2, 15);
	
	graph = graph_id;
		
	loop
	
		x = father.x;
		y = 1 + 15/2 + (father.y - height/2) + *seleccion * 15;
		z = father.z - 1;
	
		frame;
		
	end
ONEXIT

	unload_map(0, graph_id);

END
//------------------------------------------------------------------------------------------------------------------
//	GUI_LABEL
//
//	mestra un texto
//------------------------------------------------------------------------------------------------------------------
PROCESS gui_label(int x, int y, int container_id, string caption)

PRIVATE

	int id_caption;
	
	int pos_x, pos_y;
	
	string texto;
END

BEGIN
	
	
	//escribo el texto
	id_caption = write_string(0, x, y, 4, &texto);
	
	// obtengo la posicion inicial respecto al container
	if ( exists(container_id) )
		pos_x = x - container_id.x;
		pos_y = y - container_id.y;
	end
	
	LOOP
		
		// actualizo la posicion en cada frame respecto al container
		if ( exists (container_id) )
			x = container_id.x + pos_x;
			y = container_id.y + pos_y;
			z = container_id.z -1;
			move_text(id_caption, x, y);
		end
		
		texto = caption;
		
		frame;
		
	END

ONEXIT

	delete_text(id_caption);
	
END
//------------------------------------------------------------------------------------------------------------------
//	GUI_STEPPER
//
//	Muestra un numeric stepper
//------------------------------------------------------------------------------------------------------------------
PROCESS gui_stepper(int x, int y, int width, int height, int container_id, int min, int max, int steps, int pointer return_value)

PRIVATE

	int graph_normal;

	int pos_x, pos_y;
	
	int has_container;
	
	int button_increase, button_decrease;
	
	int text_id;
END

BEGIN

	// compruebo el ancho minimo
	IF ( width < 40 ) width = 40; END
	
	//creo los graficos
	graph_normal = gui_constructor(width, height, GUI_CLASS_TEXTBOX, GUI_STATE_NORMAL, NULL);
	graph = graph_normal;

	// creo los botones
	gui_button(x + width/2 - 10, y - height/4, 20, height/2, id, "+", &button_increase );
	gui_button(x + width/2 - 10, y + height/4, 20, height/2, id, "-", &button_decrease );

	// obtengo la posicion inicial respecto al container
	if ( exists(container_id) )
		has_container = true;
		pos_x = x - container_id.x;
		pos_y = y - container_id.y;
		priority = container_id.priority - 1;	// se actualiza justo despues que su padre
	end

	LOOP

		if ( has_container )
			IF (exists (container_id) )
				// actualizo la posicion en cada frame respecto al container
				x = container_id.x + pos_x;
				y = container_id.y + pos_y;
				z = container_id.z - 1;
			ELSE
				// elimino el boton si el container dejo de existir
				signal(id, S_KILL_TREE);
			END
		end
		
		//cambio los valores 
		IF ( button_increase && *return_value < max )
			*return_value += steps;
		END
		
		IF ( button_decrease && *return_value > min )
			*return_value -= steps;
		END
		
		// escribo los textos
		text_z = z - 1;
		text_id = write(0, x + width/2 - 25, y, 5, *return_value);
		text_z = -256;

	
		FRAME;
		
		//borro los textos
		delete_text(text_id);
		
	END

ONEXIT

	// borro los textos al morir
	delete_text(text_id);
	
END
//------------------------------------------------------------------------------------------------------------------
//	GUI_TEXTBOX
//
//	permite ingreso basico de texto
//	falta mejorar!
//------------------------------------------------------------------------------------------------------------------
PROCESS gui_textbox(int x, int y, int width, int height, int container_id, string *string_value)

PRIVATE

	int state = GUI_STATE_NORMAL;
	
	int graph_normal;
	
	int cursor, cursor_timer;
	
	string working_value, display_value;
	
	byte last_ascii; // ultima tecla presionada
	
	int pos_x, pos_y;
	
	int display_id;

END

BEGIN

	// creo el grafico y se lo asigno
	graph_normal = gui_constructor(width, height, GUI_CLASS_TEXTBOX, GUI_STATE_NORMAL, NULL);
	graph = graph_normal;
	
	working_value = string_value[0];

	// obtengo la posicion inicial respecto al container
	if ( exists(container_id) )
		pos_x = x - container_id.x;
		pos_y = y - container_id.y;
	end
	
	// escribo el texto
	text_z = z-2;
	display_id = write_string(0, x - width/2 + 5, y, 3, &display_value);
	text_z = -256;

	LOOP
	
		// actualizo la posicion en cada frame respecto al container
		if ( exists (container_id) )
			x = container_id.x + pos_x;
			y = container_id.y + pos_y;
			z = container_id.z -1;
		end

		
		// compruebo estado
		if ( minigui.lclick )
		
			if ( is_hover(x,y,width, height) )
				state = GUI_STATE_ACTIVE;
			else
				state = GUI_STATE_NORMAL;
			end
		
		end
		
		// ejecuto acciones de acuerdo al estado
		if ( state == GUI_STATE_ACTIVE )
		
			// parpadeo del cursor
			if ( cursor_timer > 20 )
				cursor_timer = 0;
				cursor = !cursor;
			end
			
			// edicion de texto
			
			if ( ascii != 0 && ascii != last_ascii  )
			
				switch(ascii) // handle input
				
					case 8: //backspace
						working_value = substr(working_value, 0, len(working_value)-1);
					end
					
					case 13: //enter
						state = GUI_STATE_NORMAL;
					end
					
					case 27: //escape
						// no hacer nada
					end
					
					default: //addkey
						working_value += chr(ascii);
					end
					
				end
				
			end
			
			last_ascii = ascii;
			
			
			
		ELSEIF ( state == GUI_STATE_NORMAL )
		
			cursor = false;
			
		END
		
		// actualizo el valor
		*string_value = working_value;
		
		
		// dibujo el cursor (fuera de los estados)
		if ( cursor )
			display_value = working_value + "|";
		else
			display_value = working_value;
		end
		
		// actualizo el texto
		text_z = z-2;
		delete_text(display_id);
		display_id = write_string(0, x - width/2 + 5, y, 3, &display_value);
		text_z = -256;
		
		frame;
		
		cursor_timer++;
		
	END
ONEXIT

	unload_map(0, graph_normal);
	delete_text(display_id);
	
END
//------------------------------------------------------------------------------------------------------------------
//	GUI_WINDOW
//
//	ventana comun, sirve como contenedor
//------------------------------------------------------------------------------------------------------------------
PROCESS gui_window(int x, int y, int width, int height, string title, int is_draggable )

PRIVATE

	// estado inicial de la ventana
	int state = GUI_STATE_NORMAL;
	
	int button_close;
	
	int is_draggin = false;
	int drag_offset_x, drag_offset_y;
	
	// graficos de los distintos estados
	int graph_normal;
	int graph_active;
	
	int initial_z;
	
END

BEGIN
	
	// creo los graficos
	graph_normal = gui_constructor(width, height, GUI_CLASS_WINDOW, GUI_STATE_NORMAL, title);
	graph_active  = gui_constructor(width, height, GUI_CLASS_WINDOW, GUI_STATE_ACTIVE, title);
	
	//boton de cerrar
	gui_button(x + width/2 - minigui.title_height/2, y - height/2 + minigui.title_height/2, minigui.title_height, minigui.title_height+1, id, "x", &button_close);

	// conteo de ventanas
	minigui.win_count++;
	
	// establezco profundidad
	initial_z = minigui.win_count * 5;
	
	z = initial_z + 25;

	// la primera ventana creada tiene mayor prioridad
	priority = 20 - minigui.win_count;
	
	minigui.active_id = id;
	
	LOOP
	
		// cierro la ventana
		if (button_close)
		
			// la deselecciono al morir
			IF ( minigui.active_id == id )
				minigui.hover_id = 0;
				minigui.active_id = 0;
			END
		
			signal(id, s_kill_tree);
		end
		
		// compruebo si esta sobre la ventana
		if ( is_hover(x, y, width, height) )
		
			IF ( !minigui.hover_id OR minigui.hover_z > z )
				minigui.hover_id = id;
				minigui.hover_z = z;
			END
		
			// reactivo la ventana al hacer click
			if ( minigui.ldown )
			
				IF ( minigui.hover_id == id )
					minigui.active_id = id;
				END
				
			end
		
			// compruebo si esta sobre la barra de titulo
			if ( is_hover(x, y-height/2 + minigui.title_height/2, width, minigui.title_height ) )
			
				// compruebo si se puede arrastrar la ventana
				if ( minigui.drag_id == ID OR !minigui.drag_id )
					is_draggable = true;
				else
					is_draggable = false;
				end
				
				
				// activa arrastre de la ventana
				if ( is_draggable )
				
					if ( mouse.left )
					
						minigui.drag_id = id;
					
						is_draggin ++;
						
						// guarda la posicion del primer frame
						if ( is_draggin == 1)
							drag_offset_x = x - mouse.x;
							drag_offset_y = y - mouse.y;
						end
						
					else
						
						minigui.drag_id = 0;
						
					end
				end

			end
				
		// si no esta sobre la ventana
		else
		
			IF ( minigui.hover_id == id )
				minigui.hover_id = 0;
			END
		
			// desactiva la ventana
			IF ( minigui.ldown )
			
				// cambia a estado desactivado
				IF ( minigui.active_id == ID )
					minigui.active_id = 0;
				END
			END
			
		end
		
		// si no se solto el boton, sigue arrastrando
		if ( is_draggin and not minigui.lup )
			
			x = mouse.x + drag_offset_x;
			y = mouse.y + drag_offset_y;
			
			// calculo los limites de la pantalla
			if ( x-width/2 < 0 ) x = width/2;end
			if ( y-height/2 < 0 ) y = height/2;end
			if ( x+width/2 > minigui.screen_res_x ) x = minigui.screen_res_x-width/2;end
			if ( y+height/2 > minigui.screen_res_y ) y = minigui.screen_res_y-height/2;end
		
		// suelta el boton
		else
		
			// desactiva el arrastre
			is_draggin = false;
			
		end
		
		// cambio el grafico de acuerdo al estado
		if ( minigui.active_id == id )
			graph = graph_active;
			z = initial_z - 25;
		else
			graph = graph_normal;
			z = initial_z + 25;
		end
	
		frame;
		
	END
	
ONEXIT

	map_unload(0, graph_normal);
	map_unload(0, graph_active);

END
