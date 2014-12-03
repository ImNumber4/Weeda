<?php

?>

<html>
	<head>
		<title>Reset -- Connablaze</title>
		<style>
			body {background-color:#359946}
			img {
				width:100px;
				height:100px;
				margin-left:150px;
				margin-bottom:50px
			}
			#input {
				width:400px;
				height:500px;
				
				color:white;
				font-size:12px;
				font-family:verdana;
				
				position: absolute;
				top:0;
				bottom: 0;
				left: 0;
				right: 0;
				margin: auto;
			}
			
			.btn_submit {
				width:400;
				height:30;
				border:0px;
				background:#2a912c;
				color:white;
				font-size:100%;
			}
			
			.input_password_up {
				width:400;
				height:40;
				padding:10;
				border-top:0px;
				border-left:0px;
				border-right:0px;
				border-bottom:1px solid #359946;
				border-radius : 4px 4px 0px 0px ;
			}
			.input_password_down {
				width:400;
				height:40;
				padding:10;
				border-top:1px solid #359946;
				border-left:0px;
				border-right:0px;
				border-bottom:0px;
				border-radius: 0px 0px 4px 4px;
			}
			
			@media screen and (max-device-width: 480px) {
					
				img {
					width:200;
					height:200;
					margin-left:35%;
					margin-bottom:80px;
				}
				
				#input {
					width:80%;
					height:70%;
					color:white;
					font-family:verdana;
				
					position: absolute;
					top:0;
					bottom: 0;
					left: 0;
					right: 0;
					margin: auto;
				}
				
				.btn_submit {
					-webkit-appearance: none;
					width:100%;
					height:100;
					border:0px;
					background:#2a912c;
					color:white;
					font-size:40px;
					
/*					margin: 10%;*/
				}
			
				.input_password_up {
					width:100%;
					height:100;
					padding:10;
					border-top:0px;
					border-left:0px;
					border-right:0px;
					border-bottom:1px solid #359946;
					border-radius : 8px 8px 0px 0px ;
					
					font-size:40px;
					
/*					margin-left:10%;*/
				}
				.input_password_down {
					width:100%;
					height:100;
					padding:10;
					border-top:1px solid #359946;
					border-left:0px;
					border-right:0px;
					border-bottom:0px;
					border-radius: 0px 0px 8px 8px;
					
					font-size:40px;
					
/*					margin-left:10%;*/
				}
				.confirmMessage {
					font-size:40px;
				}
			}
			
/*			input::-webkit-input-placeholder { font-size: 10pt; color: gray; }
			input::-moz-placeholder { font-size: 10pt; color: gray; }
			input:-ms-input-placeholder { font-size: 10pt; color: gray; }
			input:-moz-placeholder { font-size: 10pt; color: gray; }*/

		</style>
		
		<script>
			function checkPass()
			{
			    var pass1 = document.getElementById("password");
			    var pass2 = document.getElementById("comfirm_password");
			    var message = document.getElementById("confirmMessage");

			    var badColor = "#ff6666";
				
				if (pass1.value.length == 0) {
					message.style.color = badColor;
					message.innerHTML = "new password can not be empty.";
					return false;
				}
				
				if (pass2.value.length == 0) {
					message.style.color = badColor;
					message.innerHTML = "confirm password can not be empty.";
					return false;
				}
				
			    if(pass1.value != pass2.value){
			        message.style.color = badColor;
			        message.innerHTML = "Passwords Do Not Match!"
					
					return false;
			    }
				
				if (!preg_match("((?=.*\\d)(?=.*[A-Z])(?=.*[a-z]).{6,16})",$pass1.value)) {
					message.style.color = badColor;
					message.innerHTML = "Password needs to have least 6 characters, include 1 uppercase and 1 lowercase and 1 Digital.";
					return false;
				}

				return true;
			}
		</script>
	</head>
	<body>
		<!-- <div id="logo">

		</div> -->
		<div id="input">
			<img src="/page/images/logo.png" alt="Logo">
			<br/>
			<form action="/user/reset" method="POST" onsubmit="return checkPass()">
				<input class="input_password_up" type="password" id="password" name="password" placeholder="new password">
				<input class="input_password_down" type="password" id="comfirm_password" placeholder="confirm password">
				<input type="hidden" name="token_id" value="<?php echo $token_id ?>" >
				<input type="hidden" name="user_id" value="<?php echo $user_id ?>" >
				<p>
					<span id="confirmMessage" class="confirmMessage"></span>
				</p>
				<p>
					<input type="submit" value="Change Password" class="btn_submit">
				</p>
			</form>
		</div>
	</body>
</html>