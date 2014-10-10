<?php
/**
* 
*/
class UserDAO extends BaseDAO
{
	
	public function create($user) {
		$query = 'INSERT INTO user (username, password, email, time, deleted) VALUES (\'' 
				. $user->get_username() . '\',\'' 
				. $user->get_password() . '\',\''
				. $user->get_email() . '\',\'' 
				. $user->get_time() . '\',' 
				. $user->get_deleted() . ')';
		$result = $this->db_conn->insert($query);
		return $result;
	}
	
	public function update($user) {
		$query = 'UPDATE user SET '
			.'email = \'' . $user->get_email() . '\', '
			.'username = \'' . $user->get_username() . '\', '
			.'description = \'' . $user->get_description() . '\'';
		
		if ($user->get_user_type() && strtolower($user->get_user_type()) != 'user') {
			$query = $query . ', storename = \'' . $user->get_storename() . '\', '
				.'address_street = \'' . $user->get_address_street() . '\', '
				.'address_city = \'' . $user->get_address_city() . '\', '
				.'address_state = \'' . $user->get_address_state() . '\', '
				.'address_country = \'' . $user->get_address_country() . '\', '
				.'address_zip = \'' . $user->get_address_zip() . '\', '
				.'phone = \'' . $user->get_phone() . '\', '
				.'latitude = ' . $user->get_latitude() . ', '
				.'longitude = ' . $user->get_longitude();
				//user type should be updated separately, should not allow user to modify it
		}
			
	    $query = $query . ' WHERE id = ' . $user->get_id();
		$this->db_conn->query($query);
	}
	
	public function update_has_avatar($user) {
		$query = 'UPDATE user SET has_avatar = ' 
				. $user->get_has_avatar() . ' WHERE id = ' . $user->get_id();

		$this->db_conn->query($query);
	}
	
	public function username_exist($username) {
		$query = 'SELECT COUNT(*) as number FROM user where username=\'' . $username . '\'';
		$result = $this->db_conn->query($query);
		$data = mysql_fetch_assoc($result);
		if ($data['number'] == 0) {
			return false;
		} else {
			return true;
		}
	}
	
	public function get_users_with_coordinate($latitude, $longitude, $range, $search_key) {
		$latitude_lower_bound = $latitude - $range;
		$latitude_upper_bound = $latitude + $range;
		$longitude_lower_bound = $longitude - $range;
		$longitude_upper_bound = $longitude + $range;
		$query = "SELECT * FROM user where latitude > $latitude_lower_bound and latitude < $latitude_upper_bound and longitude > $longitude_lower_bound && longitude < $longitude_upper_bound && user_type <> 'user'";
		if (isset($search_key)) {
			$query = "$query && storename like '%$search_key%'";
		}
		$result = $this->db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	public function get_uernames_with_prefix($prefix, $count_limit) {		
		$query = 'SELECT id, username FROM user where username like \'' . $prefix . '%\' limit ' . $count_limit;
		$result = $this->db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	public function get_following_usernames($user_id, $currentUser_id, $count_limit) {		
		$query = 'SELECT user.id as id, user.username as username FROM follow join user on follow.followee_uid = user.id where follow.follower_uid = '. $user_id . ' LIMIT ' . $count_limit;
		$result = $this->db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$relationship = $this->getRelationship($currentUser_id, $user['id']);
				$user['relationshipWithCurrentUser'] = $relationship;
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	public function get_follower_usernames($user_id, $currentUser_id, $count_limit) {		
		$query = 'SELECT user.id as id, user.username as username FROM follow join user on follow.follower_uid = user.id where follow.followee_uid = '. $user_id . ' LIMIT ' . $count_limit;
		$result = $this->db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$relationship = $this->getRelationship($currentUser_id, $user['id']);
				$user['relationshipWithCurrentUser'] = $relationship;
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	public function find_by_username($username) {

		/* grab the users from the db */
		$query = 'SELECT * FROM user where username = \'' . $username . '\'';

		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			$user = mysql_fetch_assoc($result);
			return $user;
		} else {
			return null;
		}
	}
	
	public function find_by_user_id($id) {
		$query = "SELECT * FROM user WHERE id = " . $id;
		
		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			$user_array = mysql_fetch_assoc($result);
			$user = new User();
			$user->set_id($id);
			$user->set_username($user_array['username']);
			$user->set_password($user_array['password']);
			$user->set_email($user_array['email']);
			$user->set_time($user_array['time']);
			$user->set_deleted($user_array['deleted']);
			$user->set_has_avatar($user_array['has_avatar']);
			return $user;
		} else {
			return null;
		}
	}
	
	public function setUserDevice($user_id, $device_id) {
		$query = "SELECT * FROM device WHERE user_id = $user_id and device_id = '$device_id'";
		
		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			//already exists
		} else {
			$query = "INSERT INTO device VALUES($user_id,'$device_id')";	
			$this->db_conn->insert($query);
		}
	}
		
	public function find_by_id($id, $currentUser_id) {
		
		$query = "SELECT * FROM user WHERE id = ". $id;
		
		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			$user = mysql_fetch_assoc($result);
			$followerCount = $this->getFollowerCount($id);
			$user['followerCount'] = $followerCount;
			$followingCount = $this->getFollowingCount($id);
			$user['followingCount'] = $followingCount;
			$weedCount = $this->getWeedCount($id);
			$user['weedCount'] = $weedCount;
			$relationship = $this->getRelationship($currentUser_id, $id);
			$user['relationshipWithCurrentUser'] = $relationship;
			return $user;
		} else {
			return null;
		}
	}
	
