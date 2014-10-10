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
	
	public function create() 
	{
		//parse request body
		$weed = $this->parse_request_body();
		
		$result = $this->weed_dao->create($weed);

		$currentUsername = $this->getCurrentUsername();
		$currentUser_id = $this->getCurrentUser();

		foreach ($weed->get_mentions() as &$mention) {
			if ($mention != $currentUser_id) {
				$message = new Message();
				$message->set_message('@' . $currentUsername . ' mentioned you in weed: ' . $weed->get_content());
				$message->set_sender_id($currentUser_id);
				$message->set_receiver_id($mention);
				$message->set_time($weed->get_time());
				$message->set_type(Message::$MESSAGE_TYPE_NOTIFICATION);
				$message->set_related_weed_id($result);
				$this->message_dao->create($message);
				$this->sendNotificationToUser(null, $mention, '@' . $currentUsername . ' mentioned you in weed: ' . $weed->get_content());
			}
		}
		return json_encode(array('id' => $result));
	}
	
	public function upload($weed_id)
	{
		$user_id = $this->getCurrentUser();
		
		error_log('Image name: ' . $_FILES['image']['name']);
		error_log('Image type: ' . $_FILES['image']['type']);
		error_log('Image size: ' . $_FILES['image']['size']);
		error_log('Image tmp name: ' . $_FILES['image']['tmp_name']);

		if (!saveImageForWeedsToServer($_FILES['image'], $user_id, $weed_id)) {
			header('Content-type: application/json');
			http_response_code(500);
			return;
		}

		header('Content-type: application/json');
		http_response_code(200);
	}
	
	public function delete($id)
	{
		$this->weed_dao->delete($id);
	}
	
	public function seed($weed_id) 
	{
		$currentUser_id = $this->getCurrentUser();
		$result = $this->weed_dao->setUserSeedWeed($currentUser_id, $weed_id);
	}
	
	public function unseed($weed_id) 
	{		
		$currentUser_id = $this->getCurrentUser();
		$result = $this->weed_dao->setUserUnseedWeed($currentUser_id, $weed_id);
	}
	
	public function water($weed_id) 
	{
		$currentUser_id = $this->getCurrentUser();
		$result = $this->weed_dao->setUserWaterWeed($currentUser_id, $weed_id);
	}
	
	public function unwater($weed_id) 
	{		
		$currentUser_id = $this->getCurrentUser();
		$result = $this->weed_dao->setUserUnwaterWeed($currentUser_id, $weed_id);
	}
	
	private function parse_request_body() {
		if ($_SERVER['REQUEST_METHOD'] != 'POST' && $_SERVER['REQUEST_METHOD'] != 'PUT') {
			throw new InvalidRequestException('request has to be either POST or PUT.');
		}
		
		$data = json_decode(file_get_contents('php://input'));
		$invalidReason = $this->check_para($data);
		if ($invalidReason) {
			throw new InvalidRequestException("Inputs are not valid due to $invalidReason");
		}
		
		$weed = new Weed();
		$weed->set_content($data->content);
		$weed->set_user_id($data->user_id);
		$weed->set_time($data->time);
		$weed->set_id($data->id);
		$weed->set_deleted(0);
		$weed->set_light_id($data->light_id);
		$weed->set_root_id($data->root_id);
		$weed->set_image_count($data->image_count);
		$weed->set_mentions($data->mentions);
		return $weed;
	}
	
	
	private function check_para($data)
	{	
		$content = trim($data->content);
		if ($content == '') {
			return 'Input error, content is null';
		}
			
		$time = trim($data->time);
		if ($time == '') {
			return 'Input error, time is null';
		}
		
		$user_id = trim($data->user_id);
		if ($user_id == '') {
			return 'Input error, userid is null';
		}
		
		if ($data->mentions == '') {
			return 'Input error, $mentions is null';
		}
		return null;		
	}
}
?>