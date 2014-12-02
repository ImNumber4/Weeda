<?php
/**
* 
*/
class WeedDAO extends BaseDAO
{
	
	public function query($currentUser_id, $user_id, $weed_id) {
		
		$filter = null;
		if(!is_null($user_id))
			$filter = "where weed.user_id=$user_id";
		
		if(!is_null($weed_id)) {
			if (!is_null($filter))
				$filter = $filter . " and weed.id = $weed_id";
			else
				$filter = "where weed.id = $weed_id";
		}
		$isFeed = true;
		if (is_null($filter)) {
			$filter = "left join follow on follow.followee_uid = weed.user_id left join (select seed.weed_id as seed_id, seeduser.username as seedusername, seed.time as seedtime from seed left join user as seeduser on seed.user_id = seeduser.id left join follow as seedfollow on seedfollow.followee_uid = seed.user_id where seedfollow.follower_uid = $currentUser_id) as seeddata on seed_id=weed.id where (follower_uid = $currentUser_id and datediff(now(), weed.time) < 7) or datediff(now(), seedtime) < 7";
			$additionalSelect = "seeddata.seedusername as seeded_by, seeddata.seedtime as seedtime,";
		} else {
			$additionalSelect = "";
			$isFeed = false;
		}
		
		/* grab the users from the db */
		$query = "SELECT weed.id as weed_id, $additionalSelect user.id as user_id, (weed.light_count + weed.seed_count + weed.water_count) as score, user.user_type as user_type, weed.light_id as light_id, weed.root_id as root_id, currentUserWater.user_id as if_cur_user_water_it, currentUserWeed.user_id as if_cur_user_light_it, currentUserSeed.user_id as if_cur_user_seed_it, weed.water_count as water_count, weed.seed_count as seed_count, weed.light_count as light_count, weed.content as content, weed.time as weed_time, username, weed.deleted as weed_deleted, user.deleted as user_deleted, weed.image_count as image_count, weed.image_metadata as image_metadata FROM weed left join weed currentUserWeed on currentUserWeed.root_id=weed.id or currentUserWeed.light_id=weed.id and currentUserWeed.user_id=$currentUser_id left join water currentUserWater on currentUserWater.weed_id=weed.id and currentUserWater.user_id=$currentUser_id left join seed currentUserSeed on currentUserSeed.weed_id=weed.id and currentUserSeed.user_id=$currentUser_id left join user on user.id=weed.user_id $filter GROUP BY weed.id";

		$result = $this->db_conn->query($query);

		/* create one master array of the records */
		$weeds = array();
		if(mysql_num_rows($result)) {
			while($weed = mysql_fetch_assoc($result)) {
				$images = json_decode($weed['image_metadata']);
				if ($isFeed)
					$weeds[] = array('id' => $weed['weed_id'], 'content' => $weed['content'], 'seeded_by' => $weed['seeded_by'], 'watered_by' => $weed['watered_by'], 'is_feed' => $isFeed, 'content' => $weed['content'], 'content' => $weed['content'], 'user_id' => $weed['user_id'], 'user_type' => $weed['user_type'], 'score' => $weed['score'], 'username' => $weed['username'], 'time' => $weed['weed_time'], 'light_id' => $weed['light_id'], 'root_id' => $weed['root_id'], 'deleted' => $weed['weed_deleted'], 'light_count' => $weed['light_count'], 'water_count' => $weed['water_count'], 'seed_count' => $weed['seed_count'], 'if_cur_user_water_it' => $weed['if_cur_user_water_it'] == $currentUser_id, 'if_cur_user_seed_it' => $weed['if_cur_user_seed_it'] == $currentUser_id, 'if_cur_user_light_it' => $weed['if_cur_user_light_it'] == $currentUser_id, 'image_count' => $weed['image_count'], 'images' => $images, 'sort_time' => ($weed['seedtime']?$weed['seedtime']: $weed['weed_time']));
				else 
					$weeds[] = array('id' => $weed['weed_id'], 'content' => $weed['content'], 'seeded_by' => $weed['seeded_by'], 'watered_by' => $weed['watered_by'], 'content' => $weed['content'], 'content' => $weed['content'], 'user_id' => $weed['user_id'], 'user_type' => $weed['user_type'], 'score' => $weed['score'], 'username' => $weed['username'], 'time' => $weed['weed_time'], 'light_id' => $weed['light_id'], 'root_id' => $weed['root_id'], 'deleted' => $weed['weed_deleted'], 'light_count' => $weed['light_count'], 'water_count' => $weed['water_count'], 'seed_count' => $weed['seed_count'], 'if_cur_user_water_it' => $weed['if_cur_user_water_it'] == $currentUser_id, 'if_cur_user_seed_it' => $weed['if_cur_user_seed_it'] == $currentUser_id, 'if_cur_user_light_it' => $weed['if_cur_user_light_it'] == $currentUser_id, 'image_count' => $weed['image_count'], 'images' => $images, 'sort_time' => ($weed['seedtime']?$weed['seedtime']: $weed['weed_time']));
			}
		}

		return $weeds;
	}
	
