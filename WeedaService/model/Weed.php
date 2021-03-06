<?php
class Weed
{	
	private $id;
	
	private $content;
	
	private $user_id;
	
	private $time;
	
	private $deleted;
	
	private $light_id;
	
	private $root_id;
	
	private $image_count;
	
	private $mentions;
	
	private $image_metadata;
	
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
	
	public function get_light_id()
	{
		return $this->light_id;
	}
	
	public function set_light_id($light_id)
	{
		$this->light_id = $light_id;
	}
	
	public function get_root_id()
	{
		return $this->root_id;
	}
	
	public function set_root_id($root_id)
	{
		$this->root_id = $root_id;
	}
	
	public function get_image_count()
	{
		return $this->image_count;
	}
	
	public function set_image_count($image_count)
	{
		$this->image_count = $image_count;
	}
	
	public function get_mentions()
	{
		return $this->mentions;
	}
	
	public function set_mentions($mentions)
	{
		$this->mentions = $mentions;
	}
	
	public function get_image_metadata()
	{
		return $this->image_metadata;
	}
	
	public function set_image_metadata($image_metadata)
	{
		$this->image_metadata = $image_metadata;
	}
}
?>