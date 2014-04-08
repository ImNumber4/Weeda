<?php

class UserController extends Controller
{
	public function query($id) {
		if (!isset($id)) {
			error_log('Input error, id is null.');
			http_response_code(400);
			return;
		}
		
		$currentUser_id = $_COOKIE['user_id'];
		if (!isset($currentUser_id)) {
			error_log('current user is not set');
			header("Content-type: application/json");
			http_response_code(400);
			return;
		}
		
		$userDAO = new UserDAO();
		$user = $userDAO->find_by_id($id, $currentUser_id);
		if (!$user) {
			http_response_code(500);
			return;
		}
		
		header("Content-type: application/json");
		http_response_code(200);
		echo json_encode(array('user' => $user));
	}
	
	public function follow($id) {
		if (!isset($id)) {
			error_log('Input error, id is null.');
			http_response_code(400);
			return;
		}
		$currentUser_id = $_COOKIE['user_id'];
		if (!isset($currentUser_id)) {
			error_log('current user is not set');
			header("Content-type: application/json");
			http_response_code(400);
			return;
		}
		$userDAO = new UserDAO();
		if ($userDAO->setAFollowB($currentUser_id, $id)) {
			return $this->query($id);
		} else {
			error_log("failed to set currentUser=" . $currentUser_id . " to follow user " . $id);
			header("Content-type: application/json");
			http_response_code(500);
			return;
		}
	}
	
	public function unfollow($id) {
		if (!isset($id)) {
			error_log('Input error, id is null.');
			http_response_code(400);
			return;
		}
		$currentUser_id = $_COOKIE['user_id'];
		if (!isset($currentUser_id)) {
			error_log('current user is not set');
			header("Content-type: application/json");
			http_response_code(400);
			return;
		}
		$userDAO = new UserDAO();
		if ($userDAO->setAUnfollowB($currentUser_id, $id)) {
			return $this->query($id);
		} else {
			error_log('failed to set currentUser='. $currentUser_id. ' to unfollow user '. $id);
			header("Content-type: application/json");
			http_response_code(500);
			return;
		}
	}
	
	
	public function login() {
		$data = json_decode(file_get_contents("php://input"));
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
		
		if ($password == $user['password']) {
			//login success
			setcookie('user_id', $user['id'], time() + (86400 * 7), '/');
			header('Content-type: application/json');
			http_response_code(200);
			echo json_encode(array("user" => $user));
		} else {
			//username password is wrong.
			http_response_code(401);
			header('Content-type: application/json');
		}
	}

	public function logout() {
		$user_id = $_COOKIE['user_id'];
		if (!isset($user_id)) {
			//already log out.
			return;
		}
		
		setcookie('user_id', '', time() - 3600);
	}
	
	private function parse_body_request() {
		
	}
}
?>