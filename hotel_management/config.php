<?php

// Pass in your RDS credentials
$server = "Your RDS Endpoint";
$username = "Your RDS Username";
$password = "Your RDS Password";
$database = "Your RDS DB Name";

$conn = mysqli_connect($server,$username,$password,$database);

if(!$conn){
    die("<script>alert('connection Failed.')</script>");
}

?>