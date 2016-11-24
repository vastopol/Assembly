/usr/hla/hlalibsrc/trunk/os_mac.a: \
	mac_accept.o \
	mac_bind.o \
	mac_chdir.o \
	mac_close.o \
	mac_connect.o \
	mac_errno.o \
	mac_execve.o \
	mac_exit.o \
	mac_fork.o \
	mac_fstat.o \
	mac_fsync.o \
	mac_ftok.o \
	mac_ftruncate.o \
	mac_getcwd.o \
	mac_getdents.o \
	mac_getdirentries.o \
	mac_gethostbyaddr.o \
	mac_gethostbyname.o \
	mac_gethostname.o \
	mac_getpeername.o \
	mac_getsockname.o \
	mac_getsockopt.o \
	mac_gettimeofday.o \
	mac_h_errno.o \
	mac_listen.o \
	mac_lseek.o \
	mac_lstat.o \
	mac_mkdir.o \
	mac_mmap.o \
	mac_munmap.o \
	mac_nanosleep.o \
	mac_open2.o \
	mac_open3.o \
	mac_pread.o \
	mac_pthread_attr_destroy.o \
	mac_pthread_attr_init.o \
	mac_pthread_attr_setstacksize.o \
	mac_pthread_cond_destroy.o \
	mac_pthread_cond_init.o \
	mac_pthread_cond_signal.o \
	mac_pthread_cond_wait.o \
	mac_pthread_create.o \
	mac_pthread_exit.o \
	mac_pthread_getspecific.o \
	mac_pthread_key_create.o \
	mac_pthread_key_delete.o \
	mac_pthread_mutex_destroy.o \
	mac_pthread_mutex_init.o \
	mac_pthread_mutex_lock.o \
	mac_pthread_mutex_unlock.o \
	mac_pthread_self.o \
	mac_pthread_setspecific.o \
	mac_read.o \
	mac_recv.o \
	mac_recvfrom.o \
	mac_rename.o \
	mac_rmdir.o \
	mac_select.o \
	mac_semctl.o \
	mac_semget.o \
	mac_semop.o \
	mac_send.o \
	mac_sendto.o \
	mac_setsockopt.o \
	mac_shutdown.o \
	mac_sigaction.o \
	mac_sigprocmask.o \
	mac_socket.o \
	mac_stat.o \
	mac_truncate.o \
	mac_unlink.o \
	mac_waitpid.o \
	mac_write.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib.a \
		mac_accept.o \
		mac_bind.o \
		mac_chdir.o \
		mac_close.o \
		mac_connect.o \
		mac_errno.o \
		mac_execve.o \
		mac_exit.o \
		mac_fork.o \
		mac_fstat.o \
		mac_fsync.o \
		mac_ftok.o \
		mac_ftruncate.o \
		mac_getcwd.o \
		mac_getdents.o \
		mac_getdirentries.o \
		mac_gethostbyaddr.o \
		mac_gethostbyname.o \
		mac_gethostname.o \
		mac_getpeername.o \
		mac_getsockname.o \
		mac_getsockopt.o \
		mac_gettimeofday.o \
		mac_h_errno.o \
		mac_listen.o \
		mac_lseek.o \
		mac_lstat.o \
		mac_mkdir.o \
		mac_mmap.o \
		mac_munmap.o \
		mac_nanosleep.o \
		mac_open2.o \
		mac_open3.o \
		mac_pread.o \
		mac_pthread_attr_destroy.o \
		mac_pthread_attr_init.o \
		mac_pthread_attr_setstacksize.o \
		mac_pthread_cond_destroy.o \
		mac_pthread_cond_init.o \
		mac_pthread_cond_signal.o \
		mac_pthread_cond_wait.o \
		mac_pthread_create.o \
		mac_pthread_exit.o \
		mac_pthread_getspecific.o \
		mac_pthread_key_create.o \
		mac_pthread_key_delete.o \
		mac_pthread_mutex_destroy.o \
		mac_pthread_mutex_init.o \
		mac_pthread_mutex_lock.o \
		mac_pthread_mutex_unlock.o \
		mac_pthread_self.o \
		mac_pthread_setspecific.o \
		mac_read.o \
		mac_recv.o \
		mac_recvfrom.o \
		mac_rename.o \
		mac_rmdir.o \
		mac_select.o \
		mac_semctl.o \
		mac_semget.o \
		mac_semop.o \
		mac_send.o \
		mac_sendto.o \
		mac_setsockopt.o \
		mac_shutdown.o \
		mac_sigaction.o \
		mac_sigprocmask.o \
		mac_socket.o \
		mac_stat.o \
		mac_truncate.o \
		mac_unlink.o \
		mac_waitpid.o \
		mac_write.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib.a

mac_accept.o: mac_accept.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_accept

mac_bind.o: mac_bind.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_bind

