<%php

class DbConnection 
{
    public $connectionString;

	public $host = '54.215.236.186';
    
    public $username = 'weeda';

    public $password = 'weeda';

    public function init_connection() 
	{
		/* connect to the db */
		$link = mysql_connect($this->host, $this->username, $this->password) or die('Cannot connect to the DB');
		mysql_select_db('weeda',$link) or die('Cannot select the DB');
		
		return $link;
	}
}

%>