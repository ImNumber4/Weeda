<?php

/* connect to the db */
$link = mysql_connect('54.215.236.186','weeda','weeda') or die('Cannot connect to the DB');
mysql_select_db('weeda',$link) or die('Cannot select the DB');

/* grab the users from the db */
$query = "SELECT * FROM user";
$result = mysql_query($query,$link) or die('Errant query:  '.$query);

/* create one master array of the records */
$users = array();
if(mysql_num_rows($result)) {
	while($user = mysql_fetch_assoc($result)) {
		$users[] = $user;
	}
}

/* output in necessary format */

header('Content-type: application/json');
echo json_encode(array('users'=>$users));


/* disconnect from the db */
@mysql_close($link);

?>