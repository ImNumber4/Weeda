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
		echo json_encode(array('weeds'=>$weeds));
	}
	
	public function create() {
		error_log('Creating the post.');
		
		$db_conn = new DbConnection();
		
		$query = 'INSERT INTO weed (content, user_id, time) VALUES (\'' . $this->model->get_content() . '\',\'' . $this->model->get_user_id() . '\',\'' . $this->model->get_time() . '\')';
		error_log('execute sql command: '. $query);
		
		$result = $db_conn->query($query);
		
		header('Content-type: aplication/json');
		if ($result != TRUE) {
			header_status(500);
			die("Create weed failed.");
		}
		header_status(200);	
	}
	
	public function parse_request() {
		if ($_SERVER['REQUEST_METHOD'] === 'POST' || $_SERVER['REQUEST_METHOD'] === 'PUT') {
			$data = json_decode(file_get_contents('php://input'));
			error_log(1);
			if (!$this->parse_body($data)) {
				//return 403
				error_log("Input error.");
				return;
			}
			
			$this->model = new $this->_model($data);
		}
	}
	
	
	protected function parse_body($data)
	{
		// foreach ($body as $key => $value) {
		// 			if (is_object($value)) {
		// 				$this->parse_body($value);
		// 			}
		// 			array_push($this->_body, array($key => $value));
		// 		}
		
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
		
		$userid = trim($data->user->userid);
		if ($userid == '') {
			error_log('Input error, userid is null');
			return null;
		}
		return true;		
	}
	
	// public function checkEmpty($data) {
	// 	$content = trim($data->content);
	// 	if ($content == '') {
	// 		error_log('Input error, content is null');
	// 		return null;
	// 	}
	// 	
	// 	$time = trim($data->time);
	// 	if ($time == '') {
	// 		error_log('Input error, time is null');
	// 		return null;
	// 	}
	// 	
	// 	$userid = trim($data->userid);
	// 	error_log("4");
	// 	if ($userid) {
	// 		error_log('Input error, userid is null');
	// 		return null;
	// 	}
	// }
}
?>