%ifndef CMD_1234
%define CMD_1234

	def_class cmd
	def_method master, cmd/cmd_master, static, {r0}
	def_method slave, cmd/cmd_slave, static, {r0}
	def_method create, cmd/cmd_create, static, {r0, r1, r2}, {r0}
	def_method next_msg, cmd/cmd_next_msg, static, {r0, r1, r2}, {r0}
	def_method input, cmd/cmd_input, static, {r0, r1, r2}
	def_method output, cmd/cmd_output, static, {r0, r1, r2}, {r0}
	def_method error, cmd/cmd_error, static, {r0, r1, r2}, {r0}
	def_method stdin, cmd/cmd_stdin, static, {r0, r1, r2}, {r0}
	def_method stdout, cmd/cmd_stdout, static, {r0, r1, r2}
	def_method stderr, cmd/cmd_stderr, static, {r0, r1, r2}

	def_structure cmd_mail_init, ml_msg_header
		struct cmd_mail_init_stdout_id, mailbox_id
		struct cmd_mail_init_stderr_id, mailbox_id
		struct cmd_mail_init_args, null
	def_structure_end

	def_structure cmd_mail_stream, ml_msg_header
		ulong cmd_mail_stream_seqnum
		struct cmd_mail_stream_data, null
	def_structure_end

	def_structure cmd_master
		struct cmd_master_input_mailbox_id, mailbox_id
		struct cmd_master_output_mailbox, ml_mailbox
		struct cmd_master_error_mailbox, ml_mailbox
		struct cmd_master_output_list, lh_list
		ulong cmd_master_input_seqnum
		ulong cmd_master_output_seqnum
	def_structure_end

	cmd_args_buffer_size equ 120

	def_structure cmd_slave
		struct cmd_slave_stdin_list, lh_list
		struct cmd_slave_stdout_id, mailbox_id
		struct cmd_slave_stderr_id, mailbox_id
		ulong cmd_slave_stdout_seqnum
		ulong cmd_slave_stdin_seqnum
		ulong cmd_slave_args_length
		struct cmd_slave_args, cmd_args_buffer
	def_structure_end

%endif