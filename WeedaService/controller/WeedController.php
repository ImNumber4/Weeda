<?php

class WeedController extends Controller
{
	public function query() {

		/* connect to the db */
		$db_conn = new DbConnection();

		/* grab the users from the db */
		$query = "SELECT weed.id as weed_id, user.id as user_id, content, user.time as user_time, weed.time as weed_time, username, email, weed.deleted as weed_deleted, user.deleted as user_deleted FROM weed, user where user.id=weed.user_id";

		$result = $db_conn->query($query);

		/* create one master array of the records */
		$weeds = array();
		if(mysql_num_rows($result)) {
			while($weed = mysql_fetch_assoc($result)) {
				$user = array('id' => $weed['user_id'], 'username' => $weed['username'], 'email' => $weed['email'], 'time' => $weed['user_time'], 'deleted' => $weed['user_deleted']);
				$weeds[] = array('id' => $weed['weed_id'], 'content' => $weed['content'], 'user' => $user, 'time' => $weed['weed_time'], 'deleted' => $weed['weed_deleted']);
			}
		}

		/* output in necessary format */

		header('Content-type: application/json');
		http_response_code(200);
		echo json_encode(array('weeds'=>$weeds));
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
	
	private function parse_request_body() {
		if ($_SERVER['REQUEST_METHOD'] != 'POST' && $_SERVER['REQUEST_METHOD'] != 'PUT') {
			//request method error, return 403
			error_log("Request method error, should use POST or PUT.");
			return null;
		}
		
		$data = json_decode(file_get_contents('php://input'));
		if (!$this->check_para($data)) {
			//return 403
			error_log("Input error.");
			return;
		}
		
		$weed = new Weed();
		$weed->set_content($data->content);
		$weed->set_user_id($data->user->id);
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
		
		$user_id = trim($data->user->id);
		if ($user_id == '') {
			error_log('Input error, userid is null');
			return null;
		}
		return true;		
	}
}
?>