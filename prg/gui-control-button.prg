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
