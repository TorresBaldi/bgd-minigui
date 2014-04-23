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
