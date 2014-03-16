<?php

class DbConnection 
{
	public $host = '54.215.236.186';
    
    public $username = 'weeda';

    public $password = 'weeda';

	public $database = 'weeda';

	private $db_conn;
	
	function __construct() {
		/* connect to the db */
		$this->db_conn = mysql_connect($this->host, $this->username, $this->password) or die('Cannot connect to the DB');
		mysql_select_db($this->database, $this->db_conn) or die('Cannot select the DB');
	}
	
	function __destruct() {
		/* disconnect from the db */
        @mysql_close($this->db_conn);
	}

    private function init_connection() {
		$this->db_conn = mysql_connect($this->host, $this->username, $this->password) or die('Cannot connect to the DB');
		mysql_select_db($this->database, $this->db_conn) or die('Cannot select the DB');
	}
	
	public function query($query) {
		if ($this->db_conn == null) {
			$this->init_connection();
		}

		$result = mysql_query($query, $this->db_conn) or die('Errant query:  '.$query);
		return $result;
	}
}

?>