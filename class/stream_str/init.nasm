%include 'inc/func.inc'
%include 'class/class_string.inc'
%include 'class/class_stream_str.inc'

	def_function class/stream_str/init
		;inputs
		;r0 = stream_str object
		;r1 = vtable pointer
		;r2 = string object
		;outputs
		;r1 = 0 if error, else ok
		;trashes
		;all but r0, r4

		;init parent
		p_call stream_str, init, {r0, r1, r2, 0, &[r2 + string_data], [r2 + string_length]}, {r1}
		if r1, !=, 0
			;init myself
		endif
		vp_ret

	def_function_end