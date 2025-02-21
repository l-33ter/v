import os
import time
import json
import net
import net.http
import io

const (
	sport           = 12382
	sport2          = 12383
	localserver     = '127.0.0.1:${sport}'
	exit_after_time = 12000 // milliseconds
	vexe            = os.getenv('VEXE')
	vweb_logfile    = os.getenv('VWEB_LOGFILE')
	vroot           = os.dir(vexe)
	serverexe       = os.join_path(os.cache_dir(), 'controller_test_server.exe')
	tcp_r_timeout   = 30 * time.second
	tcp_w_timeout   = 30 * time.second
)

// setup of vweb webserver
fn testsuite_begin() {
	os.chdir(vroot) or {}
	if os.exists(serverexe) {
		os.rm(serverexe) or {}
	}
}

fn test_middleware_vweb_app_can_be_compiled() {
	// did_server_compile := os.system('${os.quoted_path(vexe)} -g -o ${os.quoted_path(serverexe)} vlib/vweb/tests/controller_test_server.vv')
	// TODO: find out why it does not compile with -usecache and -g
	did_server_compile := os.system('${os.quoted_path(vexe)} -o ${os.quoted_path(serverexe)} vlib/vweb/tests/controller_test_server.v')
	assert did_server_compile == 0
	assert os.exists(serverexe)
}

fn test_middleware_vweb_app_runs_in_the_background() {
	mut suffix := ''
	$if !windows {
		suffix = ' > /dev/null &'
	}
	if vweb_logfile != '' {
		suffix = ' 2>> ${os.quoted_path(vweb_logfile)} >> ${os.quoted_path(vweb_logfile)} &'
	}
	server_exec_cmd := '${os.quoted_path(serverexe)} ${sport} ${exit_after_time} ${suffix}'
	$if debug_net_socket_client ? {
		eprintln('running:\n${server_exec_cmd}')
	}
	$if windows {
		spawn os.system(server_exec_cmd)
	} $else {
		res := os.system(server_exec_cmd)
		assert res == 0
	}
	$if macos {
		time.sleep(1000 * time.millisecond)
	} $else {
		time.sleep(100 * time.millisecond)
	}
}

// test functions:

fn test_app_home() {
	x := http.get('http://${localserver}/') or { panic(err) }
	assert x.body == 'App'
}

fn test_app_path() {
	x := http.get('http://${localserver}/path') or { panic(err) }
	assert x.body == 'App path'
}

fn test_admin_home() {
	x := http.get('http://${localserver}/admin/') or { panic(err) }
	assert x.body == 'Admin'
}

fn test_admin_path() {
	x := http.get('http://${localserver}/admin/path') or { panic(err) }
	assert x.body == 'Admin path'
}

fn test_other_home() {
	x := http.get('http://${localserver}/other/') or { panic(err) }
	assert x.body == 'Other'
}

fn test_other_path() {
	x := http.get('http://${localserver}/other/path') or { panic(err) }
	assert x.body == 'Other path'
}

fn test_shutdown() {
	// This test is guaranteed to be called last.
	// It sends a request to the server to shutdown.
	x := http.fetch(
		url: 'http://${localserver}/shutdown'
		method: .get
		cookies: {
			'skey': 'superman'
		}
	) or {
		assert err.msg() == ''
		return
	}
	assert x.status() == .ok
	assert x.body == 'good bye'
}

fn test_duplicate_route() {
	did_server_compile := os.system('${os.quoted_path(vexe)} -o ${os.quoted_path(serverexe)} vlib/vweb/tests/controller_duplicate_server.v')
	assert did_server_compile == 0
	assert os.exists(serverexe)

	mut suffix := ''

	if vweb_logfile != '' {
		suffix = ' 2>> ${os.quoted_path(vweb_logfile)} >> ${os.quoted_path(vweb_logfile)} &'
	}
	server_exec_cmd := '${os.quoted_path(serverexe)} ${sport2} ${exit_after_time} ${suffix}'
	$if debug_net_socket_client ? {
		eprintln('running:\n${server_exec_cmd}')
	}
	$if windows {
		task := spawn os.execute(server_exec_cmd)
		res := task.wait()
		assert res.output.contains('V panic: method "duplicate" with route "/admin/duplicate" should be handled by the Controller of "/admin"')
	} $else {
		res := os.execute(server_exec_cmd)
		assert res.output.contains('V panic: method "duplicate" with route "/admin/duplicate" should be handled by the Controller of "/admin"')
	}
}
