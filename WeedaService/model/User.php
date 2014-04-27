<?php
/**
 * @author tony
 *
 */
class User
{
	private $id;
	private $username;
	private $password;
	private $email;
	private $time;
	private $deleted;
	private $followerCount;
	private $followingCount;
	private $weedCount;
	private $has_avatar;
	
	public function get_id() {
		return $this->id;
	}
	
	public function set_id() {
		$this->id = $id;
	}
	
	public function get_username() {
		return $this->username;
	}
	
	public function set_username($username) {
		$this->username = $username;
	}
	
	public function get_password() {
		return $this->password;
	}
	
	public function set_password($password) {
		$this->password = $password;
	}
	
	public function get_email() {
		return $this->email;
	}
	
	public function set_email($email) {
		$this->email = $email;
	} 
	
	public function get_time() {
		return $this->time;
	}
	
	public function  set_time($time) {
		$this->time = $time;
	}
	
	public function  get_deleted() {
		return $this->deleted;
	}
	
	public function set_deleted($deleted) {
		$this->deleted = $deleted;
	}
	
	public function  get_followerCount() {
		return $this->followerCount;
	}
	
	public function set_followerCount($followerCount) {
		$this->followerCount = $followerCount;
	}
	
	public function  get_followingCount() {
		return $this->followingCount;
	}
	
	public function set_followingCount($followingCount) {
		$this->followingCount = $followingCount;
	}
	
	public function  get_weedCount() {
		return $this->weedCount;
	}
	
	public function set_weedCount($weedCount) {
		$this->weedCount = $weedCount;
	}
	
	public function get_has_avatar() {
		return $this->has_avatar;
	}
	
	public function set_has_avatar($has_avatar) {
		$this->has_avatar = $has_avatar;
	}
	
}
?>