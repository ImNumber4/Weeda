<?php

include './library/NotificationHelper.php';
class Controller
{
    protected $_model;
	protected $_controller;
	protected $_action;
	protected $_template;
	
	protected $model;
	
	protected $user_dao;

	function __construct($model, $controller, $action) {
		$this->_controller = $controller;
	    $this->_action = $action;
	    $this->_model = ucwords($model);
		$this->user_dao = new UserDAO();			
	    // $this->$model = new $model;
	    // $this->_template = new Template($controller, $action);
	}
	
	protected function getCurrentUser(){
		$currentUser_id = $_COOKIE['user_id'];
		if (!isset($currentUser_id)) {
			throw new DependencyDataMissingException('current user is not set');
		}
		return $currentUser_id;
	}
	
		
	protected function getCurrentUsername(){
		$currentUsername= $_COOKIE['username'];
		if (!isset($currentUsername)) {
			throw new DependencyDataMissingException('current username is not set');
		}
		return $currentUsername;
	}
	
	protected function sendNotificationToUser($username, $user_id, $message) {
		if ($user_id)
			$devices = $this->user_dao->getUserDevicesByUserId($user_id);
		else if ($username)
			$devices = $this->user_dao->getUserDevicesByUsername($username);
		foreach ($devices as &$device) {
		    NotificationHelper::sendMessage($device['device_id'], $message);
		}
	}
	
	// function set($name,$value) {
	//         $this->_template->set($name,$value);
	// }
	// 
	// function __destruct() {
	// 	$this->_template->render();
	// }
	// 
	// function load($modelArray=''){
	//     if(empty($modelArray)){
	//         return false;
	//     }else if(is_array($modelArray)){
	//     	foreach($modelArray as $model){
	//             $this->$model = new $model;
	//         }
	//     }else{
	//         $this->$modelArray = new $modelArray;
	//     }
	// }
}
?>