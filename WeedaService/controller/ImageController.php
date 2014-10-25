<?php

// ini_set('display_errors',1);
// error_reporting(E_ALL);

include './library/ImageHandler.php';

class ImageController extends Controller
{
	private $UPLOAD_BASE_PATH = './upload/';
	
	public function upload($weed_id)
	{
		$user_id = $this->getCurrentUser();
		
		error_log('Image name: ' . $_FILES['image']['name']);
		error_log('Image type: ' . $_FILES['image']['type']);
		error_log('Image size: ' . $_FILES['image']['size']);
		error_log('Image tmp name: ' . $_FILES['image']['tmp_name']);
		
		// $this->update_image_metadata_weed($_FILES['image'], $user_id, $weed_id);
		// if (!$this->update_image_metadata_weed($_FILES['image'], $user_id, $weed_id)) {
// 			header('Content-type: application/json');
// 			http_response_code(500);
// 			return;
// 		}

		if (!saveImageForWeedsToServer($_FILES['image'], $user_id, $weed_id)) {
			header('Content-type: application/json');
			http_response_code(500);
			return;
		}

		header('Content-type: application/json');
		http_response_code(200);
	}
	
	public function query($image_id, $parameters)
	{
		if (!isset($image_id)) {
			throw new InvalidRequestException('Input error, $image_id is null');
		}
		
		$image_quality = $parameters['quality'];
		if (!isset($image_quality)) {
			$image_quality = 25;
		}
		
		$weed_image = $this->getImageForServer($image_id);
		if (!$weed_image) {
			error_log('Image not exist. image url: ' . $image_id);
			throw new InvalidRequestException('Image not exist');
		}
		
		header('Content-Type: image/jpeg');
		ob_start();
		imagejpeg($weed_image, null, $image_quality);
		$size = ob_get_length();
		header('Content-Length: '.$size);
		ob_end_flush();
		imagedestroy($weed_image);
	}
	
	private function update_image_metadata_weed($image, $user_id, $weed_id)
	{
		$image_id = strstr($image['name'], '.', true);
		$image_url = 'weed_' . $user_id . '_' . $weed_id . '_' . $image_id;
		$size = getimagesize($image['tmp_name']);
		
		$weedDAO = new WeedDAO();
		$image_metadata = $weedDAO->getImageMetadata($weed_id);
		error_log('Image_metadata1: ' . print_r($image_metadata, true));
		$image_metadata[] = array('url'=>$image_url, 'width'=>$size[0], 'height'=>$size[1]);
		error_log('Image_metadata2: ' . print_r($image_metadata, true));
		
		$test = $weedDAO->getImageMetadata($weed_id);
		error_log('Image_metadata5: ' . print_r($test, true));
		
		return $weedDAO->setImageMetadataWeed(json_encode($image_metadata), $weed_id);
	}
	
	public function query_image_metadata($weed_id)
	{
		if (!isset($weed_id)) {
			throw new InvalidRequestException('Input error, weed_id is null');
		}
		
		$weedDAO = new WeedDAO();
		$user_id = $weedDAO->get_user_id($weed_id);
		if (!isset($user_id)) {
			error_log('Weed not exist, weed_id is' . $weed_id);
			throw new InvalidRequestException('Weed not exist, weed_id is' . $weed_id);
		}
		$image_path = $this->get_weed_image_path($user_id, $weed_id);
		$images = scandir($image_path);

		$array_image = array();
		for ($i=0; $i < count($images); $i++) {
			$image = $image_path . $images[$i];
			if (is_dir($image)) {
				continue;
			}
			$image_id = 'weed_' . $user_id . '_' . $weed_id . '_' . str_replace(strrchr($images[$i], "."), "", $images[$i]); 
			$size = getimagesize($image);
			$array_image[] = array('url'=>$image_id, 'width'=>$size[0], 'height'=>$size[1]);
		}
		
		return $array_image;
	}
	
	private function getImageForServer($image_url)
	{	
		$url_arr = array();
		$url_arr = explode('_', $image_url);
		
		if (empty($url_arr)) {
			error_log('Invalid url, url:' . $image_url);
			return null;
		}
		
		$filename = null;
		$type = array_shift($url_arr);
		if ($type == 'weed') {
			$user_id = array_shift($url_arr);
			$weed_id = array_shift($url_arr);
			$count = array_shift($url_arr);
			$quality = array_shift($url_arr);
			if (!$user_id || !$weed_id || ($count == null)) {
				error_log('Invalid url, url: ' . $image_url);
				return null;
			}
			$filename = $this->get_weed_image_filename($user_id, $weed_id, $count);
		} else if ($type == 'avatar') {
			$user_id = array_shift($url_arr);
			if (!user_id) {
				error_log('Invalid url, url: ' . $image_url);
				return null;
			}
			$filename = $this->get_avatar_filename($user_id);
		} else {
			error_log('Invalid image type, type: ' . $type);
			return null;
		}
		error_log('Image name: ' . $filename);
		$image = imagecreatefromjpeg($filename);
		if (!$image) {
			error_log('Get Image failed - Loading error.');
			return null;
		}
		return $image;
	}
	
	private function get_weed_image_filename($user_id, $weed_id, $count)
	{
		return $this->UPLOAD_BASE_PATH . $user_id . '/' . $weed_id . '/' . $count . '.jpeg';
	}
	
	private function get_weed_image_path($user_id, $weed_id)
	{
		return $this->UPLOAD_BASE_PATH . $user_id . '/' . $weed_id . '/';
	}
	
	private function get_avatar_filename($user_id)
	{
		return $this->UPLOAD_BASE_PATH . $user_id . '/avatar/avatar.jpeg';
	}
}

?>