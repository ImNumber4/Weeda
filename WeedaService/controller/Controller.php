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
	    $model = ucwords($model);
					
		if ($_SERVER['REQUEST_METHOD'] === 'POST') {
			error_log('Create model instance '. $model);
			$data = json_decode(file_get_contents('php://input'));
			$this->model = new $model($data);
		}
	    // $this->$model = new $model;
	    // $this->_template = new Template($controller, $action);
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