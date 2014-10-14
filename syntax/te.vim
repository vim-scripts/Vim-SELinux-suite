" Vim syntax file
" Language:			TE (SELinux Type Enforcement Policy)
" Original Author:	Thomas Bleher <ThomasBleher@gmx.de>
" Original URL:		http://www.cip.informatik.uni-muenchen.de/~bleher/selinux/te.vim 
" Lastchange:		2004 Dec 25
"
" Author:			Yedvilun Prior
" Lastchange:		2014 Oct 07
"
" Note:	uses m4.vim, some code taken from cpp.vim
"
" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
"
 
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" First load the M4 syntax
if version < 600
  so <sfile>:p:h/m4.vim
else
  runtime! syntax/m4.vim
  unlet b:current_syntax
endif

syn sync	minlines=100

" Keywords {{{1
" Class sets {{{2
" from /usr/share/selinux/devel/include/support/obj_perm_sets.spt
syn keyword teClassSet 
	\ dir_file_class_set
	\ file_class_set
	\ notdevfile_class_set
	\ devfile_class_set
	\ socket_class_set
	\ dgram_socket_class_set
	\ stream_socket_class_set
	\ unpriv_socket_class_set

" Permission sets {{{2
" from /usr/share/selinux/devel/include/support/obj_perm_sets.spt
syn keyword tePermSet
	\ mount_fs_perms
	\ rw_socket_perms
	\ create_socket_perms
	\ rw_stream_socket_perms
	\ create_stream_socket_perms
	\ connected_socket_perms
	\ connected_stream_socket_perms
	\ create_netlink_socket_perms
	\ rw_netlink_socket_perms
	\ r_netlink_socket_perms
	\ signal_perms
	\ packet_perms
	\ r_sem_perms
	\ rw_sem_perms
	\ create_sem_perms
	\ r_msgq_perms
	\ rw_msgq_perms
	\ create_msgq_perms
	\ r_shm_perms
	\ rw_shm_perms
	\ create_shm_perms
	\ getattr_dir_perms
	\ setattr_dir_perms
	\ search_dir_perms
	\ list_dir_perms
	\ add_entry_dir_perms
	\ del_entry_dir_perms
	\ rw_dir_perms
	\ create_dir_perms
	\ rename_dir_perms
	\ delete_dir_perms
	\ manage_dir_perms
	\ relabelfrom_dir_perms
	\ relabelto_dir_perms
	\ relabel_dir_perms
	\ getattr_file_perms
	\ setattr_file_perms
	\ read_inherited_file_perms
	\ read_file_perms
	\ mmap_file_perms
	\ exec_file_perms
	\ append_inherited_file_perms
	\ append_file_perms
	\ write_inherited_file_perms
	\ write_file_perms
	\ rw_inherited_file_perms
	\ rw_file_perms
	\ create_file_perms
	\ rename_file_perms
	\ delete_file_perms
	\ manage_file_perms
	\ relabelfrom_file_perms
	\ relabelto_file_perms
	\ relabel_file_perms
	\ getattr_lnk_file_perms
	\ setattr_lnk_file_perms
	\ read_lnk_file_perms
	\ append_lnk_file_perms
	\ write_lnk_file_perms
	\ rw_lnk_file_perms
	\ create_lnk_file_perms
	\ rename_lnk_file_perms
	\ delete_lnk_file_perms
	\ manage_lnk_file_perms
	\ relabelfrom_lnk_file_perms
	\ relabelto_lnk_file_perms
	\ relabel_lnk_file_perms
	\ getattr_fifo_file_perms
	\ setattr_fifo_file_perms
	\ read_fifo_file_perms
	\ append_fifo_file_perms
	\ write_fifo_file_perms
	\ rw_inherited_fifo_file_perms
	\ rw_fifo_file_perms
	\ create_fifo_file_perms
	\ rename_fifo_file_perms
	\ delete_fifo_file_perms
	\ manage_fifo_file_perms
	\ relabelfrom_fifo_file_perms
	\ relabelto_fifo_file_perms
	\ relabel_fifo_file_perms
	\ getattr_sock_file_perms
	\ setattr_sock_file_perms
	\ read_sock_file_perms
	\ write_sock_file_perms
	\ rw_inherited_sock_file_perms
	\ rw_sock_file_perms
	\ create_sock_file_perms
	\ rename_sock_file_perms
	\ delete_sock_file_perms
	\ manage_sock_file_perms
	\ relabelfrom_sock_file_perms
	\ relabelto_sock_file_perms
	\ relabel_sock_file_perms
	\ getattr_blk_file_perms
	\ setattr_blk_file_perms
	\ read_blk_file_perms
	\ append_blk_file_perms
	\ write_blk_file_perms
	\ rw_inherited_blk_file_perms
	\ rw_blk_file_perms
	\ create_blk_file_perms
	\ rename_blk_file_perms
	\ delete_blk_file_perms
	\ manage_blk_file_perms
	\ relabelfrom_blk_file_perms
	\ relabelto_blk_file_perms
	\ relabel_blk_file_perms
	\ getattr_chr_file_perms
	\ setattr_chr_file_perms
	\ read_chr_file_perms
	\ append_chr_file_perms
	\ write_chr_file_perms
	\ rw_inherited_chr_file_perms
	\ rw_chr_file_perms
	\ create_chr_file_perms
	\ rename_chr_file_perms
	\ delete_chr_file_perms
	\ manage_chr_file_perms
	\ relabelfrom_chr_file_perms
	\ relabelto_chr_file_perms
	\ relabel_chr_file_perms
	\ rw_inherited_term_perms
	\ rw_term_perms
	\ client_stream_socket_perms
	\ server_stream_socket_perms
	\ manage_key_perms
	\ manage_service_perms
 
