<html>
	<head>
		<title><?php echo $title ?></title>
		<style>
			body {background-color:#359946}
			img {
				width:100px;
				height:100px;
				margin-left:200px;
				margin-right:200px;
				margin-bottom:30;
			}
			p {
				text-align:center;
			}
			
			#center {
				width:500px;
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
			
			@media screen and (max-device-width: 480px) {
				img {
					width:200px;
					height:200px;
					
					margin-left:37%;
				}
				
				#center {
					width:80%;
					height:70%;
					
					color:white;
					font-size:40px;
					font-family:verdana;
				
					position: absolute;
					top:0;
					bottom: 0;
					left: 0;
					right: 0;
					margin: auto;
				}
			}
		</style>
	</head>
	<body>
		<div id="center">
			<img src="/page/images/logo.png" alt="Logo">
			<p ><?php echo $message ?></p>
			<p><?php echo $sub_message ?></p>
		</div>
	</body>
</html>
