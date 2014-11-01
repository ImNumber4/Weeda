<?php
// ini_set('display_errors',1);
// error_reporting(E_ALL);

define('DS', DIRECTORY_SEPARATOR);
define('SYSTEM', dirname(dirname(__FILE__)));

//Load Configuration File
require (SYSTEM . DS . 'WeedaService/library' . DS . 'bootstrap.php');

$request = new Request();
error_log('Url elements: ' . print_r($_SERVER['REQUEST_URI'], true));
error_log('Method: ' . $request->verb);
error_log('Incoming param: ' . print_r($request->parameters, true));


Hook($request);

function Hook($request) {
	
	header('Content-Type: application/json');
    
    if(!empty($request)){
        $controller = $request->controller;
        $action = $request->action;
        
        //check the authentication
        if ($action != 'login' && $action != 'signup' && $action != 'hasUsername' && $action != 'hasEmail') {
        	$currentUser_id = $_COOKIE[Controller::$USER_ID_COOKIE_NAME];
        	if (!isset($currentUser_id)) {
				error_log('Please log first. url: ' . $url);
        		http_response_code(401);
        		return;
        	}
        }

        $controllerName = $controller;
        $controller = ucwords($controller).'Controller';
        $model = $controllerName;
		
		try {
			$dispatch = new $controller($model,$controllerName,$action);
			
	        if ((int)method_exists($controller, $action)) {
            	$response = call_user_func_array(array($dispatch, $action) , $request->parameters);
				http_response_code(200);
				echo $response;
	        } else {
				http_response_code(405);
				echo "Method does not exist.";
	        }
		} catch (InvalidRequestException $e) {
			error_log($e->toString());
			http_response_code(400);
			echo $e->getMessage();
		} catch (Exception $e) {
			error_log($e->toString());
			http_response_code(500);
			echo $e->getMessage();
		}
    }else{
		http_response_code(400);
		echo "Url Arr is empty.";
    }
}

/**
* Http Request Class
*/
class Request
{
	public $controller;
	public $action;
	public $method;
	public $parameters;
	
	function __construct()
	{
		$this->verb = $_SERVER['REQUEST_METHOD'];
		// $this->url_elements = explode('/', $_SERVER['REQUEST_URI']);
		$this->parameters = array();
		$this->parseUrlParams();
		$this->parseIncomingParams();
		$this->format = 'json';
		if (isset($this->parameters['format'])) {
			$this->format = $this->paramters['format'];
		}
		return true;
	}
	
	private function parseUrlParams()
	{
		$url_array = explode('?', $_SERVER['REQUEST_URI']);
		$url_elements = explode('/', $url_array[0]);
		
		$this->controller = $url_elements[1];
		$this->action = $url_elements[2];
		
		$count = count($url_elements);
		for ($i = 3; $i < $count; $i++) {
			$this->parameters[] = $url_elements[$i];
		}
	}
	
	public function parseIncomingParams()
	{
		
		$parameters = array();
		
		if (isset($_SERVER['QUERY_STRING'])) {
			parse_str($_SERVER['QUERY_STRING'], $parameters);
		}
		
		$body = file_get_contents('php://input');
		
		$content_type = false;
		if (isset($_SERVER['CONTENT_TYPE'])) {
			$content_type = $_SERVER['CONTENT_TYPE'];
		}
		switch ($content_type) {
			case "application/json":
				$body_params = json_decode($body);
				if ($body_params) {
					foreach ($body_params as $params_name => $param_value) {
						$parameters[$params_name] = $param_value;
					}
				}
				$this->format = "json";
				break;
			
			default:
				error_log('Incoming data is not json, do not support this now');
				break;
		}
		
		if (count($parameters) > 0) {
			$this->parameters[] = $parameters;
		}
	}
}


?>