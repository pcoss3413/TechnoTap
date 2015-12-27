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

include 'scoredb.php';
$scoreboard = new scoreboarddb();

function decrypt($d){
	$decrypted = $d;
	
	$ivSize = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_128, MCRYPT_MODE_CBC);
	$key = base64_decode("BASE_64_ENCODED_KEY"); //This key will prevent a 3rd party from submitting false scores, so make it something long and random.
	$i = 0;
	
	do {
		$peices = explode(':', $decrypted); //See iOS source for expected formatting
		$decrypted = rtrim(mcrypt_decrypt(MCRYPT_RIJNDAEL_128, $key,  base64_decode($peices[1]), MCRYPT_MODE_CBC, base64_decode($peices[0])), "\0"); //decrypted results can be a little funky, hence the rtrim.
		$i++;
	}
	while ($i < 7); //7 layers of AES encryption, each with it's own IV keeps our score submissions safe and 7 times more process intensive to brute force.
	    
    return $decrypted;
}


function formatForiOS($searchResult, $includeId){ //We have a 15 second time-out set on the iPhone, so the smaller the data pack, the better!
	$result = array();						      //This function creates an array instead of a dictionary, so instead of having "username" repeated
	foreach($searchResult as $r){				  //200 times, wasting bandwidth, we have a keyless array instead!
		$tmp = array($r["username"], $r["country"], $r["score"]);
		if($includeId)
			array_push($tmp, $r["id"]);
		array_push($result, $tmp);
	}

	return $result;
}

if ($_POST["data"]){
	header('Content-Type: application/json');
	
	$info = explode("|", decrypt($_POST["data"]));
	
	if (sizeof($info) > 2){
		//We probably don't need these mysql escapes here, since these requests are encrypted, but just in case
		//a hacker does crack the AES, the worst they will be able to do is insert a fake score
		$scoreId = $scoreboard->addScore(mysql_escape_string($info[0]), mysql_escape_string($info[1]), mysql_escape_string($info[2]));
		$recent = $scoreboard->getRecentScores();

		echo json_encode(array('scoreId'=>$scoreId, 'recent'=>formatForiOS($recent, true),'success'=>1));
	}
	else {
		echo json_encode(array('message'=>'Submission failed. Please try again.','success'=>0));
	}
	
}
else if ($_POST["action"]){
	header('Content-Type: application/json');
	
	if ($_POST["action"] == "getTop100"){
		echo json_encode(array('scores'=>formatForiOS($scoreboard->getTop100Scores(), false), 'success'=>1));
	}
	else if ($_POST["action"] == "getMostRecent"){
		echo json_encode(array('scores'=>formatForiOS($scoreboard->getRecentScores(), true), 'success'=>1));
	}
	else{
		echo json_encode(array('message'=>'Invalid Request', 'success'=>0));
	}
}
else{
		//Do testing stuff here!		
		//$scoreboard->deleteAll();
		
		$d = 0;

		$top100 = $scoreboard->getTop100Scores();
		$recent = $scoreboard->getRecentScores();
		$rank = 1;
		
		echo '<center><br /><table border=1 width= 300 style="float:left">';
		echo '<tr><td colspan="4"><h3>Top 100</h3></td></tr>';
		foreach($top100 as $score){
			echo '<tr>';
			echo '<td><b>'.$rank.'</b></td>';
			
			if(!strcmp($score['username'], "*game_maker*")){  //Because I'm vain!
				echo '<td><span style="color:red">Game Maker</span></td>';
			}
			else{
				echo '<td>'.$score['username'].'</td>';
			}
			
        	echo '<td>'.$score['score'].'</td>';
        	echo '<td><img src="/TechnoTap/flags/'.$score['country'].'.png"  alt="'.$score['country'].'" />'.'</td>';
        	echo '</tr>';
        	$rank++;
		}
		$rank = 1;
		echo '</table>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
		echo '<table border=1 width=300 style="float:left">';
		echo '<tr><td colspan="5"><h3>Most Recent</h3></td></tr>';
		foreach($recent as $score){
			echo '<tr>';
			echo '<td><b>'.$rank.'</b></td>';
			
			if(!strcmp($score['username'], "<super secret username here!>")){
				echo '<td><span style="color:red">Game Maker</span></td>';
			}
			else{
				echo '<td>'.$score['username'].'</td>';
			}
			
        	echo '<td>'.$score['score'].'</td>';
        	echo '<td><img src="/TechnoTap/flags/'.$score['country'].'.png"  alt='.$score['country'].'/>'.'</td>';
        	echo '<td>'.$score['timestamp'].'</td>';
        	echo '</tr>';
        	$rank++;
		}
		echo '</table>';
}

?>