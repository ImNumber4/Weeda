<?php

class WeedController extends Controller
{
	public function query() {

		/* connect to the db */
		$db_conn = new DbConnection();
        $currentUser_id = $this->getCurrentUser();

		/* grab the users from the db */
		$query = "SELECT weed.id as weed_id, user.id as user_id, currentUserWater.user_id as if_cur_user_water_it, currentUserSeed.user_id as if_cur_user_seed_it, water_count, seed_count, weed.content as content, user.time as user_time, weed.time as weed_time, username, weed.deleted as weed_deleted, user.deleted as user_deleted FROM weed left join water currentUserWater on currentUserWater.weed_id=weed.id and currentUserWater.user_id=$currentUser_id left join seed currentUserSeed on currentUserSeed.weed_id=weed.id and currentUserSeed.user_id=$currentUser_id, user where user.id=weed.user_id GROUP BY weed.id";
		
		$result = $db_conn->query($query);

		/* create one master array of the records */
		$weeds = array();
		if(mysql_num_rows($result)) {
			while($weed = mysql_fetch_assoc($result)) {
				$weeds[] = array('id' => $weed['weed_id'], 'content' => $weed['content'], 'user_id' => $weed['user_id'], 'username' => $weed['username'], 'time' => $weed['weed_time'], 'deleted' => $weed['weed_deleted'], 'water_count' => $weed['water_count'], 'seed_count' => $weed['seed_count'], 'if_cur_user_water_it' => $weed['if_cur_user_water_it'] == $currentUser_id, 'if_cur_user_seed_it' => $weed['if_cur_user_seed_it'] == $currentUser_id);
			}
		}

		/* output in necessary format */

		header('Content-type: application/json');
		http_response_code(200);
		echo json_encode(array('weeds'=>$weeds));
	}
	
	public function getLights($id) {
		
		$weedDAO = new WeedDAO();
		$weeds = $weedDAO->getLights($id);

		header('Content-type: application/json');
		http_response_code(200);
		echo json_encode(array('weeds'=>$weeds));
	}
	
	public function getAncestorWeeds($id) {
		
		$weedDAO = new WeedDAO();
		$weeds = $weedDAO->getAncestorWeeds($id);

		header('Content-type: application/json');
		http_response_code(200);
		echo json_encode(array('weeds'=>$weeds));
	}
	
	private function getCurrentUser(){
		$currentUser_id = $_COOKIE['user_id'];
		if (!isset($currentUser_id)) {
			error_log('current user is not set');
			header("Content-type: application/json");
			http_response_code(400);
			return;
		}
		return $currentUser_id;
	}
	
	public function create() 
	{
		//parse request body
		$weed = $this->parse_request_body();
		
		$weedDAO = new WeedDAO();
		$result = $weedDAO->create($weed);
		if ($result == 0) {
			//return 500
			error_log("Create weed failed.");
			http_response_code(500);
			return;
		}
		header('Content-type: application/json');
		http_response_code(200);
		echo json_encode(array('id' => $result));
	}
	
	public function delete($id)
	{
		$weedDAO = new WeedDAO();

		if (!$weedDAO->delete($id)) {
			//return 400
			http_response_code(400);
			return;
		}
		error_log("Delete success.");
		header('Content-type: application/json');
		http_response_code(200);
	}
	
	public function seed($weed_id) 
	{
		$currentUser_id = $this->getCurrentUser();
		$weedDAO = new WeedDAO();
		$result = $weedDAO->setUserSeedWeed($currentUser_id, $weed_id);
		if ($result == 0) {
			//return 500
			error_log("seed $weed_id failed.");
			http_response_code(500);
			return;
		}
		header('Content-type: application/json');
		http_response_code(200);
	}
	
	public function unseed($weed_id) 
	{		
		$currentUser_id = $this->getCurrentUser();
		$weedDAO = new WeedDAO();
		$result = $weedDAO->setUserUnseedWeed($currentUser_id, $weed_id);
		if ($result == 0) {
			//return 500
			error_log("unseed $weed_id failed.");
			http_response_code(500);
			return;
		}
		header('Content-type: application/json');
		http_response_code(200);
	}
	
	public function water($weed_id) 
	{
		$currentUser_id = $this->getCurrentUser();
		$weedDAO = new WeedDAO();
		$result = $weedDAO->setUserWaterWeed($currentUser_id, $weed_id);
		if ($result == 0) {
			//return 500
			error_log("water $weed_id failed.");
			http_response_code(500);
			return;
		}
		header('Content-type: application/json');
		http_response_code(200);
	}
	
	public function unwater($weed_id) 
	{		
		$currentUser_id = $this->getCurrentUser();
		$weedDAO = new WeedDAO();
		$result = $weedDAO->setUserUnwaterWeed($currentUser_id, $weed_id);
		if ($result == 0) {
			//return 500
			error_log("unwater $weed_id failed.");
			http_response_code(500);
			return;
		}
		header('Content-type: application/json');
		http_response_code(200);
	}
	
	private function parse_request_body() {
		if ($_SERVER['REQUEST_METHOD'] != 'POST' && $_SERVER['REQUEST_METHOD'] != 'PUT') {
			//request method error, return 403
			error_log("Request method error, should use POST or PUT.");
			return null;
		}
		
		$data = json_decode(file_get_contents('php://input'));
		if (!$this->check_para($data)) {
			header('Content-type: application/json');
			http_response_code(400);
		}
		
		$weed = new Weed();
		$weed->set_content($data->content);
		$weed->set_user_id($data->user_id);
		$weed->set_time($data->time);
		$weed->set_id($data->id);
		$weed->set_deleted(0);
		return $weed;
	}
	
	
	private function check_para($data)
	{	
		$content = trim($data->content);
		if ($content == '') {
			error_log('Input error, content is null');
			return null;
		}
			
		$time = trim($data->time);
		if ($time == '') {
			error_log('Input error, time is null');
			return null;
		}
		
		$user_id = trim($data->user_id);
		if ($user_id == '') {
			error_log('Input error, userid is null');
			return null;
		}
		return true;		
	}
}
?>