" all_permissions sets {{{2
" from /usr/share/selinux/devel/include/support/all_perms.spt
syn keyword teAllPermSet 
	\ all_filesystem_perms
	\ all_dir_perms
	\ all_file_perms
	\ all_lnk_file_perms
	\ all_chr_file_perms
	\ all_blk_file_perms
	\ all_sock_file_perms
	\ all_fifo_file_perms
	\ all_fd_perms
	\ all_socket_perms
	\ all_tcp_socket_perms
	\ all_udp_socket_perms
	\ all_rawip_socket_perms
	\ all_node_perms
	\ all_netif_perms
	\ all_netlink_socket_perms
	\ all_packet_socket_perms
	\ all_key_socket_perms
	\ all_unix_stream_socket_perms
	\ all_unix_dgram_socket_perms
	\ all_process_perms
	\ all_ipc_perms
	\ all_sem_perms
	\ all_msgq_perms
	\ all_msg_perms
	\ all_shm_perms
	\ all_security_perms
	\ all_system_perms
	\ all_capability_perms
	\ all_capability2_perms
	\ all_passwd_perms
	\ all_x_drawable_perms
	\ all_x_screen_perms
	\ all_x_gc_perms
	\ all_x_font_perms
	\ all_x_colormap_perms
	\ all_x_property_perms
	\ all_x_selection_perms
	\ all_x_cursor_perms
	\ all_x_client_perms
	\ all_x_device_perms
	\ all_x_server_perms
	\ all_x_extension_perms
	\ all_x_resource_perms
	\ all_x_event_perms
	\ all_x_synthetic_event_perms
	\ all_netlink_route_socket_perms
	\ all_netlink_firewall_socket_perms
	\ all_netlink_tcpdiag_socket_perms
	\ all_netlink_nflog_socket_perms
	\ all_netlink_xfrm_socket_perms
	\ all_netlink_selinux_socket_perms
	\ all_netlink_audit_socket_perms
	\ all_netlink_ip6fw_socket_perms
	\ all_netlink_dnrt_socket_perms
	\ all_dbus_perms
	\ all_nscd_perms
	\ all_association_perms
	\ all_netlink_kobject_uevent_socket_perms
	\ all_appletalk_socket_perms
	\ all_packet_perms
	\ all_key_perms
	\ all_context_perms
	\ all_dccp_socket_perms
	\ all_memprotect_perms
	\ all_db_database_perms
	\ all_db_table_perms
	\ all_db_procedure_perms
	\ all_db_column_perms
	\ all_db_tuple_perms
	\ all_db_blob_perms
	\ all_peer_perms
	\ all_x_application_data_perms
	\ all_kernel_service_perms
	\ all_tun_socket_perms
	\ all_x_pointer_perms
	\ all_x_keyboard_perms
	\ all_db_schema_perms
	\ all_db_view_perms
	\ all_db_sequence_perms
	\ all_db_language_perms
	\ all_service_perms
	\ all_proxy_perms
	\ all_kernel_class_perms
	\ all_userspace_class_perms

