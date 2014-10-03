<?php
// ini_set('display_errors',1);
// error_reporting(E_ALL);

class MessageController extends Controller
{
	protected $message_dao;
	
    function __construct($model, $controller, $action) 
    {
		parent::__construct($model, $controller, $action);
		$this->message_dao = new MessageDAO();
    }
	
	public function query() {
		$currentUser_id = $this->getCurrentUser();
		$messages = $this->message_dao->query($currentUser_id);
	    return json_encode(array('messages' => $messages));
	}
	
	public function read($message_id) {
		$currentUser_id = $this->getCurrentUser();
		$this->message_dao->mark_message_as_read($currentUser_id, $message_id);
	}
	
	public function create() {
		$message = $this->parse_create_request_body();
		$id = $this->message_dao->create($message);
	    return json_encode(array('id' => $id));
	}
	
	private function parse_create_request_body() {
		if ($_SERVER['REQUEST_METHOD'] != 'POST' && $_SERVER['REQUEST_METHOD'] != 'PUT') {
			throw new InvalidRequestException('create message request has to be either POST or PUT.');
		}
		
		$data = json_decode(file_get_contents('php://input'));
		$invalidReason = $this->check_para($data);
		if ($invalidReason) {
			throw new InvalidRequestException("Inputs are not valid due to $invalidReason");
		}
		$currentUser_id = $this->getCurrentUser();
		$message = new Message();
		$message->set_message($data->message);
		$message->set_sender_id($currentUser_id);
		$message->set_receiver_id($data->participant_id);
		$message->set_time($data->time);
		$message->set_type($data->type);
		return $message;
	}
	
	private function check_para($data)
	{	
		$message = trim($data->message);
		if ($message == '') {
			return 'Input error, message is null';
		}
			
		$time = trim($data->time);
		if ($time == '') {
			return 'Input error, time is null';
		}
		
		$participant_id = trim($data->participant_id);
		if ($participant_id == '') {
			return 'Input error, participant_id is null';
		}
		
		$type = trim($data->type);
		if ($type == '') {
			return 'Input error, type is null';
		}
		return null;		
	}
}

?>