import os
import time
import json
import net
import net.http
import io

const (
	sport           = 12380
	localserver     = '127.0.0.1:${sport}'
	exit_after_time = 12000 // milliseconds
	vexe            = os.getenv('VEXE')
	vweb_logfile    = os.getenv('VWEB_LOGFILE')
	vroot           = os.dir(vexe)
	serverexe       = os.join_path(os.cache_dir(), 'vweb_test_server.exe')
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

fn test_a_simple_vweb_app_can_be_compiled() {
	// did_server_compile := os.system('${os.quoted_path(vexe)} -g -o ${os.quoted_path(serverexe)} vlib/vweb/tests/vweb_test_server.v')
	// TODO: find out why it does not compile with -usecache and -g
	did_server_compile := os.system('${os.quoted_path(vexe)} -o ${os.quoted_path(serverexe)} vlib/vweb/tests/vweb_test_server.v')
	assert did_server_compile == 0
	assert os.exists(serverexe)
}

fn test_a_simple_vweb_app_runs_in_the_background() {
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

// web client tests follow
fn assert_common_headers(received string) {
	assert received.starts_with('HTTP/1.1 200 OK\r\n')
	assert received.contains('Server: VWeb\r\n')
	assert received.contains('Content-Length:')
	assert received.contains('Connection: close\r\n')
}

fn test_a_simple_tcp_client_can_connect_to_the_vweb_server() {
	received := simple_tcp_client(path: '/') or {
		assert err.msg() == ''
		return
	}
	assert_common_headers(received)
	assert received.contains('Content-Type: text/plain')
	assert received.contains('Content-Length: 15')
	assert received.ends_with('Welcome to VWeb')
}

fn test_a_simple_tcp_client_simple_route() {
	received := simple_tcp_client(path: '/simple') or {
		assert err.msg() == ''
		return
	}
	assert_common_headers(received)
	assert received.contains('Content-Type: text/plain')
	assert received.contains('Content-Length: 15')
	assert received.ends_with('A simple result')
}

fn test_a_simple_tcp_client_zero_content_length() {
	// tests that sending a content-length header of 0 doesn't hang on a read timeout
	watch := time.new_stopwatch(auto_start: true)
	simple_tcp_client(path: '/', headers: 'Content-Length: 0\r\n\r\n') or {
		assert err.msg() == ''
		return
	}
	assert watch.elapsed() < 1 * time.second
}

fn test_a_simple_tcp_client_html_page() {
	received := simple_tcp_client(path: '/html_page') or {
		assert err.msg() == ''
		return
	}
	assert_common_headers(received)
	assert received.contains('Content-Type: text/html')
	assert received.ends_with('<h1>ok</h1>')
}

// net.http client based tests follow:
fn assert_common_http_headers(x http.Response) ! {
	assert x.status() == .ok
	assert x.header.get(.server)! == 'VWeb'
	assert x.header.get(.content_length)!.int() > 0
	assert x.header.get(.connection)! == 'close'
}

fn test_http_client_index() {
	x := http.get('http://${localserver}/') or { panic(err) }
	assert_common_http_headers(x)!
	assert x.header.get(.content_type)! == 'text/plain'
	assert x.body == 'Welcome to VWeb'
}

fn test_http_client_404() {
	url_404_list := [
		'http://${localserver}/zxcnbnm',
		'http://${localserver}/JHKAJA',
		'http://${localserver}/unknown',
	]
	for url in url_404_list {
		res := http.get(url) or { panic(err) }
		assert res.status() == .not_found
	}
}

fn test_http_client_simple() {
	x := http.get('http://${localserver}/simple') or { panic(err) }
	assert_common_http_headers(x)!
	assert x.header.get(.content_type)! == 'text/plain'
	assert x.body == 'A simple result'
}

fn test_http_client_html_page() {
	x := http.get('http://${localserver}/html_page') or { panic(err) }
	assert_common_http_headers(x)!
	assert x.header.get(.content_type)! == 'text/html'
	assert x.body == '<h1>ok</h1>'
}

fn test_http_client_settings_page() {
	x := http.get('http://${localserver}/bilbo/settings') or { panic(err) }
	assert_common_http_headers(x)!
	assert x.body == 'username: bilbo'
	//
	y := http.get('http://${localserver}/kent/settings') or { panic(err) }
	assert_common_http_headers(y)!
	assert y.body == 'username: kent'
}

fn test_http_client_user_repo_settings_page() {
	x := http.get('http://${localserver}/bilbo/gostamp/settings') or { panic(err) }
	assert_common_http_headers(x)!
	assert x.body == 'username: bilbo | repository: gostamp'
	//
	y := http.get('http://${localserver}/kent/golang/settings') or { panic(err) }
	assert_common_http_headers(y)!
	assert y.body == 'username: kent | repository: golang'
	//
	z := http.get('http://${localserver}/missing/golang/settings') or { panic(err) }
	assert z.status() == .not_found
}

struct User {
	name string
	age  int
}

fn test_http_client_json_post() {
	ouser := User{
		name: 'Bilbo'
		age: 123
	}
	json_for_ouser := json.encode(ouser)
	mut x := http.post_json('http://${localserver}/json_echo', json_for_ouser) or { panic(err) }
	$if debug_net_socket_client ? {
		eprintln('/json_echo endpoint response: ${x}')
	}
	assert x.header.get(.content_type)! == 'application/json'
	assert x.body == json_for_ouser
	nuser := json.decode(User, x.body) or { User{} }
	assert '${ouser}' == '${nuser}'
	//
	x = http.post_json('http://${localserver}/json', json_for_ouser) or { panic(err) }
	$if debug_net_socket_client ? {
		eprintln('/json endpoint response: ${x}')
	}
	assert x.header.get(.content_type)! == 'application/json'
	assert x.body == json_for_ouser
	nuser2 := json.decode(User, x.body) or { User{} }
	assert '${ouser}' == '${nuser2}'
}

fn test_http_client_multipart_form_data() {
	boundary := '6844a625b1f0b299'
	name := 'foo'
	ct := 'multipart/form-data; boundary=${boundary}'
	contents := 'baz buzz'
	data := '--${boundary}\r
Content-Disposition: form-data; name="${name}"\r
\r
${contents}\r
--${boundary}--\r
'
	mut x := http.fetch(
		url: 'http://${localserver}/form_echo'
		method: .post
		header: http.new_header(
			key: .content_type
			value: ct
		)
		data: data
	)!
	$if debug_net_socket_client ? {
		eprintln('/form_echo endpoint response: ${x}')
	}
	assert x.body == contents
}

fn test_http_client_shutdown_does_not_work_without_a_cookie() {
	x := http.get('http://${localserver}/shutdown') or {
		assert err.msg() == ''
		return
	}
	assert x.status() == .not_found
	assert x.body == '404 Not Found'
}

fn testsuite_end() {
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

// utility code:
struct SimpleTcpClientConfig {
	retries int    = 20
	host    string = 'static.dev'
	path    string = '/'
	agent   string = 'v/net.tcp.v'
	headers string = '\r\n'
	content string
}

fn simple_tcp_client(config SimpleTcpClientConfig) !string {
	mut client := &net.TcpConn(0)
	mut tries := 0
	for tries < config.retries {
		tries++
		eprintln('> client retries: ${tries}')
		client = net.dial_tcp(localserver) or {
			if tries > config.retries {
				return err
			}
			time.sleep(100 * time.millisecond)
			continue
		}
		break
	}
	if client == unsafe { nil } {
		eprintln('coult not create a tcp client connection to ${localserver} after ${config.retries} retries')
		exit(1)
	}
	client.set_read_timeout(tcp_r_timeout)
	client.set_write_timeout(tcp_w_timeout)
	defer {
		client.close() or {}
	}
	message := 'GET ${config.path} HTTP/1.1
Host: ${config.host}
User-Agent: ${config.agent}
Accept: */*
${config.headers}
${config.content}'
	$if debug_net_socket_client ? {
		eprintln('sending:\n${message}')
	}
	client.write(message.bytes())!
	read := io.read_all(reader: client)!
	$if debug_net_socket_client ? {
		eprintln('received:\n${read}')
	}
	return read.bytestr()
}
