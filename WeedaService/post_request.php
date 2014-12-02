<?php

//decodeJson();
// base64test();
$content_type_1 = "multipart/form-data; boundary=Boundary+0xAbCdEfGbOuNdArY";
$content_type_2 = "application/json; charset=utf-8";
$content_type_3 = "application/json";


echo "#####1: " . get_content_type($content_type_1);
echo "\n";
echo "#####2: " . get_content_type($content_type_2);
echo "\n";
echo "#####3: " . get_content_type($content_type_3);


// $size = getimagesize("upload/2/103/0.jpeg");
// echo 'image width: ' . $size[0] . ', image height: ' . $size[1] . "\n";
//
// // $image_path = './upload/2/136/';
//
// $dir_path = scandir('./upload/2/');
// foreach($dir_path as $dir) {
// 	$image_path = './upload/2/' . $dir . '/';
// 	if (!is_dir($image_path)) {
// 		continue;
// 	}
//
// 	$images = scandir($image_path);
// 	$array_image_metadata = array();
// 	for ($i=0; $i < count($images); $i++) {
// 		$image = $image_path . $images[$i];
// 		if (is_dir($image)) {
// 			continue;
// 		}
// 		$size = getimagesize($image);
// 		$imageId = strstr($images[$i], '.', true);
// 		$url = 'weed_2_' . $dir . '_' . $imageId;
// 		$array_image_metadata[] = array('id'=>(int)$imageId, 'width'=>$size[0], 'height'=>$size[1]);
// 	}
// 	// var_dump(json_encode($array_image_metadata));
//
// 	echo 'UPDATE weed SET image_metadata = \'' . json_encode($array_image_metadata) . '\' WHERE id=' . $dir . ';';
// 	echo "\n";
// }

echo "\n";

function get_content_type($content_type)
{
	$pos = strpos($content_type, ';');
	if (!$pos) {
		return $content_type;
	} else {
		return strstr($content_type, ';', true);
	}
}

function base64test()
{
	$filePath = 'upload/2/avatar/avatar.jpeg';
	$encode = base64_encode($filePath);
	echo  $encode . "\n";
	$decode = base64_decode($encode);
	echo $decode . "\n";
}

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