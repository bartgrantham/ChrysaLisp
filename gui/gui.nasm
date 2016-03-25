%include 'inc/func.inc'
%include 'inc/task.inc'
%include 'inc/gui.inc'
%include 'inc/sdl2.inc'
%include 'class/class_view.inc'

	fn_function gui/gui
		;allocate background view
		static_call view, create

		;set as gui screen view
		static_bind gui, statics, r1
		vp_cpy r0, [r1 + gui_statics_screen]

		;size and color and opaque
		vp_xor r8, r8
		vp_xor r9, r9
		vp_cpy SCREEN_WIDTH, r10
		vp_cpy SCREEN_HEIGHT, r11
		static_call view, change
		vp_xor r8, r8
		vp_xor r9, r9
		vp_xor r10, r10
		vp_cpy 255, r11
		static_call view, set_color
		static_call view, opaque

		;dirty all
		static_bind gui, statics, r0
		vp_cpy [r0 + gui_statics_screen], r0
		static_call view, dirty_all

		;sleep just a moment to let all routing finish
		vp_cpy 1000000, r0
		static_call task, sleep

		;for now fire up the test apps
		;this might be an gui auto run list eventually
		fn_bind tests/gui/gui1/app, r0
		static_call task, start
		fn_bind tests/gui/gui2/app, r0
		static_call task, start

		;gui event loop
		loop_start
		next_frame:
			;kernel callback for update
			vp_lea [rel kernel_callback], r0
			static_call task, callback

			;frame rate of gui updates
			vp_cpy 1000000 / 60, r0
			static_call task, sleep

			;get mouse info, see if any change
			static_bind gui, statics, r5
			vp_cpy [r5 + gui_statics_x_pos], r8
			vp_cpy [r5 + gui_statics_y_pos], r9
			vp_cpy [r5 + gui_statics_buttons], r10
			if r8, ==, [r5 + gui_statics_last_x_pos]
				if r9, ==, [r5 + gui_statics_last_y_pos]
					if r10, ==, [r5 + gui_statics_last_buttons]
						;same as last time
						vp_jmp next_frame
					endif
				endif
			endif
			vp_cpy r8, [r5 + gui_statics_last_x_pos]
			vp_cpy r9, [r5 + gui_statics_last_y_pos]
			vp_cpy r10, [r5 + gui_statics_last_buttons]

			;dispatch to task and target view
			vp_cpy [r5 + gui_statics_last_view], r6
			if r6, !=, 0
			send_mouse:
				;do we need to wait till button goes up ?
				if r6, !=, -1
					;lookup view owner
					vp_cpy r6, r0
					static_call view, find_owner
					if r1, !=, 0
						;save owner mailbox
						static_call cpu, id
						vp_lea [r1 + tk_node_mailbox], r14
						vp_cpy r0, r15

						;allocate mail message
						static_call mail, alloc
						fn_assert r0, !=, 0

						;fill in data
						vp_cpy r14, [r0 + ml_msg_dest]
						vp_cpy r15, [r0 + (ml_msg_dest + 8)]
						vp_cpy [r5 + gui_statics_x_pos], r8
						vp_cpy [r5 + gui_statics_y_pos], r9
						vp_cpy_cl ev_type_mouse, [r0 + (ml_msg_data + ev_data_type)]
						vp_cpy r6, [r0 + (ml_msg_data + ev_data_view)]
						vp_cpy r8, [r0 + (ml_msg_data + ev_data_x)]
						vp_cpy r9, [r0 + (ml_msg_data + ev_data_y)]
						vp_cpy r10, [r0 + (ml_msg_data + ev_data_buttons)]
						vp_sub [r6 + view_ctx_x], r8
						vp_sub [r6 + view_ctx_y], r9
						vp_cpy r8, [r0 + (ml_msg_data + ev_data_rx)]
						vp_cpy r9, [r0 + (ml_msg_data + ev_data_ry)]

						;send mail to owner
						static_call mail, send
					endif
				endif

				;if button went up then clear locked view
				if r10, ==, 0
					vp_cpy r10, [r5 + gui_statics_last_view]
				endif
			else
				;button down ?
				if r10, !=, 0
					;find view
					vp_cpy [r5 + gui_statics_screen], r0
					vp_cpy [r5 + gui_statics_x_pos], r8
					vp_cpy [r5 + gui_statics_y_pos], r9
					static_call view, hit_tree
					if r0, ==, [r5 + gui_statics_screen]
						vp_xor r0, r0
					endif
					if r0, ==, 0
						vp_cpy -1, r0
					endif
					vp_cpy r0, [r5 + gui_statics_last_view]
					vp_cpy r0, r6
					vp_jmp send_mouse
				else
					;hover
				endif
			endif
		loop_end
		vp_ret

	kernel_callback:
		;inputs
		;r0 = user data

		def_structure	local
			def_long	local_old_stack
		def_structure_end

		;align stack
		vp_cpy r4, r1
		vp_sub local_size, r4
		vp_and -16, r4
		vp_cpy r1, [r4 + local_old_stack]

		;create screen window ?
		static_bind gui, statics, r0
		vp_cpy [r0 + gui_statics_window], r1
		if r1, ==, 0
			;init sdl2
			sdl_set_main_ready
			sdl_init SDL_INIT_VIDEO
			ttf_init

			;create window
			vp_lea [rel title], r0
			sdl_create_window r0, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_OPENGL
			static_bind gui, statics, r1
			vp_cpy r0, [r1 + gui_statics_window]

			;create renderer
			sdl_create_renderer r0, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC
			static_bind gui, statics, r1
			vp_cpy r0, [r1 + gui_statics_renderer]

			;set blend mode
			sdl_set_render_draw_blend_mode r0, SDL_BLENDMODE_BLEND
		endif

		;update screen
		static_bind gui, statics, r0
		vp_cpy [r0 + gui_statics_screen], r0
		if r0, !=, 0
			;pump sdl events
			sdl_pump_events

			;get mouse state
			static_bind gui, statics, r0
			vp_lea [r0 + gui_statics_x_pos], r1
			vp_lea [r0 + gui_statics_y_pos], r2
			sdl_get_mouse_state r1, r2
			static_bind gui, statics, r1
			vp_add gui_statics_buttons, r1
			vp_cpy r0, [r1]

			;update the screen
			static_bind gui, statics, r0
			vp_cpy [r0 + gui_statics_screen], r0
			static_call gui, update

			;refresh the window
			static_bind gui, statics, r0
			sdl_render_present [r0 + gui_statics_renderer]
		endif

		vp_cpy [r4 + local_old_stack], r4
		vp_ret

	title:
		db 'Asm Kernel GUI Window', 0

	fn_function_end
