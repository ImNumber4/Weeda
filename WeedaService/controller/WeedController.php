<?php

// ini_set('display_errors',1);
// error_reporting(E_ALL);

include './library/ImageHandler.php';

class WeedController extends Controller
{
	protected $weed_dao;
	protected $message_dao;
	
    function __construct($model, $controller, $action) 
    {
		parent::__construct($model, $controller, $action);
		$this->weed_dao = new WeedDAO();
		$this->message_dao = new MessageDAO();
    }
	
	public function query($user_id) {
		$current_user_id = $this->getCurrentUser();
		$weeds = $this->weed_dao->query($current_user_id, $user_id, null);
		return json_encode(array('weeds'=>$weeds));
	}
	
	public function queryByContent($keyword) {
		$current_user_id = $this->getCurrentUser();
		$weeds = $this->weed_dao->queryByContent($keyword, $current_user_id);
		return json_encode(array('weeds'=>$weeds));
	}
	
	public function trends() {
		$current_user_id = $this->getCurrentUser();
		$weeds = $this->weed_dao->trends($current_user_id);
		foreach ($weeds as &$weed) {
			$relationship = $this->user_dao->getRelationship($current_user_id, $weed['user_id']);
			$weed['relationshipWithCurrentUser'] = $relationship;
		}
		return json_encode(array('weeds'=>$weeds));
	}
	
	public function queryById($weed_id) {
		$current_user_id = $this->getCurrentUser();
		$weeds = $this->weed_dao->query($current_user_id, null, $weed_id);
		return json_encode(array('weeds'=>$weeds));
	}
	
	public function getLights($id) {
		
		$weeds = $this->weed_dao->getLights($id);

		return json_encode(array('weeds'=>$weeds));
	}
	
	public function getAncestorWeeds($id) {

		$weeds = $this->weed_dao->getAncestorWeeds($id);

		return json_encode(array('weeds'=>$weeds));
	}
	
	public function getMentions($weed_id) {
		$mentions = $this->weed_dao->getMentions($weed_id);
		return json_encode(array('mentions'=>$mentions));
	}
	
	public function create($parameters) 
	{
		//parse request body
		$weed = $this->parse_request_body($parameters);
		
		//Save weed to db
		$result = $this->weed_dao->create($weed);
		
		//Save images
		try {
			$files = $parameters["files"];
			if (isset($files)) {
				foreach($files as $id => $file) {
					$this->upload_weed_image($file, $weed->get_user_id(), $result);
				}
			}
		} catch (Exception $e) {
			$this->weed_dao->delete($result);
			delete_weed_image_dir($weed->get_user_id(), $result);
		}
		
		$currentUsername = $this->getCurrentUsername();
		$currentUser_id = $this->getCurrentUser();
		$mentions = $weed->get_mentions();
		foreach ($mentions as &$mention) {
			if ($mention != $currentUser_id) {
				$message = new Message();
				if ($weed->get_light_id() == NULL) {
					$message->set_message('@' . $currentUsername . ' mentioned you in weed: ' . $weed->get_content());
				} else {
					$message->set_message('@' . $currentUsername . ' lighted your weed: ' . $weed->get_content());
				}
				$message->set_sender_id($currentUser_id);
				$message->set_receiver_id($mention);
				$message->set_time($weed->get_time());
				$message->set_type(Message::$MESSAGE_TYPE_NOTIFICATION);
				$message->set_related_weed_id($result);
				$notification_message = $message->get_message();
				$this->message_dao->create($message, $notification_message);
			}
		}
		return json_encode(array('id' => $result));
	}
	
	public function delete($id)
	{
		$this->weed_dao->delete($id);
		$user_id = $this->getCurrentUser();
		delete_weed_image_dir($user_id, $id);
	}
	