	public function getUsersWaterWeed($currentUser_id, $weed_id) {
		$query = "SELECT user.username, user.id FROM water, user WHERE water.user_id = user.id AND water.weed_id = $weed_id";
		$result = $this->db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$relationship = $this->getRelationship($currentUser_id, $user['id']);
				$user['relationshipWithCurrentUser'] = $relationship;
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	public function getUsersSeedWeed($currentUser_id, $weed_id) {
		$query = "SELECT user.username, user.id FROM seed, user WHERE seed.user_id = user.id AND seed.weed_id = $weed_id";
		$result = $this->db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$relationship = $this->getRelationship($currentUser_id, $user['id']);
				$user['relationshipWithCurrentUser'] = $relationship;
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	private function getRelationship($userA_id, $userB_id) {
		if($userA_id == $userB_id)
			return 0;
		$isAFollowingB = $this->isAFollowingB($userA_id, $userB_id);
		$isBFollowingA = $this->isAFollowingB($userB_id, $userA_id);
		if($isAFollowingB && $isBFollowingA){
			return 4;
		}else if($isAFollowingB){
			return 3;
		}else if($isBFollowingA){
			return 2;
		}else{
			return 1;
		}
	}
	
	public function setAFollowB($userA_id, $userB_id) {
		if($userA_id == $userB_id)
			return false;
		$query = "INSERT INTO follow VALUES($userB_id,$userA_id)";	
		$this->db_conn->query($query);
	}
	
	public function setAUnfollowB($userA_id, $userB_id) {
		if($userA_id == $userB_id)
			return false;
		$query = "DELETE FROM follow WHERE followee_uid = $userB_id AND follower_uid = $userA_id";	
		$this->db_conn->query($query);
	}
	
	
	private function isAFollowingB($userA_id, $userB_id) {
		$query = "SELECT count(*) as count FROM follow WHERE followee_uid = $userB_id AND follower_uid = $userA_id";	
		$result = $this->db_conn->query($query);
		$isAFollowingB = false;
		$val = mysql_fetch_assoc($result)['count'];
		if ($val > 0) {
			$isAFollowingB = true;
		}
		return $isAFollowingB;
	}
	
	private function getFollowerCount($id) {
		
		$query = "SELECT count(*) as count FROM follow WHERE followee_uid = ". $id;
		
		$result = $this->db_conn->query($query);
		
		if (mysql_num_rows($result)) {
			$val = mysql_fetch_assoc($result);
			return $val['count'];
		} else {
			return 0;
		}
	}
	
	private function getFollowingCount($id) {
		
		$query = "SELECT count(*) as count FROM follow WHERE follower_uid = ". $id;
		
		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			$val = mysql_fetch_assoc($result);
			return $val['count'];
		} else {
			return 0;
		}
	}
	
	
	private function getWeedCount($id) {
		
		$query = "SELECT count(*) as count FROM weed WHERE deleted = 0 AND user_id = ". $id;
		
		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			$val = mysql_fetch_assoc($result);
			return $val['count'];
		} else {
			return 0;
		}
	}
}

?>