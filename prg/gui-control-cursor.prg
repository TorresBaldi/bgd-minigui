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
