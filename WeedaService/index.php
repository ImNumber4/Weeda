<?php
// ini_set('display_errors',1);
// error_reporting(E_ALL);

define('DS', DIRECTORY_SEPARATOR);
define('SYSTEM', dirname(dirname(__FILE__)));


//Load Configuration File
require (SYSTEM . DS . 'WeedaService/library' . DS . 'bootstrap.php');

error_log('Http request: ');
error_log(get_http_raw());

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
        
        //check the authentication
        if ($action != 'login' && $action != 'signup' && $action != 'username' ) {
        	$currentUser_id = $_COOKIE['user_id'];
        	if (!isset($currentUser_id)) {
        		header('Content-Type: application/json');
        		http_response_code(401);
        		return;
        	}
        }

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

function get_http_raw() {
    $raw = '';

    $raw .= $_SERVER['REQUEST_METHOD'].' '.$_SERVER['REQUEST_URI'].' '.$_SERVER['SERVER_PROTOCOL']."  ";

    foreach($_SERVER as $key => $value) {
        if(substr($key, 0, 5) === 'HTTP_') {
            $key = substr($key, 5);

            $key = str_replace('_', '-', $key);

            $raw .= $key.': '.$value."    ";
        }
    }

    $raw .= "    body: ";
    $raw .= file_get_contents('php://input');
    return $raw;
}


?>