<?php

decodeJson();


function decodeJson()
{
	$json = '{"id":100,"content":"TestAdd","time":"2014-03-30 12:32:10","user":{"userid":"1","username":"lv"}}';
	
	$data = json_decode($json);
	var_dump($data);
	
	$body = array();
	
	$user = $data->user;
	var_dump($user);
	echo $user->userid;
	
	
	//echo var_dump($data);
	// foreach ($data as $key => $value) { 
	// 		if (is_object($value)) {
	// 			foreach($value as $k => $v) {
	// 				$body[] = [$k => $v];
	// 			}
	// 		}
	// 	    $body[] = [$key => $value];
	// 	}
	// echo var_dump($body);
}



function sendPostRequest($value='')
{
	$serviceURL = 'http://localhost/weed/create';

	$time = date('Y-m-d H:i:s');
	echo $time;
	echo '\n';

	$postData = array(
	    'content' => 'The second post.',
	    'user_id' => '2'
	);
	echo var_dump($postData);
	echo '\n';

	$ch = curl_init ( $serviceURL );
	curl_setopt_array($ch, array(
	    CURLOPT_POST => TRUE,
	    CURLOPT_RETURNTRANSFER => TRUE,
	    CURLOPT_HTTPHEADER => array(
	        'Content-Type: application/json'
	    ),
	    CURLOPT_POSTFIELDS => json_encode($postData)
	));
	// curl_setopt ( $ch, CURLOPT_CUSTOMREQUEST, "POST" );
	// curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, true );
	// curl_setopt ( $ch, CURLOPT_SSL_VERIFYPEER, false );
	// curl_setopt ( $ch, CURLOPT_SSL_VERIFYHOST, false );
	// curl_setopt ( $ch, CURLOPT_HTTPHEADER, array (
	//         'Content-Type:application/json; charset=UTF-8'
	//         // 'Content-Length: ' . strlen ( $data ) 
	// ) );
	// curl_setopt ($ch, CURLOPT_POSTFIELDS, json_encode($postData));


	$result = curl_exec ( $ch );
	$errorNo = curl_errno ( $ch );
	curl_close ( $ch );
}

?>