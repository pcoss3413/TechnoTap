<?php

/*
*  Serverside code for Techno Tap score submission
*  Copyright (C) 2015  Patrick T. Cossette
*
*  This program is free software; you can redistribute it and/or
*  modify it under the terms of the GNU General Public License
*  as published by the Free Software Foundation; either version 2
*  of the License, or (at your option) any later version.
*  
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*  
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software
*  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

ini_set("post_max_size", "20M");

class scoreboarddb{
	//Put your own database info here!
	public $dbname = "DATABASE_NAME_HERE";
	public $dbuser = "DATABASE_USER_HERE";
	public $dbpassword = "DATABASE_PASSWORD_HERE";
	public $dbhost = "localhost";
	public $connection = NULL;

	function __construct(){
		$this->connection = mysqli_connect($this->dbhost, $this->dbuser, $this->dbpassword, $this->dbname) or die("Unable to access database! " . mysql_error());
		
		$this->create_tables();  //Configure the database for use (It wont' hurt anything but performance if you run this every time, I recommend you uncomment it after the database is created though!)
		$this->deleteOldScores();
	}
	
	function deleteOldScores(){
		$lowestHighScore = 0;
		$oldestRecentScore = 0;
		
		$sql = "SELECT * FROM scores ORDER BY score DESC LIMIT 100";
		$result = mysqli_query($this->connection, $sql);
		
		if($result){
			$top100 = array();
			while($row = $result->fetch_assoc()){
     			$top100[] = $row;
			}
			if (count($top10) >= 100){
				return;
			}
			$lowestHighScore = end($top100)["score"];
		}
		
		$sql = "SELECT * FROM scores ORDER BY timestamp DESC LIMIT 100";
		$result = mysqli_query($this->connection, $sql);
		
		if($result){
			$oldestRecentScore = time()+1000;
			while($row = $result->fetch_assoc()){
     			$oldestRecentScore = min($oldestRecentScore, $row["timestamp"]);
			}
		}
		
		$sql ="DELETE FROM scores WHERE (score < $lowestHighScore AND timestamp < $oldestRecentScore)";
		$result = mysqli_query($this->connection, $sql);
	}
	
	function deleteScoresForUser($user){
		$user = mysql_escape_string($user);
		$sql ="DELETE FROM scores WHERE username=\"$user\"";
		$result = mysqli_query($this->connection, $sql);
	}
	
	function create_tables(){
		$sql="CREATE TABLE IF NOT EXISTS scores(
			username VARCHAR(64) NOT NULL,
			country VARCHAR(64) NOT NULL,
			score INT,
			timestamp INT,
			id INT(11) NOT NULL auto_increment,
			PRIMARY KEY (id)
			)";
			
			$result = mysqli_query($this->connection, $sql);
	}
	
	
	function deleteAll(){
		return;  //Force us to edit the code to *actually* delete ALL records!
		
		$sql ="DELETE FROM scores";
		$result = mysqli_query($this->connection, $sql);
		return $result;
	}
	
	function getTop100Scores(){
		$sql = "SELECT * FROM scores ORDER BY score DESC LIMIT 100";
		$result = mysqli_query($this->connection, $sql);
		
		if($result){
			$top100 = array();
			while($row = $result->fetch_assoc()){
     			$top100[] = $row;
			}
			return $top100;
		}
		
		return "Error!";
	}
	
	function getRecentScores(){
		$oneHourAgo = time()-60*60;
		$sql = "SELECT * FROM scores ORDER BY timestamp DESC LIMIT 100";
		$result = mysqli_query($this->connection, $sql);
		
		if($result){
			$recent = array();
			while($row = $result->fetch_assoc()){
     			$recent[] = $row;
			}
			return $recent;
		}
		
		return "Error!";
	}
	
	function addScore($username, $country, $score){
		$sql="INSERT into scores (username, timestamp, country, score) VALUES (\"$username\", ".time().", \"$country\", \"$score\")";
		$result = mysqli_query($this->connection, $sql);
		if(!$result){
			die('Error: ' . mysql_error());
		}
		
		$scoreId = mysql_insert_id();
		return $scoreId;
		
	}	
}


?>
