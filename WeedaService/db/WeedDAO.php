<?php
/**
* 
*/
class WeedDAO extends BaseDAO
{
	public function create($weed)
	{
		$query = 'INSERT INTO weed (content, user_id, time, deleted, light_id, root_id, water_count,seed_count,light_count) VALUES (\'' . $weed->get_content() . '\',\'' . $weed->get_user_id() . '\',\'' . $weed->get_time() . '\',' . $weed->get_deleted() .','. $weed->get_light_id() .','. $weed->get_root_id() . ',0,0,0)';
		$result = $this->db_conn->insert($query);
		$fectchId = $weed->get_light_id();
		while (true) {
			if(!$fectchId) break;
			$query = "UPDATE weed SET light_count =  light_count + 1 WHERE id = $fectchId";
			$this->db_conn->query($query);
			$fetchedWeeds = $this->find_by_id($fectchId);
			if (count($fetchedWeeds) <= 0) break;
			foreach ($fetchedWeeds as &$weed) {
				$fectchId = $weed['light_id'];
			}
		}
		return $result;
	}
	
	public function getLights($id)
	{
		$weeds = array();
		$fectchIds = array($id);
		$fectchedIds = array();
		while (count($fectchIds) > 0) {
			$fectchId = array_pop($fectchIds);
			$fectchedIds[$fectchId] = true;
			$fetchedWeeds = $this->fetchLights($fectchId);
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
		$weeds = array();
		$fectchId = $id;
		while (true) {
			if(!$fectchId) break;
			$fetchedWeeds = $this->find_by_id($fectchId);
			if (count($fetchedWeeds) <= 0) break;
			foreach ($fetchedWeeds as &$weed) {
				if ($fectchId != $id)
					array_push($weeds, $weed);
				$fectchId = $weed['light_id'];
			}
		}
		return $weeds;
	}
	
	private function find_by_id($id) {
		$condition = "weed.id = $id";
		return $this->getWeedsWithCondition($condition);
	}
		
	private function fetchLights($id)
	{
		$condition = "(weed.root_id = $id OR weed.light_id = $id)";
		return $this->getWeedsWithCondition($condition);
	}
	
	private function getWeedsWithCondition($condition) {
		$query = "SELECT weed.id as weed_id, user.id as user_id, weed.content as content, weed.light_id as light_id, user.time as user_time, weed.time as weed_time, username, weed.deleted as weed_deleted, user.deleted as user_deleted FROM weed, user WHERE user.id=weed.user_id AND $condition";
		$result = $this->db_conn->query($query);

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
		$result = $this->db_conn->query($query);
	}
	
	public function delete($id)
	{
		$query = 'UPDATE weed SET deleted = 1 WHERE id = ' . $id;
		$result = $this->db_conn->query($query);
	}
	
	public function setUserSeedWeed($user_id, $weed_id) {
		$query = "UPDATE weed SET seed_count =  seed_count + 1 WHERE id = $weed_id";
		$this->db_conn->query($query);	
		$query = "INSERT INTO seed VALUES($weed_id,$user_id)";	
		$this->db_conn->query($query);
	}
	
	public function setUserUnseedWeed($user_id, $weed_id) {
		$query = "UPDATE weed SET seed_count =  seed_count - 1 WHERE id = $weed_id";
		$this->db_conn->query($query);
		$query = "DELETE FROM seed WHERE user_id = $user_id AND weed_id = $weed_id";
		$this->db_conn->query($query);
	}
	
	public function setUserWaterWeed($user_id, $weed_id) {
		$query = "UPDATE weed SET water_count =  water_count + 1 WHERE id = $weed_id";
		$this->db_conn->query($query);	
		$query = "INSERT INTO water VALUES($weed_id,$user_id)";	
		$this->db_conn->query($query);
	}
	
	public function setUserUnwaterWeed($user_id, $weed_id) {
		$query = "UPDATE weed SET water_count =  water_count - 1 WHERE id = $weed_id";
		$this->db_conn->query($query);
		$query = "DELETE FROM water WHERE user_id = $user_id AND weed_id = $weed_id";
		$this->db_conn->query($query);
	}
}

?>