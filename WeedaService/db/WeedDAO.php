<?php
/**
* 
*/
class WeedDAO extends BaseDAO
{
	public function create($weed)
	{
		$query = 'INSERT INTO weed (content, user_id, time, deleted,water_count,seed_count,light_count) VALUES (\'' . $weed->get_content() . '\',\'' . $weed->get_user_id() . '\',\'' . $weed->get_time() . '\',' . $weed->get_deleted() . ',0,0,0)';
		error_log('insert query:' . $query);
		$result = $this->db_conn->insert($query);
		if ($result == 0) {
			error_log("SQL failed. Query: " . $query);
		}
		
		return $result;
	}
	
	public function getLights($id)
	{
		$db_conn = new DbConnection();
		
		$weeds = array();
		$fectchIds = array($id);
		$fectchedIds = array();
		while (count($fectchIds) > 0) {
			$fectchId = array_pop($fectchIds);
			$fectchedIds[$fectchId] = true;
			$fetchedWeeds = $this->fetchLights($db_conn, $fectchId);
			foreach ($fetchedWeeds as &$weed) {
				if (array_key_exists($weed['id'], $fectchedIds)) continue;
				array_push($weeds, $weed);
				array_push($fectchIds, $weed['id']);
			}
			if (count($weeds) > 25) break;
		}
		return $weeds;
	}
	
	public function getAncestorWeeds($id)
	{
		error_reporting(E_ALL);
		$db_conn = new DbConnection();
		
		$weeds = array();
		$fectchId = $id;
		while (true) {
			if(!$fectchId) break;
			$fetchedWeeds = $this->find_by_id($db_conn, $fectchId);
			if (count($fetchedWeeds) <= 0) break;
			foreach ($fetchedWeeds as &$weed) {
				if ($fectchId != $id)
					array_push($weeds, $weed);
				$fectchId = $weed['light_id'];
			}
		}
		return $weeds;
	}
	
	private function find_by_id($db_conn, $id) {
		$condition = "weed.id = $id";
		return $this->getWeedsWithCondition($db_conn, $condition);
	}
		
	private function fetchLights($db_conn, $id)
	{
		$condition = "(weed.root_id = $id OR weed.light_id = $id)";
		return $this->getWeedsWithCondition($db_conn, $condition);
	}
	
	private function getWeedsWithCondition($db_conn, $condition) {
		$query = "SELECT weed.id as weed_id, user.id as user_id, weed.content as content, weed.light_id as light_id, user.time as user_time, weed.time as weed_time, username, weed.deleted as weed_deleted, user.deleted as user_deleted FROM weed, user WHERE user.id=weed.user_id AND $condition";
		$result = $db_conn->query($query);

		/* create one master array of the records */
		$weeds = array();
		if(mysql_num_rows($result)) {
			while($weed = mysql_fetch_assoc($result)) {
				$weeds[] = array('id' => $weed['weed_id'], 'content' => $weed['content'], 'user_id' => $weed['user_id'], 'light_id' => $weed['light_id'], 'username' => $weed['username'], 'time' => $weed['weed_time'], 'deleted' => $weed['weed_deleted']);
			}
		}
		return $weeds;
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
}

?>