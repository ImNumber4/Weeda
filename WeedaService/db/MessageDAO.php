<?php
/**
* 
*/
class MessageDAO extends BaseDAO
{
	public function create($message) {
		$query = 'INSERT INTO message (sender_id, receiver_id, message, type, related_weed_id, time) VALUES ('
			    . $message->get_sender_id() . ',' 
			    . $message->get_receiver_id() . ',\'' 
				. $message->get_message() . '\',\'' 
				. $message->get_type() . '\','
				. ($message->get_related_weed_id() == NULL ? 'NULL' : $message->get_related_weed_id()) . ',\''  
				. $message->get_time() . '\')';
		$id = $this->db_conn->insert($query);
		return $id;
	}
	
	/**
	* return messages that 'invole' given user and are unread or less than one day old
	*/
	public function query($user_id) {
		$query = 'SELECT message.id as id, sender.username as sender_username, receiver.username as receiver_username, sender_id, receiver_id, message, message.time as time, message.deleted as deleted, type, related_weed_id, is_read FROM message LEFT JOIN user as sender on message.sender_id = sender.id LEFT JOIN user as receiver on message.receiver_id = receiver.id WHERE (is_read = false or message.time > timestampadd(hour, -24, now())) and (receiver_id = ' . $user_id . ' or sender_id = ' . $user_id . ')';
		
		$result = $this->db_conn->query($query);

		$messages = array();
		if(mysql_num_rows($result)) {
			while($message = mysql_fetch_assoc($result)) {
				if ($user_id == $message['receiver_id']) {
					$participant_id = $message['sender_id'];
					$participant_username = $message['sender_username'];
				} else {
					$participant_id = $message['receiver_id'];
					$participant_username = $message['receiver_username'];
				}
				$is_read = $user_id == $message['sender_id'] ? 1 : $message['is_read'];
				$messages[] = array('id' => $message['id'], 'sender_id' => $message['sender_id'], 'message' => $message['message'], 'time' => $message['time'], 'deleted' => $message['deleted'], 'type' => $message['type'], 'related_weed_id' => $message['related_weed_id'], 'is_read' => $is_read, 'participant_id' => $participant_id, 'participant_username' => $participant_username);
			}
		}
		return $messages;
	}
	
	
	
	/**
	* requiring receiver_id to avoid setting wrong message to be read
	*/
	public function mark_message_as_read($receiver_id, $message_id) {
		$query = "UPDATE message SET is_read = true WHERE id = $message_id AND receiver_id = $receiver_id";
		return $this->db_conn->query($query);
	}
}

?>