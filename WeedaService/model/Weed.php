<?php
class Weed
{	
	private $id;
	
	private $content;
	
	private $user_id;
	
	private $time;
	
	private $deleted;
	
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
	
	public function get_deleted()
	{
		return $this->deleted;
	}
	
	public function set_deleted($deleted)
	{
		$this->deleted = $deleted;
	}
}
?>