<?php
class controller
{
    protected $_model;
	protected $_controller;
	protected $_action;
	protected $_template;

	function __construct($model, $controller, $action) {
		$this->_controller = $controller;
	    $this->_action = $action;
	    $this->_model = $model;
	    //$this->$model = new $model;
	    //$this->_template = new Template($controller, $action);
	}
	
	function set($name,$value) {
        $this->_template->set($name,$value);
	}

	function __destruct() {
		$this->_template->render();
	}
	
	function load($modelArray=''){
	    if(empty($modelArray)){
	        return false;
	    }else if(is_array($modelArray)){
	    	foreach($modelArray as $model){
	            $this->$model = new $model;
	        }
	    }else{
	        $this->$modelArray = new $modelArray;
	    }
	}
}
?>