" Classes {{{2
syn keyword teClasses
 	\ appletalk_socket
 	\ association
	\ blk_file
	\ capability
	\ capability2
	\ chr_file
	\ context
	\ database
	\ db_blob
	\ db_column
	\ db_database
	\ db_language
	\ db_procedure
	\ db_schema
	\ db_sequence
	\ db_table
	\ db_tuple
	\ dbus
	\ db_view
	\ dccp_socket
	\ dir
	\ fd
	\ fifo_file
	\ file
	\ filesystem
	\ ipc
	\ kernel_service
	\ key
	\ key_socket
	\ lnk_file
	\ memprotect
	\ msg
	\ msgq
	\ netif
	\ netlink_audit_socket
	\ netlink_dnrt_socket
	\ netlink_firewall_socket
	\ netlink_ip6fw_socket
	\ netlink_kobject_uevent_socket
	\ netlink_nflog_socket
	\ netlink_route_socket
	\ netlink_selinux_socket
	\ netlink_socket
	\ netlink_tcpdiag_socket
	\ netlink_xfrm_socket
	\ node
	\ nscd
	\ packet
	\ packet_socket
	\ passwd
	\ peer
	\ process
	\ rawip_socket
	\ security
	\ sem
	\ service
	\ shm
	\ socket
	\ sock_file
	\ system
	\ tcp_socket
	\ tun_socket
	\ udp_socket
	\ unix_dgram_socket
	\ unix_stream_socket
	\ x_application_data
	\ x_client
	\ x_colormap
	\ x_cursor
	\ x_device
	\ x_drawable
	\ x_event
	\ x_extension
	\ x_font
	\ x_gc
	\ x_keyboard
	\ x_pointer
	\ x_property
	\ x_resource
	\ x_screen
	\ x_selection
	\ x_server
	\ x_synthetic_event


" Permissions {{{2
syn keyword tePermissions
	\ accept
	\ acceptfrom
	\ acquire_svc
	\ add
	\ add_child
	\ add_color
	\ add_glyph
	\ add_name
	\ admin
	\ append
	\ associate
	\ audit_access
	\ audit_control
	\ audit_write
	\ bell
	\ bind
	\ blend
	\ check_context
	\ chfn
	\ chown
	\ chsh
	\ compute_av
	\ compute_create
	\ compute_member
	\ compute_relabel
	\ compute_user
	\ connect
	\ connectto
	\ {contains}
	\ copy
	\ create
	\ create_files_as
	\ crontab
	\ dac_override
	\ dac_read_search
	\ dccp_recv
	\ dccp_send
	\ debug
	\ delete
	\ destroy
	\ drop
	\ dyntransition
	\ egress
	\ enforce_dest
	\ enqueue
	\ entrypoint
	\ epollwakeup
	\ execheap
	\ execmem
	\ execmod
	\ execstack
	\ execute
	\ execute_no_trans
	\ expand
	\ export
	\ flow_in
	\ flow_out
	\ force_cursor
	\ fork
	\ forward_in
	\ forward_out
	\ fowner
	\ freeze
	\ fsetid
	\ getattr
	\ getcap
	\ getfocus
	\ getgrp
	\ gethost
	\ getopt
	\ getpid
	\ get_property
	\ getpwd
	\ getsched
	\ getserv
	\ getsession
	\ getstat
	\ get_value
	\ grab
	\ hide
	\ hide_cursor
	\ implement
	\ import
	\ ingress
	\ insert
	\ install
	\ install_module
	\ ioctl
	\ ipc_info
	\ ipc_lock
	\ ipc_owner
	\ kill
	\ lease
	\ link
	\ linux_immutable
	\ list_child
	\ listen
	\ list_property
	\ load_module
	\ load_policy
	\ lock
	\ mac_admin
	\ mac_override
	\ manage
	\ mknod
	\ mmap_zero
	\ mount
	\ mounton
	\ name_bind
	\ name_connect
	\ net_admin
	\ net_bind_service
	\ netbroadcast
	\ net_raw
	\ newconn
	\ next_value
	\ nlmsg_read
	\ nlmsg_readpriv
	\ nlmsg_relay
	\ nlmsg_tty_audit
	\ nlmsg_write
	\ noatsecure
	\ node_bind
	\ open
	\ override
	\ passwd
	\ paste
	\ paste_after_confirm
	\ polmatch
	\ ptrace
	\ query
	\ quotaget
	\ quotamod
	\ quotaon
	\ rawip_recv
	\ rawip_send
	\ read
	\ receive
	\ record
	\ recv
	\ recvfrom
	\ recv_msg
	\ relabelfrom
	\ relabelto
	\ reload
	\ remount
	\ remove
	\ remove_child
	\ remove_color
	\ remove_glyph
	\ remove_name
	\ rename
	\ rlimitinh
	\ rmdir
	\ rootok
	\ saver_getattr
	\ saver_hide
	\ saver_setattr
	\ saver_show
	\ search
	\ select
	\ send
	\ send_msg
	\ sendto
	\ setattr
	\ setbool
	\ setcap
	\ setcheckreqprot
	\ setcontext
	\ setcurrent
	\ setenforce
	\ setexec
	\ setfcap
	\ setfocus
	\ setfscreate
	\ setgid
	\ setkeycreate
	\ setopt
	\ setpcap
	\ setpgid
	\ set_property
	\ setrlimit
	\ setsched
	\ setsecparam
	\ setsockcreate
	\ setuid
	\ set_value
	\ share
	\ shmemgrp
	\ shmemhost
	\ shmempwd
	\ shmemserv
	\ show
	\ show_cursor
	\ shutdown
	\ sigchld
	\ siginh
	\ sigkill
	\ signal
	\ signull
	\ sigstop
	\ start
	\ status
	\ stop
	\ swapon
	\ sys_admin
	\ sys_boot
	\ sys_chroot
	\ syslog_console
	\ syslog_mod
	\ syslog_read
	\ sys_module
	\ sys_nice
	\ sys_pacct
	\ sys_ptrace
	\ sys_rawio
	\ sys_resource
	\ sys_time
	\ sys_tty_config
	\ tcp_recv
	\ tcp_send
	\ transition
	\ translate
	\ udp_recv
	\ udp_send
	\ uninstall
	\ unix_read
	\ unix_write
	\ unlink
	\ unmount
	\ update
	\ use
	\ use_as_override
	\ view
	\ wake_alarm
	\ write
