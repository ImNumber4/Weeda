<?php
class Controller
{
    protected $_model;
	protected $_controller;
	protected $_action;
	protected $_template;
	
	protected $model;

	function __construct($model, $controller, $action) {
		$this->_controller = $controller;
	    $this->_action = $action;
	    $this->_model = ucwords($model);
					
	    // $this->$model = new $model;
	    // $this->_template = new Template($controller, $action);
	}
	
	protected function getCurrentUser(){
		$currentUser_id = $_COOKIE['user_id'];
		if (!isset($currentUser_id)) {
			error_log('current user is not set');
			header("Content-type: application/json");
			http_response_code(400);
			return;
		}
		return $currentUser_id;
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