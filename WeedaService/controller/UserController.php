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
	
	public function getUsersWaterWeed($weed_id) {
		$currentUser_id = $_COOKIE['user_id'];
		if (!isset($currentUser_id)) {
			error_log('current user is not set');
			header("Content-type: application/json");
			http_response_code(400);
			return;
		}
		$userDAO = new UserDAO();
		$users = $userDAO->getUsersWaterWeed($currentUser_id, $weed_id);
		header('Content-type: application/json');
		http_response_code(200);
		echo json_encode(array('users'=>$users));
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
			setcookie('username', $user['username'], time() + (86400 * 7), '/');
			setcookie('password', $user['password'], time() + (86400 * 7), '/');
			header('Content-type: application/json');
			http_response_code(200);
			echo json_encode(array("user" => $user));
		} else {
			//username password is wrong.
			http_response_code(401);
			header('Content-type: application/json');
		}
	}

	public function signout() {
		$user_id = $_COOKIE['user_id'];
		if (!isset($user_id)) {
			//already log out.
			return;
		}
		
		setcookie('user_id', '', time() - 3600);
	}
	
	public function signup() {
		$user = $this->parse_body_request();
		if ($user == null) {
			http_response_code(500);
			return;
		}
		
		$userDAO = new UserDAO();
		$result = $userDAO->create($user);
		if ($result == 0) {
			//return 500
			error_log("Create weed failed.");
			http_response_code(500);
			return;
		}
		
		$user->set_id($result);
		setcookie('user_id', $result, time() + (86400 * 7), '/');
		setcookie('username', $user->get_username(), time() + (86400 * 7), '/');
		setcookie('password', $user->get_password(), time() + (86400 * 7), '/');	
		header('Content-type: application/json');
		http_response_code(200);
		echo json_encode(array('user' => $user));
	}
	
	public function username($username) {
// 		$data = json_decode(file_get_contents('php://input'));
// 		$username = $data->username;
		if (!isset($username)) {
			error_log('Input error, username is null');
			http_response_code(400);
			return;
		}
		$userDAO = new UserDAO();
		$exist = $userDAO->username_exist($username);
		
		header("Content-type: application/json");
		http_response_code(200);
		echo json_encode(array('exist' => $exist));
	}
	
	private function parse_body_request() {
		if ($_SERVER['REQUEST_METHOD'] != 'POST' && $_SERVER['REQUEST_METHOD'] != 'PUT') {
			//request method error, return 400
			error_log("Request method error, should use POST or PUT.");
			return null;
		}
		
		$data = json_decode(file_get_contents('php://input'));
		if (!$this->check_para($data)) {
			//return 400
			error_log("Input error.");
			return null;
		}
		
		$user = new User();
		$user->set_username($data->username);
		$user->set_password($data->password);
		$user->set_email($data->email);
		$user->set_time($data->time);
		$user->set_deleted(0);
		return $user;
	}
	
	private function check_para($data) {
		$username = trim($data->username);
		if ($username == '') {
			error_log('Input error, username is null.');
			return false;
		}
		
		$password = trim($data->password);
		if ($password == '') {
			error_log('Input error, password is null');
			return false;
		}
		
		$email = trim($data->email);
		if ($email == '') {
			error_log('Input error, email is null');
			return false;
		}
		
		$time = trim($data->time);
		if ($time == '') {
			error_log('Input error, time is null');
			return false;
		}
		
		return true;
	}
}
?>