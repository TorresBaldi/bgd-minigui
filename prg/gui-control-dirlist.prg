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
