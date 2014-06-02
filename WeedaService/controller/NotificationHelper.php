<?php

ini_set('display_errors',1);
error_reporting(E_ALL);

class NotificationHelper
{
	protected $user_dao;
    /**
     * Call this method to get singleton
     *
     * @return UserFactory
     */
    public static function Instance()
    {
        static $inst = null;
        if ($inst === null) {
            $inst = new NotificationHelper();
        }
        return $inst;
    }

    /**
     * Private ctor so nobody else can instance it
     *
     */
    private function __construct()
    {
		$this->user_dao = new UserDao();
    }

	public function sendMessage($receiver_id, $message) {
		
		$query = "SELECT device_id FROM device WHERE user_id = $receiver_id";
		
		// Put your device token here (without spaces):
		$deviceToken = 'facc9d1b40e9fcb510ce81094f5456c87dbc4d5520f45b0f768756807d979342';

		// Put your private key's passphrase here:
		$passphrase = 'Iloveweed@309';

		// Put your alert message here:
		$message = 'Wukun loves pz forever!';

		////////////////////////////////////////////////////////////////////////////////

		$ctx = stream_context_create();
		stream_context_set_option($ctx, 'ssl', 'local_cert', 'ck.pem');
		stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);

		// Open a connection to the APNS server
		$fp = stream_socket_client(
			'ssl://gateway.sandbox.push.apple.com:2195', $err,
			$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

		if (!$fp)
			exit("Failed to connect: $err $errstr" . PHP_EOL);

		echo 'Connected to APNS' . PHP_EOL;

		// Create the payload body
		$body['aps'] = array(
			'alert' => $message,
			'badge'=> 1,
			'sound' => 'default'
			);

		// Encode the payload as JSON
		$payload = json_encode($body);

		// Build the binary notification
		$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

		// Send it to the server
		$result = fwrite($fp, $msg, strlen($msg));

		if (!$result)
			echo 'Message not delivered' . PHP_EOL;
		else
			echo 'Message successfully delivered' . PHP_EOL;

		// Close the connection to the server
		fclose($fp);
	} 


}
?>
