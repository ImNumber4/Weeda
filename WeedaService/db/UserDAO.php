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
		$query = 'SELECT * FROM user where username = \'' . $username . '\'';

		$result = $db_conn->query($query);
		if (mysql_num_rows($result)) {
			$user = mysql_fetch_assoc($result);
			return $user;
		} else {
			return null;
		}
	}
	
	public function find_by_id($id) {
		$db_conn = new DbConnection();
		
		$query = "SELECT * FROM user WHERE id = ". $id;
		
		$result = $db_conn->query($query);
		if (mysql_num_rows($result)) {
			$user = mysql_fetch_assoc($result);
			return $user;
		} else {
			return null;
		}
	}
}

?>