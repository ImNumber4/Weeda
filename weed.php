<?php
include("dbconnect.php");

/* connect to the db */
$db_conn = new DbConnection();

/* grab the users from the db */
$query = "SELECT * FROM weed";

$result = $db_conn->query($query);

/* create one master array of the records */
$weeds = array();
if(mysql_num_rows($result)) {
	while($weed = mysql_fetch_assoc($result)) {
		$weeds[] = $weed;
	}
}

/* output in necessary format */

header('Content-type: application/json');
echo json_encode(array('weeds'=>$weeds));


/* disconnect from the db */
@mysql_close($link);

?>