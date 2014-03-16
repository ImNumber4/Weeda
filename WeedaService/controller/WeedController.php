<?php

class WeedController extends Controller
{
	public function query() {
		include("db/dbconnect.php");

		/* connect to the db */
		$db_conn = new DbConnection();

		/* grab the users from the db */
		$query = "SELECT * FROM weed LEFT JOIN user ON user.id=weed.user_id";

		$result = $db_conn->query($query);

		/* create one master array of the records */
		$weeds = array();
		if(mysql_num_rows($result)) {
			while($weed = mysql_fetch_assoc($result)) {
				$weeds[] = $weed;
			}
		}

		/* output in necessary format */

		header('Content-type: application/json');
		echo json_encode(array('weeds'=>$weeds));
	}
}



?>