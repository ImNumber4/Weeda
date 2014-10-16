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
	private $description;
	private $storename;
	private $address_street;
	private $address_city;
	private $address_state;
	private $address_country;
	private $address_zip;
	private $phone;
	private $user_type;
	private $latitude;
	private $longitude;
	
	public static $TYPE_USER = 'user';
	
	public function get_id() {
		return $this->id;
	}
	
	public function set_id($id) {
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
	
	public function get_description() {
		return $this->description;
	}
	
	public function set_description($description) {
		$this->description = $description;
	}
	
	public function get_latitude() {
		return $this->latitude;
	}
	
	public function set_latitude($latitude) {
		$this->latitude = $latitude;
	}
	
	public function get_longitude() {
		return $this->longitude;
	}
	
	public function set_longitude($longitude) {
		$this->longitude = $longitude;
	}
	
	public function get_storename() {
		return $this->storename;
	}
	
	public function set_storename($longitude) {
		$this->storename = $longitude;
	}
	
	public function get_address_street() {
		return $this->address_street;
	}
	
	public function set_address_street($address_street) {
		$this->address_street = $address_street;
	}
	
	public function get_address_city() {
		return $this->address_city;
	}
	
	public function set_address_city($address_city) {
		$this->address_city = $address_city;
	}
	
	public function get_address_state() {
		return $this->address_state;
	}
	
	public function set_address_state($address_state) {
		$this->address_state = $address_state;
	}
	
	public function get_address_country() {
		return $this->address_country;
	}
	
	public function set_address_country($address_country) {
		$this->address_country = $address_country;
	}
	
	public function get_address_zip() {
		return $this->address_zip;
	}
	
	public function set_address_zip($address_zip) {
		$this->address_zip = $address_zip;
	}
	
	public function get_phone() {
		return $this->phone;
	}
	
	public function set_phone($phone) {
		$this->phone = $phone;
	}
	
	
	public function get_user_type() {
		return $this->user_type;
	}
	
	public function set_user_type($user_type) {
		$this->user_type = $user_type;
	}
	
}
?>