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
			$relationship = $this->getRelationship($currentUser_id, $id);
			$user['relationshipWithCurrentUser'] = $relationship;
			return $user;
		} else {
			return null;
		}
	}
	
	public function getRelationship($userA_id, $userB_id) {
		if($userA_id == $userB_id)
			return 0;
		$db_conn = new DbConnection();
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