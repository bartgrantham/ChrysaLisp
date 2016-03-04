%include 'inc/func.inc'
%include 'inc/task.inc'

	fn_function sys/cpu_get_id, no_debug_enter
		;outputs
		;r0 = cpu ID

		fn_bind sys/task_statics, r0
		vp_cpy [r0 + tk_statics_cpu_id], r0
		vp_ret

	fn_function_end
