<?php
/**
* 
*/
class WeedDAO extends BaseDAO
{
	public function create($weed)
	{
		$query = 'INSERT INTO weed (content, user_id, time, deleted) VALUES (\'' . $weed->get_content() . '\',\'' . $weed->get_user_id() . '\',\'' . $weed->get_time() . '\',' . $weed->get_deleted() . ',0,0)';
		error_log('insert query:' . $query);
		$result = $this->db_conn->insert($query);
		if ($result == 0) {
			error_log("SQL failed. Query: " . $query);
		}
		
		return $result;
	}
	
	public function update($weed)
	{
		$query = 'UPDATE weed SET content = \'' . $weed->get_content() . '\',time = \'' . $weed->get_time() . '\', deleted = \'' . $weed->get_deleted() . '\' WHERE id = ' . $weed->get_id();
		error_log('update query: ' . $query);
		$result = $this->db_conn->query($query);
		if (!$result) {
			error_log("SQL failed. Query: " . $query);
			return false;
		}
		return true;
	}
	
	public function delete($id)
	{
		$query = 'UPDATE weed SET deleted = 1 WHERE id = ' . $id;
		error_log('update query: ' . $query);
		$result = $this->db_conn->query($query);
		if (!$result) {
			error_log("SQL failed. Query: " . $query);
			return false;
		}
		return true;
	}
	
	public function setUserSeedWeed($user_id, $weed_id) {
		$db_conn = new DbConnection();
		$query = "UPDATE weed SET seed_count =  seed_count + 1 WHERE id = $weed_id";
		$db_conn->query($query);	
		$query = "INSERT INTO seed VALUES($weed_id,$user_id)";	
		return $db_conn->query($query);
	}
	
	public function setUserUnseedWeed($user_id, $weed_id) {
		$db_conn = new DbConnection();
		$query = "UPDATE weed SET seed_count =  seed_count - 1 WHERE id = $weed_id";
		$db_conn->query($query);
		$query = "DELETE FROM seed WHERE user_id = $user_id AND weed_id = $weed_id";
		return $db_conn->query($query);
	}
	
	public function setUserWaterWeed($user_id, $weed_id) {
		$db_conn = new DbConnection();
		$query = "UPDATE weed SET water_count =  water_count + 1 WHERE id = $weed_id";
		$db_conn->query($query);	
		$query = "INSERT INTO water VALUES($weed_id,$user_id)";	
		return $db_conn->query($query);
	}
	
	public function setUserUnwaterWeed($user_id, $weed_id) {
		$db_conn = new DbConnection();
		$query = "UPDATE weed SET water_count =  water_count - 1 WHERE id = $weed_id";
		$db_conn->query($query);
		$query = "DELETE FROM water WHERE user_id = $user_id AND weed_id = $weed_id";
		return $db_conn->query($query);
	}
	
	public function find_by_id($id)
	{
		$query = "SELECT * FROM weed WHERE id = ".$id;
		error_log('find query: ' . $query);
		$result = $this->db_conn->query($query);
		error_log('result: ' . $result);
		if (mysql_num_rows($result)) {
			$weed_array = mysql_fetch_assoc($result);
			$weed = new Weed();
			$weed->set_id($weed_array["id"]);
			$weed->set_content($weed_array["content"]);
			$weed->set_user_id($weed_array["user_id"]);
			$weed->set_time($weed_array["time"]);
			$weed->set_deleted($weed_array["deleted"]);
			return $weed;
		}
		
		return null;
	}
}

?>