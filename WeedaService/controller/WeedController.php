<?php

class WeedController extends Controller
{
	public function query() {

		/* connect to the db */
		$db_conn = new DbConnection();

		/* grab the users from the db */
		$query = "SELECT weed.id as weed_id, user.id as user_id, content, user.time as user_time, weed.time as weed_time, username, email FROM weed, user where user.id=weed.user_id";

		$result = $db_conn->query($query);

		/* create one master array of the records */
		$weeds = array();
		if(mysql_num_rows($result)) {
			while($weed = mysql_fetch_assoc($result)) {
				$user = array('id' => $weed['user_id'], 'username' => $weed['username'], 'email' => $weed['email'], 'time' => $weed['user_time']);
				$weeds[] = array('id' => $weed['weed_id'], 'content' => $weed['content'], 'user' => $user, 'time' => $weed['weed_time']);
			}
		}

		/* output in necessary format */

		header('Content-type: application/json');
		echo json_encode(array('weeds'=>$weeds));
	}
	
	public function create() {
		error_log('Creating the post.');
		
		$db_conn = new DbConnection();
		
		error_log("content: ". $this->model->get_content());
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
}
?>