<?php

// ini_set('display_errors',1);
// error_reporting(E_ALL);

/**
* Sending emails
*/
class MailController extends Controller
{
	/*Init
	function __construct(argument)
	{
		# code...
	}
	*/
	
	public function forgotPassword($parameters)
	{	
		if (!isset($parameters['username'])) {
			throw new InvalidRequestException('Inputs are not valid due to No user_name');
		}
				
		$userDao = new UserDAO();
		$user = $userDao->find_by_username($parameters['username']);
		if (!$user) {
			throw new InvalidaRequestException('Invalid username, please make sure input the correct username.');
		}
		
		if (strcmp($parameters['email'], $user['email']) !== 0) {
			error_log('Email doesn\'t match. Please make sure input the correct email address.');
			throw new InvalidRequestException('Email doesn\'t match. Please make sure input the correct email address.');
		}
		$date = date_create();

		$md5_password = md5(date_timestamp_get($date) . $user['password'] . $user['email']);
		error_log("token: " . $md5_password);
		//save token
		$tokenDao = new TokenDAO();
		$token['token_id'] = $md5_password;
		$token['user_id'] = $user['id'];
		$token['time'] = date_timestamp_get($date);
		$tokenDao->create($token);
		
		//Send email
		$parameters['send_to'] = $user['email'];
		$parameters['subject'] = 'Please renew your password';
		$parameters['body'] = $this->generate_forgot_password_body($user, $md5_password);
		
		$this->send_mail($parameters);
	}
	
	private function send_mail($parameters)
	{
		$mail = new PHPMailer();
		
		//For debug
		// $mail->SMTPDebug = 3;  
		
		$mail->isSMTP();
		$mail->IsHTML(true);
		$mail->Host = "smtp.gmail.com";
		$mail->SMTPAuth = true;
		$mail->Username = 'Weeda.LaVida@gmail.com';
		$mail->Password = 'Iloveweed@309';
		$mail->SMTPSecure = 'tls';                            
		$mail->Port = 587;
		
		$mail->From = 'Weeda.LaVida@gmail.com';
		$mail->FromName = 'Cannablaze.com';
		$mail->addAddress($parameters['send_to'], $parameters['username']);
		
		$mail->Subject = $parameters['subject'];
		$mail->Body = $parameters['body'];
		
		if (!$mail->send()) {
			error_log('Email sending failed, error ' . $mail->ErrorInfo);
		} else {
			error_log('Email has been sent');
		}
	}
	
	private function generate_forgot_password_body($user, $md5_password)
	{
		$body = "Dear " . $user['username'] . ",";
		$body = $body . "<br/><br/>";
		$body = $body . "Please click blow link to reset password <br/>";
		$body = $body . "<a>" . "www.cannablaze.com/user/forgotPassword/". $md5_password . "</a><br/><br/>";
		$body = $body . "Best Regards,<br/>";
		$body = $body . "Cannablaze Team <br/> @cannablaze.com";
		return $body;
	}
}

?>