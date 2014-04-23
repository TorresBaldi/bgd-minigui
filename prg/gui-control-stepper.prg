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
