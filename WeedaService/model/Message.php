<?php
/**
 * model for message
 */
class Message
{
	private $id;
	private $sender_id;
	private $receiver_id;
	private $message;
	private $send_time;
	private $received;
	
	public function get_id() {
		return $this->id;
	}
	
	public function set_id($id) {
		$this->id = $id;
	}
	
	public function get_sender_id() {
		return $this->sender_id;
	}
	
	public function set_sender_id($sender_id) {
		$this->sender_id = $sender_id;
	}
	
	public function get_receiver_id() {
		return $this->receiver_id;
	}
	
	public function set_receiver_id($receiver_id) {
		$this->receiver_id = $receiver_id;
	}
	
	public function get_message() {
		return $this->message;
	}
	
	public function set_message($message) {
		$this->message = $message;
	}
	
	public function get_send_time() {
		return $this->send_time;
	}
	
	public function set_send_time($send_time) {
		$this->send_time = $send_time;
	}
	
	public function get_received() {
		return $this->received;
	}
	
	public function set_received($received) {
		$this->received = $received;
	}
}

?>