"}}}
" Statements {{{1 
syn keyword	teStatement	
	\ alias
	\ allow
	\ attribute
	\ attribute_role
	\ auditallow
	\ bool
	\ class
	\ dominance
	\ dontaudit
	\ neverallow
	\ permissive
	\ require
	\ role
	\ roles
	\ roleattribute
	\ role_transition
	\ type
	\ typealias
	\ typeattribute
	\ type_change
	\ typebounds
	\ type_member
	\ types
	\ type_transition
	\ user
"}}}
" Strings {{{1
syn match teString '\("[^"]\+"\|\'[^\']\+\'\)'
" }}}
" Other syntax {{{1
" Original rules {{{2
" Syntax {{{3
" define the te syntax
syn keyword	teTodo		TODO XXX FIXME contained
syn match	teDescription	/\<\(Authors\=\>\|X[-_A-Za-z]*-Packages:\|DESC\>\|Depends:\).*/ contained
syn match	teComment	/#.*/ contains=teTodo,teDescription
syn match	teNegated	/[-~]\(\w\|\$\)\+/
syn region	teNegated	start="\~{" end="}" contains=@m4Top
syn region	teConditional	start="if (.*) {" end="}" contains=@m4Top
syn match	teSpecial	/\*/

" highlight teStatements and teComments inside of m4-macros
syn cluster	m4Top		contains=m4Comment,m4Constants,m4Special,m4Variable,m4String,m4Paren,m4Command,m4Statement,m4Function,teStatement,teComment,teNegated,teConditional
" change m4Type to allow lowercase-macros
syn region	m4Function	matchgroup=m4Type      start="\<[_A-Za-z]\w*("he=e-1 end=")" contains=@m4Top

" Highlighting {{{3
" Default highlighting
if version >= 508 || !exists("did_te_syntax_inits")
	if version < 508
		let did_te_syntax_inits = 1
		command -nargs=+ HiLink hi link <args>
		command -nargs=+ HiCust hi <args>
	else
		command -nargs=+ HiLink hi def link <args>
		command -nargs=+ HiCust hi def <args>
	endif
	HiLink teStatement		Statement
	HiLink teTodo			Todo
	HiLink teDescription	Underlined
	HiLink teComment		Comment
	HiLink teNegated		Special
	HiLink teSpecial		Special
	HiLink teConditional	String
" Added
	HiLink teString			String
	HiCust teClassSet		ctermfg=green cterm=bold gui=bold guifg=green
	HiCust tePermSet  		ctermfg=magenta cterm=bold gui=bold guifg=magenta
	HiCust teAllPermSet		ctermfg=magenta cterm=bold gui=bold guifg=magenta
	HiCust teClasses		ctermfg=green guifg=green
	HiLink tePermissions	Special
	delcommand HiLink
	delcommand HiCust
endif
"}}}

let b:current_syntax = "te"

" arch-tag: a0a77edf-bed7-43ca-a19e-6279177a9de2
" vim: set ts=4 sw=4 tw=78 noet fdm=marker :
