try (
	destroydialog DankLowResCurtainMaker
)
catch()
global dummy_plane = undefined
global dummy_box = undefined
global dummy_cyl = undefined
global boxer = undefined
global window_cover = #()
global random_type = #()
global blackouts = #()
global persianas = #()
global cortinas = #()
global baked_blackouts = #()
global baked_persianas = #()
global baked_cortinas = #()
global cortinificador_arr = undefined
global offsetx = 0
global offsety = 0
global offsetz = 0
global out = 0
global prob = 100
global prob_blackouts = 10
global prob_persianas = 10
global prob_cortinas = 10
global processedp = 0
global cortinificacionp = 0
global type = "None"
global mode = 1
clearlistener()

rollout DankLowResCurtainMaker "Cortinificador" (
	fn create_dummys = (
		if dummy_plane == undefined do (
			Plane lengthsegs:1 widthsegs:1 length:1 width:1 pos:[0,0,0] isselected:on
			global dummy_plane = $
			clearselection()
		)
		if dummy_box == undefined do (
			Box pos:[0,0,0] isSelected:on width:1 length:1 height:1
			global dummy_box = $
			clearselection()
		)
		if dummy_cyl == undefined do (
			Cylinder radius:1 height:1 sides:6 pos:[0,0,0] isSelected:on
			global dummy_cyl = $
			clearselection()
		)
	)	
	fn create_blackout = (
	)
		
	fn create_cortina i = (
	)
	
	fn delete_dummys = (
		try (
			delete dummy_plane
			dummy_plane = undefined
		)catch()
		try (
			delete dummy_box
			dummy_box = undefined
		) catch()
		try (
			delete dummy_cyl
			dummy_cyl = undefined
		) catch()
	)
	fn create_rando = (
		random_type = #()
		for i = 1 to prob_blackouts do (
			append random_type "Blackout"
		)
		for i = 1 to prob_persianas do (
			append random_type "Persiana"
		)
		for i = 1 to prob_cortinas do (
			append random_type "Cortina"
		)	
	)			
	fn aligner = (
		for i = 1 to window_cover.count do ( 
			ventana = cortinificador_arr[i]
			dummer = window_cover[i] 
			dummer.scale.x = abs(ventana.scale.x)
			dummer.scale.y = abs(ventana.scale.y)
			dummer.scale.z = abs(ventana.scale.z)
			dummer.rotation = ventana.rotation
			dummer.pos = ventana.center
			dummer.pos.z = ventana.max.z - ((dummer.length/2)*(abs dummer.scale[3]))
			dummer.transform = (rotateXmatrix offsetx) * dummer.transform
			dummer.transform = (rotateYmatrix offsety) * dummer.transform
			dummer.transform = (rotateZmatrix offsetz) * dummer.transform
		)
		for obj1 in window_cover do (
			in coordsys Local obj1.pos += [0,0,out]
		)
	)
	fn typer = (
		type = random_type[(random 1 (random_type.count))]
	)
	fn clearwindow_cover = (
		for i in window_cover do (
			delete i
		)
		window_cover = #()
		persianas = #()
		blackouts = #()
		cortinas = #()
		boxer = undefined
	)
	checkbutton arr_btn "Select Windows" across:2
	label wind_cnt "0"	
	spinner spn_prob "Probability" range:[1,100,100] scale:1 type:#integer 
	spinner spn_prob_blackouts "Blackouts" range:[0,10,10] scale:1 type:#integer across:2
	colorpicker blackouts_color color:[108,105,60]
	spinner spn_prob_persianas "Persianas" range:[0,10,10] scale:1 type:#integer across:2
	colorpicker persianas_color color:[40,20,2]
	spinner spn_prob_cortinas "Cortinas" range:[0,10,10] scale:1 type:#integer across:2
	colorpicker cortinas_color color:[185,170,150]
	spinner spn_x "X Offset" range:[-360,360,0] scale:90 type:#integer 
	spinner spn_y "Y Offset" range:[-360,360,0] scale:90 type:#integer 
	spinner spn_z "Z Offset" range:[-360,360,0] scale:90 type:#integer 
	spinner spn_out "Out" range:[-100,100,0] scale:1 type:#integer 
	spinner spn_mode "Mode" range:[1,6,1] scale:1 type:#integer 
	button btn "Execute"
	button process_btn "Process"
	button erase_baked "Borrar"
	label cortinificacion_lbl "No Window Covers"
	progressbar cortinificacion_bar "Progress" labelontop:true value:cortinificacionp color:(color 255 0 0) 

   fn colorize = (
	   for i in blackouts do (
		   i.wirecolor = blackouts_color.color
	   )
		for i in persianas do (
		   i.wirecolor = persianas_color.color
	   )
		for i in cortinas do (
		   i.wirecolor = cortinas_color.color
	   )
		for i in blackouts do (
		   i.wirecolor = blackouts_color.color
	   )
		for i in persianas do (
		   i.wirecolor = persianas_color.color
	   )
		for i in cortinas do (
		   i.wirecolor = cortinas_color.color
	   )
   )	   
	fn corticnt total processed = (	
			cortinificacion_bar.value = (processed*100/total)
			if cortinificacion_bar.value < 100 then ( cortinificacion_bar.color = (color 0 142 255) )
			if cortinificacion_bar.value < 99 then ( cortinificacion_bar.color = (color 13 191 0) )
			if cortinificacion_bar.value < 75 then ( cortinificacion_bar.color = (color 147 255 0) )
			if cortinificacion_bar.value < 50 then ( cortinificacion_bar.color = (color 255 232 0) )
			if cortinificacion_bar.value < 25 then ( cortinificacion_bar.color = (color 255 124 0) )
			if cortinificacion_bar.value < 15 then ( cortinificacion_bar.color = (color 255 31 0) )
			cortinificacion_lbl.text = (cortinificacion_bar.value as string + "% " + processed as string + " out of " + total as string)
	)
	
	fn cortinificar = (
		if cortinificador_arr == undefined do (
			messagebox "Select windows!"
		)
		if cortinificador_arr != undefined then (
			cortinificacion_lbl.text = "Ready to process " + ((cortinificador_arr.count) as string) + " windows."
			if cortinificador_arr.count >= 1 do (
				create_dummys()
				with redraw off (
				with undo off (
					for i in cortinificador_arr do (
						rando = (random 1 100)
						if prob >=  rando then (
						boxer = copy dummy_plane
						typer()
							sizer = nodeGetBoundingBox  i (i.transform)
							if mode == 1 do (
								width = abs(((sizer[2])[1])-((sizer[1])[1]))
								height = abs(((sizer[2])[3])-((sizer[1])[3]))
								depth = abs(((sizer[2])[2])-((sizer[1])[2]))
							)
							if mode == 2 do (
								width = abs(((sizer[2])[1])-((sizer[1])[1]))
								depth = abs(((sizer[2])[3])-((sizer[1])[3]))
								height = abs(((sizer[2])[2])-((sizer[1])[2]))
							)
							if mode == 3 do (
								height = abs(((sizer[2])[1])-((sizer[1])[1]))
								width = abs(((sizer[2])[3])-((sizer[1])[3]))
								depth = abs(((sizer[2])[2])-((sizer[1])[2]))
							)
							if mode == 4 do (
								height = abs(((sizer[2])[1])-((sizer[1])[1]))
								depth = abs(((sizer[2])[3])-((sizer[1])[3]))
								width = abs(((sizer[2])[2])-((sizer[1])[2]))
							)
							if mode == 5 do (
								depth = abs(((sizer[2])[1])-((sizer[1])[1]))
								width = abs(((sizer[2])[3])-((sizer[1])[3]))
								height = abs(((sizer[2])[2])-((sizer[1])[2]))
							)
							if mode == 6 do (
								depth = abs(((sizer[2])[1])-((sizer[1])[1]))
								height = abs(((sizer[2])[3])-((sizer[1])[3]))
								width = abs(((sizer[2])[2])-((sizer[1])[2]))
							)
							if type == "Blackout" then (
								boxer.name = "Blackout"
								boxer.width = width
								boxer.length = (height/(random 1 6))
								append blackouts boxer
								append window_cover boxer
							)
							if type == "Persiana" then (
								boxer.name = "Persiana"
								boxer.width = width
								boxer.length = (height/(random 1 5))
								append persianas boxer
								append window_cover boxer
							)
							if type == "Cortina" then (
								boxer.name = "Cortina"
								boxer.width = width
								boxer.length = height
								append cortinas boxer
								append window_cover boxer
							)
						)--end if true
					)--for i in cort end
				colorize()
				)--end undo	
				)--end redraw
			)
		)
	)--cortinificar end

	fn create_blackouts = (
		blackouts_mesh = mesh vertices:#() faces:#() 
        blackouts_mesh.name = "Blackouts"
		with redraw off (
		with undo off (
			for i in blackouts do (
				a = copy dummy_plane
				a.pos = i.pos
				a.width = i.width
				a.length = i.length
				a.transform = i.transform
				meshOp.attach blackouts_mesh a
				h2 = copy dummy_cyl
				h2.height = (i.width)
				h2.pivot = h2.center
				h2.pos= i.pos
				h2.transform = i.transform
				h2.radius = 1
				in coordsys (i.transform) (
					rotate h2 (angleaxis 90 [0,1,0])
					h2.pos.y = i.center.y - (i.length/2)
				)
				meshOp.attach blackouts_mesh h2 
				h3 = copy dummy_box
				h3.pos= i.pos
				h3.transform = i.transform
				h3.width = 2
				h3.height = 4
				h3.length = (i.width)
				in coordsys i.transform (
					h3.pos.y = h3.pos.y + (i.length/2) - (h3.width/2)
					h3.pos.z = h3.pos.z - (h3.height/2)
					rotate h3 (angleaxis -90 [0,0,1])
				)
				meshOp.attach blackouts_mesh h3 
			processedp = processedp + 1
			corticnt (cortinificador_arr.count) processedp 
			)
			blackouts_mesh.wirecolor = blackouts_color.color
			baked_blackouts =  #()
		)--end redraw
		)--end undo
	)--end fn
	
	fn create_persianas = (
		persianas_mesh = mesh vertices:#() faces:#() 
        persianas_mesh.name = "Persianas"
		with redraw off (
		with undo off (
			for i in persianas do (
				rando = (random 20 60)
				a = copy dummy_box
				a.length = 2.5
				a.height = 0.12
				a.pos = i.pos
				a.width = i.width
				a.transform = i.transform
				a.pivot = a.center
				in coordsys i.transform (
					a.pos.y = (i.length/2) 
					a.pos.z = i.pos.z 
				)
				quant = abs(i.length/a.length) + 1
				div = (i.length/quant)
				for step = 1 to quant-1 do (
					in coordsys i.transform (
						h = copy a
						rotate h (angleaxis rando [1,0,0])
						h.pos.y -= div*step 
					)
					meshOp.attach persianas_mesh h
				)
				in coordsys i.transform (
					h2 = copy a
					h2.pos.y -= div*quant 
					h2.pos.z -= 1
					h2.length = 1
					h2.height = 3
				)
				meshOp.attach persianas_mesh h2
				in coordsys i.transform (
					a.length = 2
					a.height = 4
					a.pos.z -= 2
					a.pos.y -= 1
				)
				meshOp.attach persianas_mesh a
				processedp = processedp + 1
				corticnt (cortinificador_arr.count) processedp 
			)
			persianas_mesh.wirecolor = persianas_color.color
			baked_persianas = #()
		)--end redraw
		)--end undo
	)--end fn
	
	fn create_cortinas = (
		cortinas_mesh = mesh vertices:#() faces:#() 
        cortinas_mesh.name = "cortinas"
		with redraw off (
		with undo off (
			for i in cortinas do (
				--Palo 
				h2 = copy dummy_cyl
				h2.height = (i.width)
				h2.pivot = h2.center
				h2.pos= i.pos
				h2.transform = i.transform
				h2.radius = 1
				h2.sides = 4
				in coordsys (i.transform) (
					rotate h2 (angleaxis 90 [0,1,0])
					h2.pos.y = i.center.y + (i.length/2) - 5
				)
				meshOp.attach cortinas_mesh h2
				h1 = copy dummy_plane
				h1.pos = i.pos
				h1.width = i.width/(random 2 4)
				h1.length = i.length
				h1.transform = i.transform
				h1.widthsegs = 10
				h2 = copy h1
				in coordsys (i.transform) (
					h1.pos.x = h1.pos.x - (i.width/2) + (h1.width/2)
					h2.pos.x = h2.pos.x + (i.width/2) - (h2.width/2)
				)
				ConvertTo h1 Editable_Mesh
				MeshOp.attach h1 h2
				in coordsys (i.transform) ( for i in (h1.verts) do ( move i [0,0,(random -5 5)]))
				processedp = processedp + 1
				corticnt (cortinificador_arr.count) processedp 
				meshOp.attach cortinas_mesh h1
			)
			cortinas_mesh.wirecolor = cortinas_color.color
			baked_cortinas =  #()
		)--end redraw
		)--end undo
	)--end fn
	
	on DankLowResCurtainMaker open do (
		create_rando()
		if selection.count >= 1 do (
			arr_btn.checked = true
			arr_btn.text = "Selected"
			cortinificador_arr = selection as array
			wind_cnt.text = cortinificador_arr.count as string
			clearwindow_cover()
			cortinificar()
			aligner()
			DankLowResCurtainMaker
		)
		if selection.count == 0 do (
		)
	)
	on DankLowResCurtainMaker close do (
	 clearwindow_cover()
		baked_persianas = #()
		baked_blackouts = #()
		baked_cortinas = #()
		delete_dummys()
	)
	on arr_btn changed state do (
		if state == true then (
			arr_btn.text = "Selected"
			if selection.count >= 1 then (
				cortinificador_arr = selection as array
				wind_cnt.text = cortinificador_arr.count as string
			)
			else (
				messagebox "Please select windows"
				arr_btn.checked = false
				arr_btn.text = "Select Windows"
			)
		)
		if state == false then (
			arr_btn.text = "Select Windows"
			wind_cnt.text = "0"
		)
	)
	on spn_prob changed val do (
		prob = val
		clearwindow_cover()
		cortinificar()
		aligner()
		DankLowResCurtainMaker
	)
	on spn_prob_blackouts changed val do (
		prob_blackouts = val
		create_rando()
		clearwindow_cover()
		cortinificar()
		aligner()
		DankLowResCurtainMaker
	)
	on spn_prob_persianas changed val do (
		prob_persianas = val
		create_rando()
		clearwindow_cover()
		cortinificar()
		aligner()
		DankLowResCurtainMaker
	)
	on spn_prob_cortinas changed val do (
		prob_cortinas = val
		create_rando()
		clearwindow_cover()
		cortinificar()
		aligner()
		DankLowResCurtainMaker
	)
	on spn_x changed val do (
		offsetx = val
		aligner()
	)
	on spn_y changed val do (
		offsety = val
		aligner()
	)
	on spn_z changed val do (
		offsetz = val
		aligner()
	)
	on spn_out changed val do (
		out = val
		aligner()
		DankLowResCurtainMaker
	)
	on btn pressed do (
		clearwindow_cover()
		cortinificar()
		aligner()
		DankLowResCurtainMaker
		clearselection()
	)
	on process_btn pressed do (
		if cortinificador_arr == undefined do (
			messagebox "Select windows!"
		)
		max create mode
		create_cortinas()
		create_blackouts()
		create_persianas ()
	)
	
	on erase_baked pressed do (
        delete $Persianas
		delete $Cortinas
		delete $Blackouts
	)
	on merge_baked pressed do (
		clearselection()
		for i in baked_persianas do (
			selectmore i
		)
		merger()
		clearselection()
		for i in baked_blackouts do (
			selectmore i
		)
		merger()
		clearselection()
		for i in baked_cortinas do (
			selectmore i
		)
		merger()
		clearselection()
		baked_persianas = #()
		baked_blackouts = #()
		baked_cortinas = #()
	)
	on spn_mode changed i do (
		mode = i
		clearwindow_cover()
		cortinificar()
		aligner()
		DankLowResCurtainMaker
	)
)-- End Rollout
createDialog DankLowResCurtainMaker  pos:[1990,200] 
