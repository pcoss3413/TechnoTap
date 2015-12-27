<!--
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
*
 -->


<!DOCTYPE html>

<html>
<head>
<title>Techno Tap</title>
<link rel="icon" 
      type="image/png" 
      href="/TechnoTap/favicon.png" />
</head>

<style>
body {background-color:black;}
p {color:white;}
td {color:white;}
h2 {color:white;}
div.tableContainer{
  width: 700px;
  height:auto;
  display: block;
  margin-left: auto;
  margin-right: auto;
  background-color: #000000;
  display:table;
}

div.privacy{
  text-align:left;
  width: 600px;
  height:auto;
  display: block;
  margin-left: auto;
  margin-right: auto;
  background-color: #000000;
  display:table;
}
</style>

<body>

<center>
<a href="https://itunes.apple.com/us/app/techno-tap/id986631346?ls=1&mt=8" target="_blank"><img src="/TechnoTap/intro.png" alt="Techno Tap" /></a><br />
<a href="https://itunes.apple.com/us/app/techno-tap/id986631346?ls=1&mt=8" target="_blank"><img src="/TechnoTap/appstore.png" alt="Techno Tap" /></a><br />
<?php

$pageFound = false;
if($_GET["page"]){
	if($_GET["page"] == "privacy"){
	echo '<br />';
	echo '<a href="/TechnoTap/">Scoreboard</a>';
	echo '&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:white;">|</span>&nbsp;&nbsp;&nbsp;&nbsp;';
	echo '<a href="/TechnoTap/?page=about">About</a><br /><br />';
	
		echo "<p><h2>Privacy Policy</h2></p><br />";
		echo '<div class="privacy"><p>';
		?>
Your privacy is very important to us. Accordingly, we have developed this Policy in order for you to understand how we collect, use, communicate and disclose and make use of personal information. The following outlines our privacy policy.
<br /><br />
Neither this website nor the Techno Tap iPhone app will collect or store any personal information. We're cool like that. If you submit a score to our servers, your score will remain visible until it is either pushed off the recent scoreboard (which stores the last 100 scores submitted) OR it is pushed off the top 100 scoreboard.
<br /><br />
If you discover this service being used incorrectly or would like your score removed, please do not hesitate to contact the system administrator: patrick @ digitaldiscrepancy . com .
<br /><br />
We are committed to conducting our business in accordance with these principles in order to ensure that the confidentiality of personal information is protected and maintained.
<br /><br />
</p</div><br />
<center><p>Copyright &copy; 2015 Patrick Cossette</p></center>
		<?php
		$pageFound = true;
	}
	else if ($_GET["page"] == "about"){
	echo '<br />';
	echo '<a href="/TechnoTap/?page=privacy">Privacy Policy</a>';
	echo '&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:white;">|</span>&nbsp;&nbsp;&nbsp;&nbsp;';
	echo '<a href="/TechnoTap/">Scoreboard</a><br /><br />';
		echo "<p><h2>About Techno Tap</h2></p>";
				echo '<div class="privacy"><p>';
		?>
Techno Tap is a solo venture created by software engineer Patrick Cossette in his spare time
</p</div><br />
<center><p>Copyright &copy; 2015 Patrick Cossette</p></center>
		<?php
		$pageFound = true;
	}
}

if(!$pageFound){
	include 'scoredb.php';
	$scoreboard = new scoreboarddb();
	echo '<br />';
	echo '<a href="/TechnoTap/?page=privacy">Privacy Policy</a>';
	echo '&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:white;">|</span>&nbsp;&nbsp;&nbsp;&nbsp;';
	echo '<a href="/TechnoTap/?page=about">About</a><br /><br />';
	
	echo "<h2>-Scoreboard-</h2></p><br /><br />";
		$top100 = $scoreboard->getTop100Scores();
		$recent = $scoreboard->getRecentScores();
		$rank = 1;
		
		echo '<div class="tableContainer"><br /><table border=1 width= 300 style="float:left">';
		echo '<tr><td colspan="4"><h3><center>Top 100</center></h3></td></tr>';
		echo '<tr>';
		echo '<td><b>Rank</b></td>';
		echo '<td><b>Name</b></td>';
		echo '<td><b>Score</b></td>';
		echo '<td><b>Country</b></td>';
		echo '</tr>';
		
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
		echo '</table>';
		echo '<table border=1 width=300 style="float:right">';
		echo '<tr><td colspan="5"><h3><center>Most Recent</center></h3></td></tr>';
		echo '<tr>';
		echo '<td><b>Rank</b></td>';
		echo '<td><b>Name</b></td>';
		echo '<td><b>Score</b></td>';
		echo '<td><b>Country</b></td>';
		echo '</tr>';
		
		foreach($recent as $score){
			echo '<tr>';
			echo '<td><b>'.$rank.'</b></td>';
			
			if(!strcmp($score['username'], "*game_maker*")){
				echo '<td><span style="color:red">Game Maker</span></td>';
			}
			else{
				echo '<td>'.$score['username'].'</td>';
			}
			
        	echo '<td>'.$score['score'].'</td>';
        	echo '<td><img src="/TechnoTap/flags/'.$score['country'].'.png"  alt='.$score['country'].'/>'.'</td>';
        	echo '</tr>';
        	$rank++;
		}
		echo '</table></div><br /><center><p>Copyright &copy; 2015 Patrick Cossette</p></center>';
}

?>
</center>

</body>
</html>