mac_chdir.o: mac_chdir.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_chdir

mac_close.o: mac_close.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_close

mac_connect.o: mac_connect.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_connect

mac_errno.o: mac_errno.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_errno

mac_execve.o: mac_execve.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_execve

mac_exit.o: mac_exit.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_exit

mac_fork.o: mac_fork.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_fork

mac_fstat.o: mac_fstat.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_fstat

mac_fsync.o: mac_fsync.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_fsync

mac_ftok.o: mac_ftok.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_ftok

mac_ftruncate.o: mac_ftruncate.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_ftruncate

mac_getcwd.o: mac_getcwd.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_getcwd

mac_getdents.o: mac_getdents.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_getdents

mac_getdirentries.o: mac_getdirentries.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_getdirentries

mac_gethostbyaddr.o: mac_gethostbyaddr.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_gethostbyaddr

mac_gethostbyname.o: mac_gethostbyname.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_gethostbyname

mac_gethostname.o: mac_gethostname.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_gethostname

mac_getpeername.o: mac_getpeername.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_getpeername

mac_getsockname.o: mac_getsockname.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_getsockname

mac_getsockopt.o: mac_getsockopt.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_getsockopt

mac_gettimeofday.o: mac_gettimeofday.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_gettimeofday

mac_h_errno.o: mac_h_errno.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_h_errno

mac_listen.o: mac_listen.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_listen

mac_lseek.o: mac_lseek.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_lseek

mac_lstat.o: mac_lstat.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_lstat

mac_mkdir.o: mac_mkdir.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_mkdir

mac_mmap.o: mac_mmap.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_mmap

mac_munmap.o: mac_munmap.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_munmap

mac_nanosleep.o: mac_nanosleep.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_nanosleep

mac_open2.o: mac_open2.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_open2

mac_open3.o: mac_open3.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_open3

mac_pread.o: mac_pread.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pread

mac_pthread_attr_destroy.o: mac_pthread_attr_destroy.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_attr_destroy

mac_pthread_attr_init.o: mac_pthread_attr_init.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_attr_init

mac_pthread_attr_setstacksize.o: mac_pthread_attr_setstacksize.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_attr_setstacksize

mac_pthread_cond_destroy.o: mac_pthread_cond_destroy.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_cond_destroy

mac_pthread_cond_init.o: mac_pthread_cond_init.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_cond_init

mac_pthread_cond_signal.o: mac_pthread_cond_signal.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_cond_signal

mac_pthread_cond_wait.o: mac_pthread_cond_wait.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_cond_wait

mac_pthread_create.o: mac_pthread_create.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_create

mac_pthread_exit.o: mac_pthread_exit.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_exit

mac_pthread_getspecific.o: mac_pthread_getspecific.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_getspecific

mac_pthread_key_create.o: mac_pthread_key_create.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_key_create

mac_pthread_key_delete.o: mac_pthread_key_delete.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_key_delete

mac_pthread_mutex_destroy.o: mac_pthread_mutex_destroy.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_mutex_destroy

mac_pthread_mutex_init.o: mac_pthread_mutex_init.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_mutex_init

mac_pthread_mutex_lock.o: mac_pthread_mutex_lock.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_mutex_lock

mac_pthread_mutex_unlock.o: mac_pthread_mutex_unlock.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_mutex_unlock

mac_pthread_self.o: mac_pthread_self.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_self

mac_pthread_setspecific.o: mac_pthread_setspecific.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_pthread_setspecific

mac_read.o: mac_read.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_read

mac_recv.o: mac_recv.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_recv

mac_recvfrom.o: mac_recvfrom.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_recvfrom

mac_rename.o: mac_rename.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_rename

mac_rmdir.o: mac_rmdir.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_rmdir

mac_select.o: mac_select.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_select

mac_semctl.o: mac_semctl.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_semctl

mac_semget.o: mac_semget.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_semget

mac_semop.o: mac_semop.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_semop

mac_send.o: mac_send.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_send

mac_sendto.o: mac_sendto.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_sendto

mac_setsockopt.o: mac_setsockopt.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_setsockopt

mac_shutdown.o: mac_shutdown.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_shutdown

mac_sigaction.o: mac_sigaction.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_sigaction

mac_sigprocmask.o: mac_sigprocmask.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_sigprocmask

mac_socket.o: mac_socket.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_socket

mac_stat.o: mac_stat.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_stat

mac_truncate.o: mac_truncate.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_truncate

mac_unlink.o: mac_unlink.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_unlink

mac_waitpid.o: mac_waitpid.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_waitpid

mac_write.o: mac_write.hla \

	hla -sourcemode -ag -AL -cx -p:temp  mac_write



clean:
	delete temp
	delete .inc
	delete .o
	delete .obj
	delete .link
	delete .exe
	delete .asm
	delete .pdb
	delete .ilk
	delete .a
	delete .lib

