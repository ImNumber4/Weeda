<?php

include './library/ImageHandler.php';

ini_set('display_errors',1);
error_reporting(E_ALL);

class UserController extends Controller
{
	protected $user_dao;
	
    function __construct($model, $controller, $action) 
    {
		parent::__construct($model, $controller, $action);
		$this->user_dao = new UserDAO();
    }
	
	public function query($id) {
		if (!isset($id)) {
			throw new InvalidRequestException('Input error, id is null.');
		}
		
		$currentUser_id = $this->getCurrentUser();
		
		$user = $this->user_dao->find_by_id($id, $currentUser_id);
		if($user)
			return json_encode(array('user' => $user));
	}
	
	public function registerDevice($device_id) {
		if (!isset($device_id)) {
			throw new InvalidRequestException('Input error, device_id is null.');
		}
		
		$currentUser_id = $this->getCurrentUser();
		$result = $this->user_dao->setUserDevice($currentUser_id, $device_id);
	}
	
	public function getUsernamesByPrefix($prefix){
		$currentUser_id = $this->getCurrentUser();
		$count = 10;
		$users = $this->user_dao->get_uernames_with_prefix($prefix, $count); 
		if ($users)
			return json_encode(array('users' => $users));
		else
			return json_encode(array('users' => []));
		
	}
	
	public function getFollowingUsers(){
		$currentUser_id = $this->getCurrentUser();
		$count = 10;
		$users = $this->user_dao->get_following_usernames($currentUser_id, $count);
		if ($users)
			return json_encode(array('users' => $users));
		else
			return json_encode(array('users' => []));
	}
	
	public function getUsersWaterWeed($weed_id) {
		if (!isset($weed_id)) {
			throw new InvalidRequestException('Input error, weed_id is null.');
		}
		$currentUser_id = $this->getCurrentUser();
		$users = $this->user_dao->getUsersWaterWeed($currentUser_id, $weed_id);
		if ($users)
			return json_encode(array('users' => $users));
		else
			return json_encode(array('users' => []));
	}
	
	public function getUsersSeedWeed($weed_id) {
		if (!isset($weed_id)) {
			throw new InvalidRequestException('Input error, weed_id is null.');
		}
		$currentUser_id = $this->getCurrentUser();
		$users = $this->user_dao->getUsersSeedWeed($currentUser_id, $weed_id);
		if ($users)
			return json_encode(array('users' => $users));
		else
			return json_encode(array('users' => []));
	}
	
	public function follow($id) {
		if (!isset($id)) {
			throw new InvalidRequestException('Input error, id is null.');
		}
		$currentUser_id = $this->getCurrentUser();
		$this->user_dao->setAFollowB($currentUser_id, $id);
		return $this->query($id);
	}
	
	public function unfollow($id) {
		if (!isset($id)) {
			throw new InvalidRequestException('Input error, id is null.');
		}
		$currentUser_id = $this->getCurrentUser();
		$this->user_dao->setAUnfollowB($currentUser_id, $id);
		return $this->query($id);
	}
	
	public function login() {
		$data = json_decode(file_get_contents("php://input"));
		$username = $data->username;
		$password = $data->password;
		
		if (!isset($username)) {
			throw new InvalidRequestException('Input para error, username is null');
		}
		
		if (!isset($password)) {
			throw new InvalidRequestException('Input para error, password is null');
		}
		
		$user = $this->user_dao->find_by_username($username);
		if ($user == null) {
			throw new InvalidRequestException("Did not find user by username:$username");
		}
		
		if ($password == $user['password']) {
			//login success
			setcookie('user_id', $user['id'], time() + (86400 * 7), '/');
			setcookie('username', $user['username'], time() + (86400 * 7), '/');
			setcookie('password', $user['password'], time() + (86400 * 7), '/');
			return json_encode(array("user" => $user));
		} else {
			throw new InvalidRequestException('user/password do not match record.');
		}
	}

	public function signout() {		
		try {
			$currentUser_id = $this->getCurrentUser();
			setcookie('user_id', '', time() - 3600);
		} catch (DependencyDataMissingException $e) {
			//already log out.
			return;
		}
	}
	
	public function signup() {
		$user = $this->parse_body_request();
		
		$result = $this->user_dao->create($user);
		
		$user->set_id($result);
		setcookie('user_id', $result, time() + (86400 * 7), '/');
		setcookie('username', $user->get_username(), time() + (86400 * 7), '/');
		setcookie('password', $user->get_password(), time() + (86400 * 7), '/');	
		
		return json_encode(array('user' => $user));
	}
	
	public function upload() {
		$user_id = $this->getCurrentUser();
		
		error_log('Image name: ' . $_FILES['avatar']['name']);
		error_log('Image type: ' . $_FILES['avatar']['type']);
		error_log('Image size: ' . $_FILES['avatar']['size']);
		error_log('Image tmp name: ' . $_FILES['avatar']['tmp_name']);
		
		if (!saveAvatarToServer($_FILES['avatar'], $user_id)) {
			header('Content-type: application/json');
			http_response_code(500);
			return;
		}
		
		$user = $this->user_dao->find_by_user_id($user_id);
		error_log('2');		
		if (!$user) {
			error_log('Did not find user by user id: ' . $user_id);
			header('Content-type: application/json');
			http_response_code(500);
			return;
		}
		$user->set_has_avatar(1);
		error_log('3');
		$this->user_dao->update($user);
		error_log('4');
		
		header('Content-type: application/json');
		http_response_code(200);
	}
	
	public function username($username) {
		if (!isset($username)) {
			throw new InvalidRequestException('Input error, username is null');
		}
		$exist = $this->user_dao->username_exist($username);
		return json_encode(array('exist' => $exist));
	}
	
	public function avatar($user_id) {
// 		$currentUser_id = $_COOKIE['user_id'];
		if (!isset($user_id)) {
			throw new InvalidRequestException('current user is not set');
		}
		
		//Get the user avatar
		$avatar = getAvatarFromServer($user_id, 50);
		if (!$avatar) {
			throw new DependencyFailureException('Get avatar failed.');
		}
		$image['url'] = 'http://localhost/upload/xx/xx/avatar.jpeg';
		$image['image'] = $avatar;
		
		return json_encode(array('image' => $image));
	}
	
	private function parse_body_request() {
		if ($_SERVER['REQUEST_METHOD'] != 'POST' && $_SERVER['REQUEST_METHOD'] != 'PUT') {
			throw new InvalidRequestException('request has to be either POST or PUT.');
		}
		
		$data = json_decode(file_get_contents('php://input'));
		$invalidReason = $this->check_para($data);
		if ($invalidReason) {
			throw new InvalidRequestException("Inputs are not valid due to $invalidReason");
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
			return 'Input error, username is null.';
		}
		
		$password = trim($data->password);
		if ($password == '') {
			return 'Input error, password is null';
		}
		
		$email = trim($data->email);
		if ($email == '') {
			return 'Input error, email is null';
		}
		
		$time = trim($data->time);
		if ($time == '') {
			return 'Input error, time is null';
		}
		
		return null;
	}
}
?>