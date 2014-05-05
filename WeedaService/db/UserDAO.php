<?php
/**
* 
*/
class UserDAO extends BaseDAO
{
	private $user;
	
	public function create($user) {
		$query = 'INSERT INTO user (username, password, email, time, deleted) VALUES (\'' 
				. $user->get_username() . '\',\'' 
				. $user->get_password() . '\',\''
				. $user->get_email() . '\',\'' 
				. $user->get_time() . '\',' 
				. $user->get_deleted() . ')';
		error_log('insert query:' . $query);
		$result = $this->db_conn->insert($query);
		if ($result == 0) {
			error_log("SQL failed. Query: " . $query);
		}
		
		return $result;
	}
	
	public function update($user) {
		$query = 'UPDATE user SET email = \'' 
				. $user->get_email() . '\',time = \'' 
				. $user->get_time() . '\', deleted = ' 
				. $user->get_deleted() . ', has_avatar = ' 
				. $user->get_has_avatar() . ' WHERE id = ' . $user->get_id();

		$result = $this->db_conn->query($query);
		if ($result == 0) {
			error_log("SQL failed. Query: " . $query);
		}
		return $result;
	}
	
	public function username_exist($username) {
		$db_conn = new DbConnection();
		
		$query = 'SELECT COUNT(*) as number FROM user where username=\'' . $username . '\'';
		error_log('query: ' . $query);
		
		$result = $db_conn->query($query);
		error_log('query result: ' . $result);
		$data = mysql_fetch_assoc($result);
		error_log($data['number']);
		if ($data['number'] == 0) {
			return false;
		} else {
			return true;
		}
	}
	
	public function find_by_username($username) {
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
	
	public function find_by_id($id, $currentUser_id) {
		
		$db_conn = new DbConnection();
		
		$query = "SELECT * FROM user WHERE id = ". $id;
		
		$result = $db_conn->query($query);
		if (mysql_num_rows($result)) {
			$user = mysql_fetch_assoc($result);
			$followerCount = $this->getFollowerCount($db_conn, $id);
			$user['followerCount'] = $followerCount;
			$followingCount = $this->getFollowingCount($db_conn, $id);
			$user['followingCount'] = $followingCount;
			$weedCount = $this->getWeedCount($db_conn, $id);
			$user['weedCount'] = $weedCount;
			$relationship = $this->getRelationship($db_conn, $currentUser_id, $id);
			$user['relationshipWithCurrentUser'] = $relationship;
			return $user;
		} else {
			return null;
		}
	}
	
	public function getUsersWaterWeed($currentUser_id, $weed_id) {
		$db_conn = new DbConnection();
		$query = "SELECT user.username, user.id FROM water, user WHERE water.user_id = user.id AND water.weed_id = $weed_id";
		$result = $db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$relationship = $this->getRelationship($db_conn, $currentUser_id, $user['id']);
				$user['relationshipWithCurrentUser'] = $relationship;
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	public function getUsersSeedWeed($currentUser_id, $weed_id) {
		$db_conn = new DbConnection();
		$query = "SELECT user.username, user.id FROM seed, user WHERE seed.user_id = user.id AND seed.weed_id = $weed_id";
		$result = $db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$relationship = $this->getRelationship($db_conn, $currentUser_id, $user['id']);
				$user['relationshipWithCurrentUser'] = $relationship;
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	private function getRelationship($db_conn, $userA_id, $userB_id) {
		if($userA_id == $userB_id)
			return 0;
		$isAFollowingB = $this->isAFollowingB($db_conn, $userA_id, $userB_id);
		$isBFollowingA = $this->isAFollowingB($db_conn, $userB_id, $userA_id);
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
		$db_conn = new DbConnection();
		$query = "INSERT INTO follow VALUES($userB_id,$userA_id)";	
		return $db_conn->query($query);
	}
	
	public function setAUnfollowB($userA_id, $userB_id) {
		if($userA_id == $userB_id)
			return false;
		$db_conn = new DbConnection();
		$query = "DELETE FROM follow WHERE followee_uid = $userB_id AND follower_uid = $userA_id";	
		return $db_conn->query($query);
	}
	
	
	private function isAFollowingB($db_conn, $userA_id, $userB_id) {
		$query = "SELECT count(*) as count FROM follow WHERE followee_uid = $userB_id AND follower_uid = $userA_id";	
		$result = $db_conn->query($query);
		$isAFollowingB = false;
		$val = mysql_fetch_assoc($result)['count'];
		if ($val > 0) {
			$isAFollowingB = true;
		}
		return $isAFollowingB;
	}
	
	
	private function getFollowerCount($db_conn, $id) {
		
		$query = "SELECT count(*) as count FROM follow WHERE followee_uid = ". $id;
		
		$result = $db_conn->query($query);
		if (mysql_num_rows($result)) {
			$val = mysql_fetch_assoc($result);
			return $val['count'];
		} else {
			return 0;
		}
	}
	
	private function getFollowingCount($db_conn, $id) {
		
		$query = "SELECT count(*) as count FROM follow WHERE follower_uid = ". $id;
		
		$result = $db_conn->query($query);
		if (mysql_num_rows($result)) {
			$val = mysql_fetch_assoc($result);
			return $val['count'];
		} else {
			return 0;
		}
	}
	
	
	private function getWeedCount($db_conn, $id) {
		
		$query = "SELECT count(*) as count FROM weed WHERE deleted = 0 AND user_id = ". $id;
		
		$result = $db_conn->query($query);
		if (mysql_num_rows($result)) {
			$val = mysql_fetch_assoc($result);
			return $val['count'];
		} else {
			return 0;
		}
	}
}

?>