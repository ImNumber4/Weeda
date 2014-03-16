<?php
// Simple bootstrap file PHP 5 (with no template engine)
// stop error reporting for curious eyes, should be set to E_ALL when debugging
error_reporting(0);
// name of folder that application class files reside in
define('CLASSDIR', 'controller');
// application absolute path to source files (should reside on a folder one level behind the public one)
define('BASEDIR', @realpath(dirname(__FILE__).'/../'.CLASSDIR).'/');
// function to autoload classes (getting rid of include() calls)
function __autoload($class)
{
	$file = BASEDIR.$class.'.php';
	if (!file_exists($file))
	{
		echo 'Requested module \''.$class.'\' is missing. Execution stopped.';
		exit();
	}
	require($file);
}
// the router code, breaks request uri to parts and retrieves the specific class, method and arguments
// $route = '';
// $class = '';
// $method = '';
// $args = null;
// $cmd_path = BASEDIR;
// $fullpath = '';
// $file = '';
// if (empty($_GET['route'])) $route = 'index'; else $route = $_GET['route'];
// $route = trim($route, '/\\');
// $parts = explode('/', $route);
// foreach($parts as $part)
// {
// 	$part = str_replace('-', '_', $part);
// 	$fullpath .= $cmd_path.$part;
// 	if (is_dir($fullpath))
// 	{
// 		$cmd_path .= $part.'/';
// 		array_shift($parts);
// 		continue;
// 	}
// 	if (is_file($fullpath.'.php'))
// 	{
// 		$class = $part;
// 		array_shift($parts);
// 		break;
// 	}
// }
// if (empty($class)) $class = 'index';
// $action = array_shift($parts);
// $action = str_replace('-', '_', $action);
// if (empty($action)) $action = 'index';
// $file = $cmd_path.$class.'.php';
// $args = $parts;
// // now that we have the parts, let's run a few more test and then execute the function in the class file
// if (is_readable($file) == false)
// {
// 	echo 'Requested module \''.$class.'\' is missing. Execution stopped.';
// 	exit();
// }
// // load the requested file
// $class = new $class();
// if (is_callable(array($class, $action)) == false)
// {
// 	// function not found in controller, set it as index and send it to args
// 	array_unshift($args, $action);
// 	$action = 'index';
// }
// // Run action
// $class->$action($args);
?>