<?php
//ini_set('display_errors',1);
//error_reporting(E_ALL);

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
}

?>