	public function queryByContent($keyword, $currentUser_id) {

		/* grab the users from the db */
		$query = "SELECT weed.id as weed_id, user.id as user_id, (weed.light_count + weed.seed_count + weed.water_count) as score, user.user_type as user_type, weed.light_id as light_id, weed.root_id as root_id, currentUserWater.user_id as if_cur_user_water_it, currentUserWeed.user_id as if_cur_user_light_it, currentUserSeed.user_id as if_cur_user_seed_it, weed.water_count as water_count, weed.seed_count as seed_count, weed.light_count as light_count, weed.content as content, weed.time as weed_time, username, weed.deleted as weed_deleted, user.deleted as user_deleted, weed.image_count as image_count, weed.image_metadata as image_metadata FROM weed left join weed currentUserWeed on currentUserWeed.root_id=weed.id or currentUserWeed.light_id=weed.id and currentUserWeed.user_id=$currentUser_id left join water currentUserWater on currentUserWater.weed_id=weed.id and currentUserWater.user_id=$currentUser_id left join seed currentUserSeed on currentUserSeed.weed_id=weed.id and currentUserSeed.user_id=$currentUser_id left join user on user.id=weed.user_id WHERE weed.content like '%$keyword%' GROUP BY weed.id";

		$result = $this->db_conn->query($query);

		/* create one master array of the records */
		$weeds = array();
		if(mysql_num_rows($result)) {
			while($weed = mysql_fetch_assoc($result)) {
				$images = json_decode($weed['image_metadata']);
				$weeds[] = array('id' => $weed['weed_id'], 'content' => $weed['content'], 'user_id' => $weed['user_id'], 'user_type' => $weed['user_type'], 'score' => $weed['score'], 'username' => $weed['username'], 'time' => $weed['weed_time'], 'light_id' => $weed['light_id'], 'root_id' => $weed['root_id'], 'deleted' => $weed['weed_deleted'], 'light_count' => $weed['light_count'], 'water_count' => $weed['water_count'], 'seed_count' => $weed['seed_count'], 'if_cur_user_water_it' => $weed['if_cur_user_water_it'] == $currentUser_id, 'if_cur_user_seed_it' => $weed['if_cur_user_seed_it'] == $currentUser_id, 'if_cur_user_light_it' => $weed['if_cur_user_light_it'] == $currentUser_id, 'image_count' => $weed['image_count'], 'images' => $images);
			}
		}

		return $weeds;
	}
	
	public function getMentions($weed_id) {
		$query = "SELECT id, username FROM mention JOIN user ON user_id = id AND weed_id = $weed_id";
		$result = $this->db_conn->query($query);
		$mentions = array();
		if(mysql_num_rows($result)) {
			while($mention = mysql_fetch_assoc($result)) {
				$mentions[] = $mention;
			}
		}
		return $mentions;
	}
	
