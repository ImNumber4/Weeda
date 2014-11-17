<?php
/**
* Token DAO
*/
class TokenDAO extends BaseDAO
{
	
	// function __construct(argument)
	// {
	// 	# code...
	// }
	
	public function create($token) {
		$query = 'INSERT INTO token (token_id, user_id, used) VALUES (\'' 
				. $token['token_id'] . '\',' 
				. $token['user_id'] . ','
				. 0 . ')';
		$result = $this->db_conn->insert($query);
		return $result;
	}
	
	public function find_by_token_id($token_id) {

		/* grab the users from the db */
		$query = 'SELECT * FROM token where token_id = \'' . $token_id . '\'';

		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			$user = mysql_fetch_assoc($result);
			return $user;
		} else {
			return null;
		}
	}
	
	public function update_used($used, $token_id)
	{
		$query = 'UPDATE token SET used=' . $used . ' WHERE token_id=\'' . $token_id . '\'';
		$result = $this->db_conn->query($query);
	}
}
?>