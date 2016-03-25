%include 'inc/func.inc'
%include 'inc/gui.inc'
%include 'class/class_view.inc'

	fn_function class/view/forward
		;inputs
		;r0 = view object
		;r1 = user data pointer
		;r2 = callback
		;trashes
		;dependant on callback
			;callback api
			;inputs
			;r0 = child view object
			;r1 = user data pointer
			;outputs
			;r0 = child view object

		def_structure	local
			def_long	local_data
			def_long	local_callback
		def_structure_end

		vp_sub local_size, r4
		vp_cpy r1, [r4 + local_data]
		vp_cpy r2, [r4 + local_callback]

		lh_get_tail r0 + view_list, r0
		loop_start
		 	ln_get_pred r0, r1
			breakif r1, ==, 0

			;callback
			vp_sub view_node, r0
			vp_cpy [r4 + local_data], r1
			vp_call [r4 + local_callback]

			;across to sibling
			ln_get_pred r0 + view_node, r0
		loop_end
		vp_add local_size, r4
		vp_ret

	fn_function_end
