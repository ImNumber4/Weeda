<?php

class UserController extends Controller
{
	public function login() {
		$data = json_decode(file_get_contents("php://input."));
		$username = $data->username;
		$password = $data->password;
		
		if (!isset($username)) {
			error_log('Input para error, username is null');
			http_response_code(400);
			return;
		}
		
		if (!isset($password)) {
			error_log('Input para error, password is null');
			http_response_code(400);
			return;
		}
		
		$userDAO = new UserDAO();
		$user = $userDAO->find_by_username($username);
		if ($user == null) {
			error_log('Did not find user by username:' . $username);
			return;
		}
		
		if ($password == $user->get_password()) {
			//login success
			setcookie('usename', $username, time() + (86400 * 7));
			http_response_code(200);
			header('ContentType: application/json');
			echo json_encode(array('id' => $user->get_id()));
		} else {
			//username password is wrong.
			http_response_code(401);
			header('ContentType: application/json');
		}
		
	}
	
	public function logout() {
		$username = $_COOKIE['username'];
		if (!isset($username)) {
			//already log out.
			return;
		}
		
		setcookie('usename', '', time() - 3600);
	}
	
	private function parse_body_request() {
		
	}
}
?>