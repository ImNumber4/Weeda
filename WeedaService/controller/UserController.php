<?php

include './library/ImageHandler.php';

//ini_set('display_errors',1);
//error_reporting(E_ALL);

class UserController extends Controller
{
	
    function __construct($model, $controller, $action) 
    {
		parent::__construct($model, $controller, $action);
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
	
	public function queryUsersWithCoordinates($latitude, $longitude, $range, $search_key) {
		if (!isset($latitude) || !isset($longitude) || !isset($range)) {
			throw new InvalidRequestException('Input error, latitude or longitude or range is null.');
		}
		
		$users = $this->user_dao->get_users_with_coordinate($latitude, $longitude, $range, $search_key);
		if($users)
			return json_encode(array('users' => $users));
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
	
	public function getFollowingUsers($user, $count){
		$currentUser_id = $this->getCurrentUser();
		$users = $this->user_dao->get_following_usernames($user, $currentUser_id, $count);
		if ($users)
			return json_encode(array('users' => $users));
		else
			return json_encode(array('users' => []));
	}
	
	public function getFollowers($user, $count){
		$currentUser_id = $this->getCurrentUser();
		$users = $this->user_dao->get_follower_usernames($user, $currentUser_id, $count);
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
			$this->update_cookie($user);
			return json_encode(array("user" => $user));
		} else {
			throw new InvalidRequestException('user/password do not match record.');
		}
	}

	public function signout() {		
		try {
			$currentUser_id = $this->getCurrentUser();
			setcookie(Controller::$USER_ID_COOKIE_NAME, '', time() - 3600);
			setcookie(Controller::$USERNAME_COOKIE_NAME, '', time() - 3600);
			setcookie(Controller::$PASSWORD_COOKIE_NAME, '', time() - 3600);
		} catch (DependencyDataMissingException $e) {
			//already log out.
			return;
		}
	}
	
	public function signup() {
		$data = $this->parse_body_request();
		$invalidReasons = $this->check_para($data);
		if (!empty($invalidReasons)) {
			throw new InvalidRequestException("Inputs are not valid due to $invalidReasons");
		}
		$user = $this->convert_data_to_user($data);
		$result = $this->user_dao->create($user);
		$user->set_id($result);
		$userPropertyMap = array('id'=>$user->get_id(), 'username'=>$user->get_username(), 'password'=>$user->get_password());
		$this->update_cookie($userPropertyMap);	
		
		return json_encode(array('user' => $user));
	}
	
	private function update_cookie($user){
		error_log($user['id']);
				error_log($user['username']);
				error_log($user['password']);
		setcookie(Controller::$USER_ID_COOKIE_NAME, $user['id'], time() + (86400 * 7), '/');
		setcookie(Controller::$USERNAME_COOKIE_NAME, $user['username'], time() + (86400 * 7), '/');
		setcookie(Controller::$PASSWORD_COOKIE_NAME, $user['password'], time() + (86400 * 7), '/');
	}
	
	public function updateUsername($username) {
		$user_id = $this->getCurrentUser();
		$password = $this->getCurrentUserPassword();
		$this->user_dao->updateUsername($user_id, $username);
		$user = array();
		$user['id'] = $user_id;
		$user['password'] = $password;
		$user['username'] = $username;
		$this->update_cookie($user);
	}
	
	public function update() {
		$data = $this->parse_body_request();
		$invalidReasons = $this->check_para($data);
		if (!empty($invalidReasons)) {
			return json_encode(array('errors' => $invalidReasons));
		}
		$user = $this->convert_data_to_user($data);
		$user_id = $this->getCurrentUser();
		if ($user_id != $user->get_id()) {
			throw new InvalidRequestException('Current user id is '. $user_id . ' and it is trying to modify user data for user id ' . $user->get_id() . '.');
		}
		$result = $this->user_dao->update($user);
		return json_encode(array('errors' => array()));
	}
	
	public function upload() {
		$user_id = $this->getCurrentUser();
		
		error_log('Image name: ' . $_FILES['avatar']['name']);
		error_log('Image type: ' . $_FILES['avatar']['type']);
		error_log('Image size: ' . $_FILES['avatar']['size']);
		error_log('Image tmp name: ' . $_FILES['avatar']['tmp_name']);
		
		if (!saveAvatarToServer($_FILES['avatar'], $user_id)) {
			throw new DependencyFailureException('Failed to store avatar.');
		}
		
		$this->user_dao->update_has_avatar($user_id);
	}
	
	public function hasUsername($username) {
		if (!isset($username)) {
			throw new InvalidRequestException('Input error, username is null');
		}
		$exist = $this->user_dao->username_exist($username);
		return json_encode(array('exist' => $exist));
	}
	
	public function hasEmail($email) {
		if (!isset($email)) {
			throw new InvalidRequestException('Input error, email is null');
		}
		$exist = $this->user_dao->email_exist($email);
		return json_encode(array('exist' => $exist));
	}
	
	private function parse_body_request() {
		if ($_SERVER['REQUEST_METHOD'] != 'POST' && $_SERVER['REQUEST_METHOD'] != 'PUT') {
			throw new InvalidRequestException('request has to be either POST or PUT.');
		}
		
		return json_decode(file_get_contents('php://input'));
	}
	
	private function convert_data_to_user($data) {
		$user = new User();
		$user->set_id($data->id);
		$user->set_username($data->username);
		$user->set_password($data->password);
		$user->set_email($data->email);
		$user->set_time($data->time);
		if(!$data->deleted)
			$user->set_deleted(0);
		else
			$user->set_deleted($data->deleted);
		$user->set_has_avatar($data->has_avatar);
		$user->set_description($data->description);
		$user->set_storename($data->storename);
		$user->set_address_street($data->address_street);
		$user->set_address_city($data->address_city);
		$user->set_address_state($data->address_state);
		$user->set_address_country($data->address_country);
		$user->set_address_zip($data->address_zip);
		$user->set_phone($data->phone);
		$user->set_user_type($data->user_type);
		$user->set_latitude($data->latitude);
		$user->set_longitude($data->longitude);
		return $user;
	}
	
	private function check_para($data) {
		$invalidReasons = array();
		
		$username = trim($data->username);
		if ($username == '') {
			$invalidReasons[] = 'Username can not be empty';
		}
		
		$password = trim($data->password);
		if ($password == '') {
			$invalidReasons[] = 'Password can not be empty';
		}
		
		$email = trim($data->email);
		if ($email == '') {
			$invalidReasons[] = 'Email can not be empty';
		} else {
			if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
			    $invalidReasons[] = "Email address $email is not valid.";
			}
		}
		
		$time = trim($data->time);
		if ($time == '') {
			$invalidReasons[] = 'Time can not be empty';
		}
		
		$user_type = trim($data->user_type);
		if ($user_type && $user_type != User::$TYPE_USER) {
			$storename = trim($data->storename);
			if ($storename == '') {
				$invalidReasons[] = 'Storename can not be empty';
			}
			$address_street = trim($data->address_street);
			if ($address_street == '') {
				$invalidReasons[] = 'Street can not be empty';
			}
			$address_city = trim($data->address_city);
			if ($address_city == '') {
				$invalidReasons[] = 'City can not be empty';
			}
			$address_state = trim($data->address_state);
			if ($address_state == '') {
				$invalidReasons[] = 'State can not be empty';
			}
			$address_country = trim($data->address_country);
			if ($address_country == '') {
				$invalidReasons[] = 'Country can not be empty';
			}
			$address_zip = trim($data->address_zip);
			if ($address_zip == '') {
				$invalidReasons[] = 'ZIP code can not be empty';
			}
			$phone = trim($data->phone);
			if ($phone == '') {
				$invalidReasons[] = 'Phone can not be empty';
			}
			$latitude = trim($data->latitude);
			if ($latitude == '') {
				$invalidReasons[] = 'Latitude can not be empty';
			}
			$longitude = trim($data->longitude);
			if ($longitude == '') {
				$invalidReasons[] = 'Longitude can not be empty';
			}
		}
		
		return $invalidReasons;
	}
}
?>