	public function trends($currentUser_id) {

		/* grab the users from the db */
		$query = "SELECT weed.id as weed_id, (weed.light_count + weed.seed_count + weed.water_count) as score, user.user_type as user_type, user.id as user_id, weed.light_id as light_id, weed.root_id as root_id, currentUserWater.user_id as if_cur_user_water_it, currentUserWeed.user_id as if_cur_user_light_it, currentUserSeed.user_id as if_cur_user_seed_it, weed.water_count as water_count, weed.seed_count as seed_count, weed.light_count as light_count, weed.content as content, weed.time as weed_time, username, weed.deleted as weed_deleted, user.deleted as user_deleted, weed.image_count as image_count, weed.image_metadata as image_metadata FROM weed left join weed currentUserWeed on currentUserWeed.root_id=weed.id or currentUserWeed.light_id=weed.id and currentUserWeed.user_id=$currentUser_id left join water currentUserWater on currentUserWater.weed_id=weed.id and currentUserWater.user_id=$currentUser_id left join seed currentUserSeed on currentUserSeed.weed_id=weed.id and currentUserSeed.user_id=$currentUser_id left join user on user.id=weed.user_id GROUP BY weed.id order by score desc limit 20";

		$result = $this->db_conn->query($query);

		/* create one master array of the records */
		$weeds = array();
		if(mysql_num_rows($result)) {
			while($weed = mysql_fetch_assoc($result)) {
				$images = json_decode($weed['image_metadata']);
				$weeds[] = array('id' => $weed['weed_id'], 'content' => $weed['content'], 'user_id' => $weed['user_id'], 'user_type' => $weed['user_type'], 'score' => $weed['score'], 'username' => $weed['username'], 'time' => $weed['weed_time'], 'light_id' => $weed['light_id'], 'root_id' => $weed['root_id'], 'deleted' => $weed['weed_deleted'], 'light_count' => $weed['light_count'], 'water_count' => $weed['water_count'], 'seed_count' => $weed['seed_count'], 'if_cur_user_water_it' => $weed['if_cur_user_water_it'] == $currentUser_id, 'if_cur_user_seed_it' => $weed['if_cur_user_seed_it'] == $currentUser_id, 'if_cur_user_light_it' => $weed['if_cur_user_light_it'] == $currentUser_id, 'image_count' => $weed['image_count'], 'images' => $images);
			}
		}

		return $weeds;
	}
	
