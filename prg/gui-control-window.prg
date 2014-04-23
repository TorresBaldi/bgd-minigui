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