	public function seed($weed_id) 
	{
		$currentUser_id = $this->getCurrentUser();
		$currentUsername = $this->getCurrentUsername();
		$this->weed_dao->setUserSeedWeed($currentUser_id, $weed_id);
		$weed = $this->weed_dao->find_by_id($weed_id)[0];
		if ($weed['user_id'] != $currentUser_id) {
			$message = new Message();
			$message->set_message('@' . $currentUsername . ' seeded your weed: ' . $weed['content']);
			$message->set_sender_id($currentUser_id);
			$message->set_receiver_id($weed['user_id']);
			$message->set_time(date('Y-m-d H:i:s'));
			$message->set_type(Message::$MESSAGE_TYPE_NOTIFICATION);
			$message->set_related_weed_id($weed_id);
			$notification_message = $message->get_message();
			$this->message_dao->create($message, $notification_message);
		}
	}
	
	public function unseed($weed_id) 
	{		
		$currentUser_id = $this->getCurrentUser();
		$this->weed_dao->setUserUnseedWeed($currentUser_id, $weed_id);
	}
	
	public function water($weed_id) 
	{
		$currentUser_id = $this->getCurrentUser();
		$currentUsername = $this->getCurrentUsername();
		$this->weed_dao->setUserWaterWeed($currentUser_id, $weed_id);
		$weed = $this->weed_dao->find_by_id($weed_id)[0];
		if ($weed['user_id'] != $currentUser_id) {
			$message = new Message();
			$message->set_message('@' . $currentUsername . ' watered your weed: ' . $weed['content']);
			$message->set_sender_id($currentUser_id);
			$message->set_receiver_id($weed['user_id']);
			$message->set_time(date('Y-m-d H:i:s'));
			$message->set_type(Message::$MESSAGE_TYPE_NOTIFICATION);
			$message->set_related_weed_id($weed_id);
			$notification_message = $message->get_message();
			$this->message_dao->create($message, $notification_message);
		}
	}
	
	public function unwater($weed_id) 
	{		
		$currentUser_id = $this->getCurrentUser();
		$this->weed_dao->setUserUnwaterWeed($currentUser_id, $weed_id);
	}
	
	private function parse_request_body($parameters) {
		if ($_SERVER['REQUEST_METHOD'] != 'POST' && $_SERVER['REQUEST_METHOD'] != 'PUT') {
			throw new InvalidRequestException('request has to be either POST or PUT.');
		}
		// $data = json_decode(file_get_contents('php://input'));
		$invalidReason = $this->check_para($parameters);
		if ($invalidReason) {
			throw new InvalidRequestException("Inputs are not valid due to $invalidReason");
		}
		
		$weed = new Weed();
		$weed->set_content($parameters["content"]);
		$weed->set_user_id($parameters["user_id"]);
		$weed->set_time($parameters["time"]);
		$weed->set_id($parameters["id"]);
		$weed->set_deleted(0);
		$weed->set_light_id($parameters["light_id"]);
		$weed->set_root_id($parameters["root_id"]);
		$weed->set_image_count($parameters["image_count"]);
		
		$mentions = array();
		if (isset($parameters["mentions"])) {
			foreach ($parameters["mentions"] as $mention) {
				$mentions[] = $mention["id"];
			}
		} 
		$weed->set_mentions($mentions);
		
		$metadata = array();
		$files = $parameters["files"];
		foreach($parameters["images"] as $image) {
			$id = $image["id"];
			$file = $files[$id];
			if (!$file) {
				continue;
			}
			list($width, $height) = getimagesize($file['tmp_name']);
			$metadata[] = array('id'=>$image["id"], 'width'=>$width, 'height'=>$height);
		}
		$weed->set_image_metadata(json_encode($metadata));
		
		return $weed;
	}
	
	private function check_para($data)
	{
		$content = trim($data['content']);
		if ($content == '') {
			return 'Input error, content is null';
		}
			
		$time = trim($data['time']);
		if ($time == '') {
			return 'Input error, time is null';
		}
		
		$user_id = trim($data['user_id']);
		if ($user_id == '') {
			return 'Input error, userid is null';
		}
		
		return null;		
	}
	
	private function upload_weed_image($file, $user_id, $weed_id)
	{
		error_log('Image name: ' . $file['name']);
		error_log('Image type: ' . $file['type']);
		error_log('Image size: ' . $file['size']);
		error_log('Image tmp name: ' . $file['tmp_name']);

		if (!saveImageForWeedsToServer($file, $user_id, $weed_id)) {
			throw new DependencyFailureException('Failed to upload image for weed ' . $weed_id);
		}
	}
}
?>