	public function create($weed)
	{
		$query = 'INSERT INTO weed (content, user_id, time, deleted, light_id, root_id, water_count,seed_count,light_count,image_count, image_metadata) VALUES (\'' . mysql_real_escape_string($weed->get_content()) . '\',\'' . $weed->get_user_id() . '\',\'' . $weed->get_time() . '\',' . $weed->get_deleted() .','. ($weed->get_light_id() == NULL ? 'NULL' : $weed->get_light_id()) .','. ($weed->get_root_id() == NULL ?  'NULL' : $weed->get_root_id()) . ',0,0,0,' . $weed->get_image_count() . ',\'' . $weed->get_image_metadata() . '\')';
		error_log('create weed query: ' . $query);
		$result = $this->db_conn->insert($query);
		$fectchId = $weed->get_light_id();
		while (true) {
			if(!$fectchId) break;
			$query = "UPDATE weed SET light_count =  light_count + 1 WHERE id = $fectchId";
			$this->db_conn->query($query);
			$fetchedWeeds = $this->find_by_id($fectchId);
			if (count($fetchedWeeds) <= 0) break;
			foreach ($fetchedWeeds as &$parent_weed) {
				$fectchId = $parent_weed['light_id'];
			}
		}
		if (count($weed->get_mentions()) > 0) {
			$update_mention_table_query = "INSERT INTO mention (weed_id, user_id) VALUES ";
			$mentions = $weed->get_mentions();
			foreach ($mentions as &$mention) {
				$update_mention_table_query = $update_mention_table_query . "(" . $result . "," . $mention . "), ";
			}
			$this->db_conn->insert(substr($update_mention_table_query, 0, strlen($update_mention_table_query) - 2));
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
	
	public function getImageMetadata($weed_id)
	{
		$query = 'SELECT image_metadata as image_metadata FROM weed WHERE id=' . $weed_id;
		$result = $this->db_conn->query($query);
		
		$image_metadata = array();
		if(mysql_num_rows($result)) {
			while($weed = mysql_fetch_assoc($result)) {
				error_log('Image_metadata4: ' . print_r($weed['image_metadata'], true));
				$image_metadata = json_decode($weed['image_metadata']);
				error_log('Image_metadata3: ' . print_r($image_metadata, true));
			}
		}
		return $image_metadata;
	}
	
	/*
	* this function just returns a plain weed that matches the give id. No extra information will be retrieved
	*/
	public function find_by_id($id) {
		$condition = "weed.id = $id";
		return $this->getWeedsWithCondition($condition);
	}
		
	private function fetchLights($id)
	{
		$condition = "(weed.root_id = $id OR weed.light_id = $id)";
		return $this->getWeedsWithCondition($condition);
	}
	
	private function getWeedsWithCondition($condition) {
		$query = "SELECT weed.id as weed_id, user.id as user_id, weed.content as content, user.user_type as user_type, weed.light_id as light_id, weed.time as weed_time, username, weed.deleted as weed_deleted, user.deleted as user_deleted FROM weed, user WHERE user.id=weed.user_id AND $condition";
		$result = $this->db_conn->query($query);

		/* create one master array of the records */
		$weeds = array();
		if(mysql_num_rows($result)) {
			while($weed = mysql_fetch_assoc($result)) {
				$weeds[] = array('id' => $weed['weed_id'], 'content' => $weed['content'], 'user_id' => $weed['user_id'], 'user_type' => $weed['user_type'], 'light_id' => $weed['light_id'], 'username' => $weed['username'], 'time' => $weed['weed_time'], 'deleted' => $weed['weed_deleted']);
			}
		}
		return $weeds;
	}
	
	public function update($weed)
	{
		$query = 'UPDATE weed SET content = \'' . mysql_real_escape_string($weed->get_content()) . '\',time = \'' . $weed->get_time() . '\', deleted = \'' . $weed->get_deleted() . '\' WHERE id = ' . $weed->get_id();
		$result = $this->db_conn->query($query);
	}
	
	public function delete($id)
	{
		$query = 'UPDATE weed SET deleted = 1 WHERE id = ' . $id;
		$result = $this->db_conn->query($query);
	}
	
	public function setUserSeedWeed($user_id, $weed_id) {
		$query = "INSERT INTO seed (weed_id, user_id) VALUES($weed_id,$user_id)";	
		$this->db_conn->query($query);
		$query = "UPDATE weed SET seed_count =  seed_count + 1 WHERE id = $weed_id";
		$this->db_conn->query($query);
	}
	
	public function setUserUnseedWeed($user_id, $weed_id) {
		$query = "DELETE FROM seed WHERE user_id = $user_id AND weed_id = $weed_id";
		$this->db_conn->query($query);
		$query = "UPDATE weed SET seed_count =  seed_count - 1 WHERE id = $weed_id";
		$this->db_conn->query($query);
	}
	
	public function setUserWaterWeed($user_id, $weed_id) {
		$query = "INSERT INTO water (weed_id, user_id) VALUES($weed_id,$user_id)";	
		$this->db_conn->query($query);
		$query = "UPDATE weed SET water_count =  water_count + 1 WHERE id = $weed_id";
		$this->db_conn->query($query);	
	}
	
	public function setUserUnwaterWeed($user_id, $weed_id) {
		$query = "DELETE FROM water WHERE user_id = $user_id AND weed_id = $weed_id";
		$this->db_conn->query($query);
		$query = "UPDATE weed SET water_count =  water_count - 1 WHERE id = $weed_id";
		$this->db_conn->query($query);
	}
	
	public function setImageMetadataWeed($image_metadata, $weed_id)
	{
		$query = 'UPDATE weed SET image_metadata = \'' . $image_metadata . '\' WHERE id=' . $weed_id;
		$result = $this->db_conn->query($query);
	}
	
	public function get_user_id($weed_id)
	{
		$weeds = $this->find_by_id($weed_id);
		if (count($weeds) == 0) {
			return null;
		}
		$weed = $weeds[0];
		return $weed['user_id'];
	}
}

?>