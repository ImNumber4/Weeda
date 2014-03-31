<?php
/**
* 
*/
class UserDAO
{
	private $user;
	
	public function find_by_username($username)
	{
		/* connect to the db */
		$db_conn = new DbConnection();

		/* grab the users from the db */
		$query = "SELECT user.id as user_id FROM user where user.username = $username";

		$result = $db_conn->query($query);
		
		if(mysql_num_rows($result)) {
			while($weed = mysql_fetch_assoc($result)) {
				$user = array('id' => $weed['user_id'], 'username' => $weed['username'], 'email' => $weed['email'], 'time' => $weed['user_time'], 'deleted' => $weed['user_deleted']);
				$weeds[] = array('id' => $weed['weed_id'], 'content' => $weed['content'], 'user' => $user, 'time' => $weed['weed_time'], 'deleted' => $weed['weed_deleted']);
			}
		}
	}
}

?>