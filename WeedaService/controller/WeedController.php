<?php

ini_set('display_errors',1);
error_reporting(E_ALL);

include './library/ImageHandler.php';

class WeedController extends Controller
{
	public function query($user_id) {
		
		/* connect to the db */
		$db_conn = new DbConnection();
        $currentUser_id = $this->getCurrentUser();
		
		$userIdFilter = "";
		if($user_id)
			$userIdFilter = " and weed.user_id=$user_id";

		/* grab the users from the db */
		$query = "SELECT weed.id as weed_id, user.id as user_id, weed.light_id as light_id, weed.root_id as root_id, currentUserWater.user_id as if_cur_user_water_it, currentUserWeed.user_id as if_cur_user_light_it, currentUserSeed.user_id as if_cur_user_seed_it, weed.water_count as water_count, weed.seed_count as seed_count, weed.light_count as light_count, weed.content as content, user.time as user_time, weed.time as weed_time, username, weed.deleted as weed_deleted, user.deleted as user_deleted FROM weed left join weed currentUserWeed on currentUserWeed.root_id=weed.id or currentUserWeed.light_id=weed.id and currentUserWeed.user_id=$currentUser_id left join water currentUserWater on currentUserWater.weed_id=weed.id and currentUserWater.user_id=$currentUser_id left join seed currentUserSeed on currentUserSeed.weed_id=weed.id and currentUserSeed.user_id=$currentUser_id, user where user.id=weed.user_id$userIdFilter GROUP BY weed.id";
		
		$result = $db_conn->query($query);

		/* create one master array of the records */
		$weeds = array();
		if(mysql_num_rows($result)) {
			while($weed = mysql_fetch_assoc($result)) {
				$weeds[] = array('id' => $weed['weed_id'], 'content' => $weed['content'], 'user_id' => $weed['user_id'], 'username' => $weed['username'], 'time' => $weed['weed_time'], 'light_id' => $weed['light_id'], 'root_id' => $weed['root_id'], 'deleted' => $weed['weed_deleted'], 'light_count' => $weed['light_count'], 'water_count' => $weed['water_count'], 'seed_count' => $weed['seed_count'], 'if_cur_user_water_it' => $weed['if_cur_user_water_it'] == $currentUser_id, 'if_cur_user_seed_it' => $weed['if_cur_user_seed_it'] == $currentUser_id, 'if_cur_user_light_it' => $weed['if_cur_user_light_it'] == $currentUser_id);
			}
		}

		return json_encode(array('weeds'=>$weeds));
	}
	
	public function getLights($id) {
		
		$weedDAO = new WeedDAO();
		$weeds = $weedDAO->getLights($id);

		return json_encode(array('weeds'=>$weeds));
	}
	
	public function getAncestorWeeds($id) {
		
		$weedDAO = new WeedDAO();
		$weeds = $weedDAO->getAncestorWeeds($id);

		return json_encode(array('weeds'=>$weeds));
	}
	
	public function create() 
	{
		//parse request body
		$weed = $this->parse_request_body();
		
		$weedDAO = new WeedDAO();
		$result = $weedDAO->create($weed);
		
		$userDao = new UserDAO();
		$currentUsername = $this->getCurrentUsername();
		$tokens = preg_split('/\s+/', $weed->get_content());
		
		foreach ($tokens as &$token) {
			if(strpos($token, '@') === 0) {
				$username = substr($token, 1);
				$devices = $userDao->getUserDevicesByUsername($username);
				foreach ($devices as &$device) {
				    NotificationHelper::sendMessage($device['device_id'], '@' . $currentUsername . ' mentioned you in weed: ' . $weed->get_content());
				}
			}
		}
		error_log('Create weed successed!');
		header('Content-type: application/json');
		http_response_code(200);
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
		$weedDAO = new WeedDAO();

		$weedDAO->delete($id);
	}
	
	public function seed($weed_id) 
	{
		$currentUser_id = $this->getCurrentUser();
		$weedDAO = new WeedDAO();
		$result = $weedDAO->setUserSeedWeed($currentUser_id, $weed_id);
	}
	
	public function unseed($weed_id) 
	{		
		$currentUser_id = $this->getCurrentUser();
		$weedDAO = new WeedDAO();
		$result = $weedDAO->setUserUnseedWeed($currentUser_id, $weed_id);
	}
	
	public function water($weed_id) 
	{
		$currentUser_id = $this->getCurrentUser();
		$weedDAO = new WeedDAO();
		$result = $weedDAO->setUserWaterWeed($currentUser_id, $weed_id);
	}
	
	public function unwater($weed_id) 
	{		
		$currentUser_id = $this->getCurrentUser();
		$weedDAO = new WeedDAO();
		$result = $weedDAO->setUserUnwaterWeed($currentUser_id, $weed_id);
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
		return null;		
	}
}
?>