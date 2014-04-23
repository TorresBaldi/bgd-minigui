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
