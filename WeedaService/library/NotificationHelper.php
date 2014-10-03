<?php

class NotificationHelper
{
   	
	public static function sendMessage($deviceToken, $message) {
		
		$passphrase = 'Iloveweed@309';
		
		$ctx = stream_context_create();
		stream_context_set_option($ctx, 'ssl', 'local_cert', 'controller/ck.pem');
		stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);

		// Open a connection to the APNS server
		$fp = stream_socket_client(
			'ssl://gateway.sandbox.push.apple.com:2195', $err,
			$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

		if (!$fp)
			exit("Failed to connect: $err $errstr" . PHP_EOL);

		error_log('Connected to APNS' . PHP_EOL);

		// Create the payload body
		$body['aps'] = array(
			'alert' => $message,
			'badge'=> 1,
			'sound' => 'default'
			);

		// Encode the payload as JSON
		$payload = json_encode($body);

		// Build the binary notification
		$msg = chr(1) . pack("N", $msg_id) . pack("N", $expiry) . pack('n', 32) . pack('H*', $token) . pack('n', strlen($payload)) . $payload; 

		// Send it to the server
		$result = fwrite($fp, $msg, strlen($msg));

		if (!$result)
			error_log('Message not delivered' . PHP_EOL);
		else
			error_log('Message successfully delivered' . PHP_EOL);

		// Close the connection to the server
		fclose($fp);
	} 


}
?>
