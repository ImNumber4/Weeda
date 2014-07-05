<?php
	
class ImageController extends Controller
{
	private $UPLOAD_BASE_PATH = './upload/';
	
	public function query($image_url)
	{
		if (!isset($image_url)) {
			throw new InvalidRequestException('Input error, image_url is null');
		}
		
		$weed_image = $this->getImageForServer($image_url);
		if (!$weed_image) {
			error_log('Image not exist. image url: ' . $image_url);
			throw new InvalidRequestException('Image not exist');
		}
		
		$image['url'] = $image_url;
		$image['image'] = $weed_image;
		
		return json_encode(array('image' => $image));
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
			if (!$user_id || !$weed_id || ($count == null)) {
				error_log('Invalid url, url: ' . $image_url);
				return null;
			}
			$filename = $this->get_weed_image_filename($user_id, $weed_id, $count);
		} else if ($type == 'avatar') {
			# code...
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
		ob_start();
		imagejpeg($image, null, 100);
		$contents =  ob_get_contents();
		ob_end_clean();
		
		imagedestroy($image);
		return base64_encode($contents);
	}
	
	private function get_weed_image_filename($user_id, $weed_id, $count)
	{
		return $this->UPLOAD_BASE_PATH . $user_id . '/' . $weed_id . '/' . $count . '.jpeg';
	}
}

?>