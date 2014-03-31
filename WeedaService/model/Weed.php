<?php
class Weed
{	
	private $id;
	
	private $content;
	
	private $user_id;
	
	private $time;
	
	public function __construct($postData) {
		error_log("Create model weed: " . $postData->content . "  " . $postData->time . "  " . $postData->user->userid);
		$this->content = $postData->content;
		$this->user_id = $postData->user->userid;
		$this->time = $postData->time;
	}
	
	public function set_id($id) {
		$this->id = $id;
	}
	
	public function get_id() {
		return $this->id;
	}
	
	public function set_content($content) {
		$this->content = $content;
	}
	
	public function get_content() {
		return $this->content;
	}
	
	public function set_user_id($user_id) {
		$this->user_id = $user_id;
	}
	
	public function get_user_id() {
		return $this->user_id;
	}
	
	public function set_time($time) {
		$this->time = $time;
	}
	
	public function get_time() {
		return $this->time;
	}
}
?>