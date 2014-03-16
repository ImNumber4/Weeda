<?php

define('DS', DIRECTORY_SEPARATOR);
define('SYSTEM', dirname(dirname(__FILE__)));

//Get URL
$url = isset($_GET['url']) ? $_GET['url']: '';

//Load Configuration File
require_once (SYSTEM . DS . 'WeedaService/library' . DS . 'bootstrap.php');

Hook($url);

function Hook($url) {
	
    $urlArr = array();

    $urlArr = explode("/",$url);
    
    if(!empty($urlArr)){
        $controller = array_shift($urlArr); 
        $action = array_shift($urlArr);     
        $stringParameter = $urlArr;

        $controllerName = $controller;
        $controller = ucwords($controller).'Controller';
        $model = trim($controller);

        $dispatch = new $controller($model,$controllerName,$action);

        if ((int)method_exists($controller, $action)) {
            call_user_func_array(array($dispatch,$action),$stringParameter);
        } else {
			echo "Method does not exist.";
        }
    }else{
		echo "Url Arr is empty.";
    }
}

?>