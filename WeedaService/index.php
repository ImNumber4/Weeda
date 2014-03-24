<?php

define('DS', DIRECTORY_SEPARATOR);
define('SYSTEM', dirname(dirname(__FILE__)));
//Load Configuration File
require (SYSTEM . DS . 'WeedaService/library' . DS . 'bootstrap.php');

//Get URL
$url = isset($_GET['url']) ? $_GET['url']: '';
error_log('request url: '. $url);

//Get post data
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
	error_log('Post data is: ' . file_get_contents('php://input'));
}

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
        $model = $controllerName;
		
		try {
			$dispatch = new $controller($model,$controllerName,$action);
		} catch (Exception $e) {
			error_log($e->getMessage());
		}

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