<?php

class WeedController extends Controller
{
	public function query() {
		include("db/dbconnect.php");

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
}



?>